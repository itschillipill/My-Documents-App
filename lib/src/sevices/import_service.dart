import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:my_documents/src/core/model/errors.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/result_or.dart';
import '../features/documents/model/document.dart';
import 'file_service.dart';

class ImportService {
  static Future<ResultOr<void>> import({
    required Function() onClearAllDocuments,
    required Function(List<Document>) onAddAllDocuments,
  }) async {
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
      await onClearAllDocuments();

      final appDir = await FileService.getDocumentsStorageDir();
      if (await appDir.exists()) {
        await appDir.delete(recursive: true);
      }
      await appDir.create(recursive: true);

      final List<Document> documentsToImport = [];

      // ================= 📄 ПОДГОТОВКА ДОКУМЕНТОВ =================
      for (final docJson in docsList) {
        final versionsJson = docJson['versions'] as List;
        final int currentVersionIndex = docJson['currentVersionIndex'] ?? 0;
        
        if (versionsJson.isEmpty) {
          debugPrint('Document ${docJson['title']} has no versions, skipping');
          continue;
        }

        final List<DocumentVersion> documentVersions = [];

        // Создаем все версии документа
        for (int i = 0; i < versionsJson.length; i++) {
          final v = versionsJson[i];
          final fileName = v['file'];
          final sourceFile = File(p.join(filesDir.path, fileName));
          
          // Генерируем уникальное имя файла
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileExt = p.extension(fileName);
          final newFileName = 'doc_${documentsToImport.length}_${i}_$timestamp$fileExt';
          final newPath = p.join(appDir.path, newFileName);

          await sourceFile.copy(newPath);

          documentVersions.add(
            DocumentVersion(
              id: 0,
              documentId: 0, // Будет установлено при вставке
              filePath: newPath,
              uploadedAt: DateTime.parse(v['uploadedAt']),
              comment: v['comment'],
              expirationDate: v['expirationDate'] != null
                  ? DateTime.parse(v['expirationDate'])
                  : null,
            ),
          );
        }

        // Определяем текущую версию
        final currentVersionId = currentVersionIndex < documentVersions.length
            ? 0 // Временный ID, будет заменен при вставке
            : null;

        final doc = Document(
          id: 0,
          title: docJson['title'],
          folderId: null,
          isFavorite: docJson['isFavorite'],
          createdAt: DateTime.parse(docJson['createdAt']),
          currentVersionId: currentVersionId,
          versions: documentVersions,
        );

        documentsToImport.add(doc);
      }

      // ================= 📥 ДОБАВЛЕНИЕ ВСЕХ ДОКУМЕНТОВ =================
      await onAddAllDocuments(documentsToImport);

      return ResultOr.success(null);
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
}