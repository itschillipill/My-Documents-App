import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/app_context.dart';
import '../core/model/errors.dart';
import '../core/result_or.dart';
import '../features/documents/model/document.dart';
import 'file_service.dart';

class ExportBuildContext {
  final Map<String, String> hashToFileName = {};
  final Directory filesDir;

  ExportBuildContext(this.filesDir);

  Future<String> registerFile(String filePath) async {
    final file = File(filePath);
    final hash = await FileService.calculateFileHash(file);

    return hashToFileName.putIfAbsent(hash, () {
      final ext = p.extension(filePath);
      final name = '$hash$ext';
      file.copySync(p.join(filesDir.path, name));
      return name;
    });
  }
}

class ExportService {
  static Future<ResultOr<void>> exportData({
    required List<Document> documents,
  }) async {
    Directory? exportDir;

    try {
      if (AppContext.instance.config.isProd) return ResultOr.error(ErrorKeys.notImplemented);
      
      final tempDir = await _getSaveDirectory();
      exportDir = Directory(
        p.join(tempDir, 'export_${DateTime.now().millisecondsSinceEpoch}'),
      );
      await exportDir.create(recursive: true);

      final filesDir = Directory(p.join(exportDir.path, 'files'));
      await filesDir.create();

      final ctx = ExportBuildContext(filesDir);
      
      final exportedDocs = <Map<String, dynamic>>[];
      for (final doc in documents) {
        exportedDocs.add(await doc.exportMap(ctx));
      }

      await writeDocumentsJson(exportDir, exportedDocs);
      await writeManifest(exportDir);

      final zipBytes = await Isolate.run(
        () => buildZipInIsolate(exportDir!.path),
      );

      final zipFile = File(
        p.join(
          tempDir,
          'my_documents_export_${DateTime.now().millisecondsSinceEpoch}.zip',
        ),
      );

      await zipFile.writeAsBytes(zipBytes);
      await SharePlus.instance.share(ShareParams(files: [XFile(zipFile.path)]));

      return ResultOr.success(null);
    } catch (e, st) {
      debugPrint('$e\n$st');
      return ResultOr.error(ErrorKeys.failedToShare);
    } finally {
      await exportDir?.deleteIfExists();
    }
  }

  static Future<void> writeDocumentsJson(
    Directory exportDir,
    List<Map<String, dynamic>> documents,
  ) async {
    final file = File(p.join(exportDir.path, 'documents.json'));
    final json = {'documents': documents};
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(json));
  }

   static Future<String> _getSaveDirectory() async {
    if (Platform.isAndroid) {
      final dir = Directory('/storage/emulated/0/Download');

      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      return dir.path;
    }

    if (Platform.isIOS) {
      final dir = await getApplicationDocumentsDirectory();
      return dir.path;
    }

    final dir = await getDownloadsDirectory() ?? await getTemporaryDirectory();
    return dir.path;
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

extension DirectoryExtension on Directory {
  Future<void> deleteIfExists() async {
    try {
      if (await exists()) await delete(recursive: true);
    } catch (e) {
      debugPrint('Failed to delete directory: $e');
    }
  }
}