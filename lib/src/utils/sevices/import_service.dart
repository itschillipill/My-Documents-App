import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:my_documents/src/core/model/errors.dart';
import 'package:my_documents/src/database/database.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/result_or.dart';
import '../../features/documents/model/document.dart';
import 'file_service.dart';

class ImportService {
  static Future<ResultOr<List<Document>>> importAndReplace(
    DataSource dataSource,
  ) async {
    Directory? tempDir;

    if (!kDebugMode) return ResultOr.error(ErrorKeys.notImplemented);

    try {
      // ================= 📦 ВЫБОР ZIP =================
      final result = await FilePicker.platform.pickFiles(
        allowedExtensions: ['zip'],
      );

      if (result == null || result.files.single.path == null) {
        return ResultOr.error(ErrorKeys.filesNotFound);
      }

      final zipFile = File(result.files.single.path!);

      // ================= 📂 РАСПАКОВКА =================
      tempDir = await Directory(
        p.join(
          (await getTemporaryDirectory()).path,
          'import_${DateTime.now().millisecondsSinceEpoch}',
        ),
      ).create(recursive: true);

      final archive = ZipDecoder().decodeBytes(await zipFile.readAsBytes());

      for (final file in archive) {
        final outPath = p.join(tempDir.path, file.name);
        if (file.isFile) {
          final outFile = File(outPath);
          await outFile.parent.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
        }
      }

      // ================= 📄 ПРОВЕРКИ =================
      final manifestFile = File(p.join(tempDir.path, 'manifest.json'));
      final docsFile = File(p.join(tempDir.path, 'documents.json'));
      final filesDir = Directory(p.join(tempDir.path, 'files'));

      if (!await manifestFile.exists() ||
          !await docsFile.exists() ||
          !await filesDir.exists()) {
        return ResultOr.error(ErrorKeys.invalidBackupFormat);
      }

      final manifest = jsonDecode(await manifestFile.readAsString());
      if (manifest['format'] != 'my_documents_export') {
        return ResultOr.error(ErrorKeys.invalidBackupFormat);
      }

      final docsJson = jsonDecode(await docsFile.readAsString());
      final List docsList = docsJson['documents'];

      // ================= 🔐 ВАЛИДАЦИЯ ФАЙЛОВ =================
      for (final doc in docsList) {
        final versions = doc['versions'] as List;
        
        for (final v in versions) {
          final fileName = v['file'];
          final expectedHash = v['hash'];

          final f = File(p.join(filesDir.path, fileName));
          if (!await f.exists()) {
            return ResultOr.error(ErrorKeys.corruptedBackup);
          }

          final actualHash = await FileService.calculateFileHash(f);
          if (actualHash != expectedHash) {
            return ResultOr.error(ErrorKeys.corruptedBackup);
          }
        }
      }

      // ================= 🗑️ ОЧИСТКА СУЩЕСТВУЮЩИХ ДАННЫХ =================
      final allDocs = await dataSource.getAllDocuments();
      if (allDocs.isNotEmpty) {
        await dataSource.deleteDocumentsByIds(
          allDocs.map((e) => e.id).toList(),
        );
      }

      final appDir = await FileService.getDocumentsStorageDir();
      if (await appDir.exists()) {
        await appDir.delete(recursive: true);
      }
      await appDir.create(recursive: true);

      final List<Document> restoredDocuments = [];

      // ================= 📄 ИМПОРТ ДОКУМЕНТОВ =================
      for (final docJson in docsList) {
        // Создаем новый документ (обратите внимание: поле 'token' теперь не используется в модели Document)
        var doc = await dataSource.insertDocument(
          Document(
            id: 0,
            title: docJson['title'],
            folderId: null,
            isFavorite: docJson['isFavorite'],
            createdAt: DateTime.parse(docJson['createdAt']),
            currentVersionId: null, // Установим после создания версий
            versions: [],
          ),
        );

        final List<DocumentVersion> createdVersions = [];
        int? currentVersionDbId;

        final versionsJson = docJson['versions'] as List;
        final int currentVersionIndex = docJson['currentVersionIndex'] ?? 0;

        // Создаем все версии документа
        for (int i = 0; i < versionsJson.length; i++) {
          final v = versionsJson[i];

          final fileName = v['file'];
          final sourceFile = File(p.join(filesDir.path, fileName));
          
          // Генерируем новое уникальное имя файла для избежания конфликтов
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileExt = p.extension(fileName);
          final newFileName = '${doc.id}_${i}_$timestamp$fileExt';
          final newPath = p.join(appDir.path, newFileName);

          await sourceFile.copy(newPath);

          final newVersion = await dataSource.addNewVersion(
            doc.id,
            DocumentVersion(
              id: 0,
              documentId: doc.id,
              filePath: newPath,
              uploadedAt: DateTime.parse(v['uploadedAt']),
              comment: v['comment'],
              expirationDate: v['expirationDate'] != null
                  ? DateTime.parse(v['expirationDate'])
                  : null,
            ),
          );

          createdVersions.add(newVersion);

          // Сохраняем ID текущей версии
          if (i == currentVersionIndex) {
            currentVersionDbId = newVersion.id;
          }
        }

        // Обновляем документ с текущей версией
        doc = doc.copyWith(
          currentVersionId: currentVersionDbId ?? createdVersions.firstOrNull?.id,
          versions: createdVersions,
        );

        await dataSource.updateDocument(doc);

        restoredDocuments.add(doc);
      }

      return ResultOr.success(restoredDocuments);
    } catch (e, st) {
      debugPrint('Import error: $e');
      debugPrintStack(stackTrace: st);
      return ResultOr.error(ErrorKeys.failedToImport);
    } finally {
      if (tempDir != null && await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  }

  // ================= 📥 ИМПОРТ БЕЗ УДАЛЕНИЯ СУЩЕСТВУЮЩИХ ДАННЫХ =================
  static Future<ResultOr<List<Document>>> importAdditive(
    DataSource dataSource,
  ) async {
    Directory? tempDir;

    if (!kDebugMode) return ResultOr.error(ErrorKeys.notImplemented);

    try {
      // ================= 📦 ВЫБОР ZIP =================
      final result = await FilePicker.platform.pickFiles(
        allowedExtensions: ['zip'],
      );

      if (result == null || result.files.single.path == null) {
        return ResultOr.error(ErrorKeys.filesNotFound);
      }

      final zipFile = File(result.files.single.path!);

      // ================= 📂 РАСПАКОВКА =================
      tempDir = await Directory(
        p.join(
          (await getTemporaryDirectory()).path,
          'import_add_${DateTime.now().millisecondsSinceEpoch}',
        ),
      ).create(recursive: true);

      final archive = ZipDecoder().decodeBytes(await zipFile.readAsBytes());

      for (final file in archive) {
        final outPath = p.join(tempDir.path, file.name);
        if (file.isFile) {
          final outFile = File(outPath);
          await outFile.parent.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
        }
      }

      // ================= 📄 ПРОВЕРКИ =================
      final manifestFile = File(p.join(tempDir.path, 'manifest.json'));
      final docsFile = File(p.join(tempDir.path, 'documents.json'));
      final filesDir = Directory(p.join(tempDir.path, 'files'));

      if (!await manifestFile.exists() ||
          !await docsFile.exists() ||
          !await filesDir.exists()) {
        return ResultOr.error(ErrorKeys.invalidBackupFormat);
      }

      final manifest = jsonDecode(await manifestFile.readAsString());
      if (manifest['format'] != 'my_documents_export') {
        return ResultOr.error(ErrorKeys.invalidBackupFormat);
      }

      final docsJson = jsonDecode(await docsFile.readAsString());
      final List docsList = docsJson['documents'];

      // ================= 🔐 ВАЛИДАЦИЯ ФАЙЛОВ =================
      for (final doc in docsList) {
        for (final v in doc['versions'] as List) {
          final fileName = v['file'];
          final expectedHash = v['hash'];

          final f = File(p.join(filesDir.path, fileName));
          if (!await f.exists()) {
            return ResultOr.error(ErrorKeys.corruptedBackup);
          }

          final actualHash = await FileService.calculateFileHash(f);
          if (actualHash != expectedHash) {
            return ResultOr.error(ErrorKeys.corruptedBackup);
          }
        }
      }

      final appDir = await FileService.getDocumentsStorageDir();
      if (!await appDir.exists()) {
        await appDir.create(recursive: true);
      }

      final List<Document> importedDocuments = [];

      // ================= 📥 ДОБАВЛЕНИЕ НОВЫХ ДОКУМЕНТОВ =================
      for (final docJson in docsList) {
        // Проверяем, нет ли уже документа с таким названием
        final existingDocs = await dataSource.getAllDocuments();
        final titleExists = existingDocs.any((d) => d.title == docJson['title']);
        
        // Если документ с таким названием уже существует, добавляем суффикс
        String finalTitle = docJson['title'];
        if (titleExists) {
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          finalTitle = '${docJson['title']} (импорт $timestamp)';
        }

        var doc = await dataSource.insertDocument(
          Document(
            id: 0,
            title: finalTitle,
            folderId: null,
            isFavorite: docJson['isFavorite'],
            createdAt: DateTime.parse(docJson['createdAt']),
            currentVersionId: null,
            versions: [],
          ),
        );

        final List<DocumentVersion> createdVersions = [];
        int? currentVersionDbId;

        final versionsJson = docJson['versions'] as List;
        final int currentVersionIndex = docJson['currentVersionIndex'] ?? 0;

        for (int i = 0; i < versionsJson.length; i++) {
          final v = versionsJson[i];

          final fileName = v['file'];
          final sourceFile = File(p.join(filesDir.path, fileName));
          
          // Генерируем уникальное имя файла
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileExt = p.extension(fileName);
          final newFileName = '${doc.id}_${i}_$timestamp$fileExt';
          final newPath = p.join(appDir.path, newFileName);

          await sourceFile.copy(newPath);

          final newVersion = await dataSource.addNewVersion(
            doc.id,
            DocumentVersion(
              id: 0,
              documentId: doc.id,
              filePath: newPath,
              uploadedAt: DateTime.parse(v['uploadedAt']),
              comment: v['comment'],
              expirationDate: v['expirationDate'] != null
                  ? DateTime.parse(v['expirationDate'])
                  : null,
            ),
          );

          createdVersions.add(newVersion);

          if (i == currentVersionIndex) {
            currentVersionDbId = newVersion.id;
          }
        }

        doc = doc.copyWith(
          currentVersionId: currentVersionDbId ?? createdVersions.firstOrNull?.id,
          versions: createdVersions,
        );

        await dataSource.updateDocument(doc);

        importedDocuments.add(doc);
      }

      return ResultOr.success(importedDocuments);
    } catch (e, st) {
      debugPrint('Import additive error: $e');
      debugPrintStack(stackTrace: st);
      return ResultOr.error(ErrorKeys.failedToImport);
    } finally {
      if (tempDir != null && await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  }
}

// ================= 🛠️ УТИЛИТЫ =================
extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}