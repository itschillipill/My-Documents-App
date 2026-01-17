import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../core/model/errors.dart';
import '../../core/result_or.dart';
import '../../features/documents/model/document.dart';
import '../../features/export/export_build_context.dart';
import '../../features/export/export_document.dart';
import '../../features/export/export_document_version.dart';

class ExportService {
  static Future<ResultOr<void>> exportData({
    required List<Document> documents,
  }) async {
    Directory? exportDir;

    try {
      if (!kDebugMode) return ResultOr.error(ErrorKeys.notImplemented);
      final tempDir = await getTemporaryDirectory();

      exportDir = Directory(
        p.join(tempDir.path, 'export_${DateTime.now().millisecondsSinceEpoch}'),
      );
      await exportDir.create(recursive: true);

      final filesDir = Directory(p.join(exportDir.path, 'files'));
      await filesDir.create();

      final ctx = ExportBuildContext(filesDir);
      final exportedDocs = <ExportDocument>[];

      for (final doc in documents) {
        exportedDocs.add(await buildExportDocument(doc, ctx));
      }

      await writeDocumentsJson(exportDir, exportedDocs);
      await writeManifest(exportDir);

      final zipBytes = await Isolate.run(
        () => buildZipInIsolate(exportDir!.path),
      );

      final zipFile = File(
        p.join(
          tempDir.path,
          'my_documents_export_${DateTime.now().millisecondsSinceEpoch}.zip',
        ),
      );

      await zipFile.writeAsBytes(zipBytes);

      await SharePlus.instance.share(ShareParams(files: [XFile(zipFile.path)]));

      return ResultOr.success(null);
    } catch (e, st) {
      debugPrint('$e');
      debugPrintStack(stackTrace: st);
      return ResultOr.error(ErrorKeys.failedToShare);
    } finally {
      if (exportDir != null) {
        try {
          if (await exportDir.exists()) {
            await exportDir.delete(recursive: true);
            debugPrint('Export temp directory deleted: ${exportDir.path}');
          }
        } catch (e) {
          debugPrint('Failed to delete export temp directory: $e');
        }
      }
    }
  }

  static Future<ExportDocument> buildExportDocument(
    Document document,
    ExportBuildContext ctx,
  ) async {
    final versions = <ExportDocumentVersion>[];

    for (final v in document.versions) {
      final zipFileName = await ctx.registerFile(v.filePath);

      versions.add(
        ExportDocumentVersion(
          file: zipFileName,
          hash: p.basenameWithoutExtension(zipFileName),
          uploadedAt: v.uploadedAt,
          comment: v.comment,
          expirationDate: v.expirationDate,
        ),
      );
    }

    final currentIndex = document.versions.indexWhere(
      (v) => v.id == document.currentVersionId,
    );

    if (currentIndex == -1) {
      throw StateError('Current version not found for document ${document.id}');
    }

    return ExportDocument(
      uuid: const Uuid().v4(),
      title: document.title,
      isFavorite: document.isFavorite,
      createdAt: document.createdAt,
      currentVersionIndex: currentIndex,
      versions: versions,
    );
  }

  static Uint8List buildZipInIsolate(String exportDirPath) {
    final archive = Archive();
    final dir = Directory(exportDirPath);

    for (final entity in dir.listSync(recursive: true)) {
      if (entity is! File) continue;

      final relativePath = p.relative(entity.path, from: exportDirPath);

      archive.addFile(
        ArchiveFile(
          relativePath,
          entity.lengthSync(),
          entity.readAsBytesSync(),
        ),
      );
    }

    final zipData = ZipEncoder().encode(archive);
    return Uint8List.fromList(zipData);
  }

  static Future<void> writeDocumentsJson(
    Directory exportDir,
    List<ExportDocument> documents,
  ) async {
    final file = File(p.join(exportDir.path, 'documents.json'));

    final json = {'documents': documents.map((d) => d.toJson()).toList()};

    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(json));
  }

  static Future<void> writeManifest(Directory exportDir) async {
    final file = File(p.join(exportDir.path, 'manifest.json'));
    await file.writeAsString(jsonEncode(buildManifest()));
  }

  static Map<String, dynamic> buildManifest() => {
    'format': 'my_documents_export',
    'version': 1,
    'createdAt': DateTime.now().toIso8601String(),
  };
}
