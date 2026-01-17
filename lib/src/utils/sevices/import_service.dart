import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:my_documents/src/core/model/errors.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/result_or.dart';
import '../../data/data_sourse.dart';
import '../../features/documents/model/document.dart';
import 'file_service.dart';

class ImportService {
  static Future<ResultOr<void>> importAndReplace({
    required DataSource dataSource,
  }) async {
    Directory? tempDir;
    if (!kDebugMode) return ResultOr.error(ErrorKeys.notImplemented);

    try {
      final result = await FilePicker.platform.pickFiles(
        allowedExtensions: ['zip'],
      );
      if (result == null || result.files.single.path == null) {
        return ResultOr.error(ErrorKeys.filesNotFound);
      }
      final zipFile = File(result.files.single.path!);

      // 1️⃣ Распаковка
      tempDir = await Directory(
        p.join(
          (await getTemporaryDirectory()).path,
          'import_${DateTime.now().millisecondsSinceEpoch}',
        ),
      ).create(recursive: true);

      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      for (final file in archive) {
        final outPath = p.join(tempDir.path, file.name);
        if (file.isFile) {
          final outFile = File(outPath);
          await outFile.parent.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
        }
      }

      // 2️⃣ Проверка manifest
      final manifestFile = File(p.join(tempDir.path, 'manifest.json'));
      if (!await manifestFile.exists()) {
        return ResultOr.error(ErrorKeys.invalidBackupFormat);
      }

      final manifest = jsonDecode(await manifestFile.readAsString());
      if (manifest['format'] != 'my_documents_export') {
        return ResultOr.error(ErrorKeys.invalidBackupFormat);
      }

      // 3️⃣ Читаем documents.json
      final docsFile = File(p.join(tempDir.path, 'documents.json'));
      if (!await docsFile.exists()) {
        return ResultOr.error(ErrorKeys.invalidBackupFormat);
      }

      final docsJson = jsonDecode(await docsFile.readAsString());
      final List docsList = docsJson['documents'];

      final filesDir = Directory(p.join(tempDir.path, 'files'));
      if (!await filesDir.exists()) {
        return ResultOr.error(ErrorKeys.invalidBackupFormat);
      }

      // 4️⃣ ПОЛНАЯ ВАЛИДАЦИЯ ФАЙЛОВ
      for (final doc in docsList) {
        for (final v in doc['versions']) {
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

      // ================= 💣 СНОСИМ ВСЁ =================

      // 5️⃣ Удаляем все документы из БД
      final allDocs = await dataSource.getAllDocuments();
      if (allDocs.isNotEmpty) {
        await dataSource.deleteDocumentsByIds(
          allDocs.map((e) => e.id).toList(),
        );
      }

      // 6️⃣ Чистим папку приложения
      final appDir = await FileService.getDocumentsStorageDir();
      if (await appDir.exists()) {
        await appDir.delete(recursive: true);
      }
      await appDir.create(recursive: true);

      // ================= ♻️ ВОССТАНАВЛИВАЕМ =================

      for (final docJson in docsList) {
        // 7️⃣ Создаём документ
        final insertedDoc = await dataSource.insertDocument(
          Document(
            id: 0,
            title: docJson['title'],
            folderId: null,
            isFavorite: docJson['isFavorite'],
            createdAt: DateTime.parse(docJson['createdAt']),
            currentVersionId: null,
            versions: [],
          ),
        );

        int? currentVersionDbId;

        final versionsJson = docJson['versions'] as List;

        for (int i = 0; i < versionsJson.length; i++) {
          final v = versionsJson[i];

          final fileName = v['file'];
          final sourceFile = File(p.join(filesDir.path, fileName));

          final newPath = p.join(appDir.path, fileName);
          await sourceFile.copy(newPath);

          final insertedVersion = await dataSource.addNewVersion(
            insertedDoc.id,
            DocumentVersion(
              id: 0,
              documentId: insertedDoc.id,
              filePath: newPath,
              uploadedAt: DateTime.parse(v['uploadedAt']),
              comment: v['comment'],
              expirationDate: v['expirationDate'] != null
                  ? DateTime.parse(v['expirationDate'])
                  : null,
            ),
          );

          if (i == docJson['currentVersionIndex']) {
            currentVersionDbId = insertedVersion.id;
          }
        }

        // 8️⃣ Обновляем currentVersionId
        await dataSource.updateDocument(
          insertedDoc.copyWith(currentVersionId: currentVersionDbId),
        );
      }

      return ResultOr.success(null);
    } catch (e, st) {
      debugPrint('$e');
      debugPrintStack(stackTrace: st);
      return ResultOr.error(ErrorKeys.failedToImport);
    } finally {
      // 🧹 Чистим временную папку
      if (tempDir != null && await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  }
}
