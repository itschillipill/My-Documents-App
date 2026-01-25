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

      for (final docJson in docsList) {
        var doc = await dataSource.insertDocument(
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

        final List<DocumentVersion> createdVersions = [];
        int? currentVersionDbId;

        final versionsJson = docJson['versions'] as List;

        for (int i = 0; i < versionsJson.length; i++) {
          final v = versionsJson[i];

          final fileName = v['file'];
          final sourceFile = File(p.join(filesDir.path, fileName));
          final newPath = p.join(appDir.path, fileName);

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

          if (i == docJson['currentVersionIndex']) {
            currentVersionDbId = newVersion.id;
          }
        }

        doc = doc.copyWith(
          currentVersionId: currentVersionDbId,
          versions: createdVersions,
        );

        await dataSource.updateDocument(doc);

        restoredDocuments.add(doc);
      }

      return ResultOr.success(restoredDocuments);
    } catch (e, st) {
      debugPrint('$e');
      debugPrintStack(stackTrace: st);
      return ResultOr.error(ErrorKeys.failedToImport);
    } finally {
      if (tempDir != null && await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  }
}
