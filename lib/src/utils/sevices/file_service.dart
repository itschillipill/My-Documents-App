import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show BuildContext;
import 'package:image_picker/image_picker.dart';
import 'package:my_documents/src/core/model/errors.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../core/result_or.dart';
import '../../features/documents/model/document.dart' show Document;
import '../../features/export/export_build_context.dart';
import '../../features/export/export_document.dart';
import '../../features/export/export_document_version.dart';

class FileService {
  static const int maxFileSize = 50 * 1024 * 1024; // 50 MB
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  static Future<String> saveFileToAppDir(String originalPath) async {
    final appDir = await getApplicationSupportDirectory();
    final fileName = p.basename(originalPath);
    String newPath = p.join(appDir.path, fileName);

    final newFile = File(newPath);

    final isValid = await validateFileSize(originalPath);
    if (!isValid) {
      throw Exception(
        "File is too large. Max allowed size is ${maxFileSize ~/ (1024 * 1024)} MB",
      );
    }

    if (await newFile.exists()) {
      final existingHash = await calculateFileHash(newFile);
      final incomingHash = await calculateFileHash(File(originalPath));

      if (existingHash == incomingHash) {
        return newFile.path;
      } else {
        newPath = await _generateUniqueFilePath(appDir.path, fileName);
      }
    }

    return (await File(originalPath).copy(newPath)).path;
  }


  static Future<ResultOr<String?>> scanDocument(BuildContext context) async {
  if(!isMobile) return ResultOr.error(ErrorKeys.notAvailableOnDesktop);
  try {
    final List<String>? pictures =
        await CunningDocumentScanner.getPictures(noOfPages: 1);
      return ResultOr.success(pictures?.first);
    
  } catch (e) {
    return ResultOr.error(ErrorKeys.failedToScan);
  }
}

  static Future<ResultOr<String?>> pickFile({ImageSource? imageSource}) async {
    String? path;
    if (imageSource != null) {
      if (imageSource == ImageSource.camera && !isMobile) {
        return ResultOr.error(ErrorKeys.notAvailableOnDesktop);
      }
      final image = await ImagePicker().pickImage(source: imageSource);
      if (image != null) {
        path = image.path;
      }
    } else {
      final result = await FilePicker.platform.pickFiles();
      if (result != null) {
        path = result.files.single.path!;
      }
    }
    return ResultOr.success(path);
  }

  static int getFileSize(String path) {
    try {
      return File(path).lengthSync();
    } catch (e) {
      debugPrint("Error getting file size: $e");
      return 0;
    }
  }

  static Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      try {
        await file.delete();
        debugPrint("Deleted file: $path");
      } catch (e) {
        debugPrint("Failed to delete $path, error: $e");
      }
    }
  }

  static Future<void> deleteDocumentsFiles(
    List<Document> documents,
    List<Document> allDocuments,
  ) async {
    debugPrint("documents to delete: ${documents.length}");

    // Уже обработанные пути, чтобы не удалять повторно
    final Set<String> processedPaths = {};

    for (final document in documents) {
      for (final version in document.versions) {
        final filePath = version.filePath;

        // Пропускаем, если этот файл уже проверяли
        if (!processedPaths.add(filePath)) {
          continue;
        }

        final isUsedElsewhere = allDocuments.any(
          (doc) =>
              doc.id != document.id &&
              doc.versions.any((v) => v.filePath == filePath),
        );

        if (isUsedElsewhere) {
          debugPrint("Skip deleting $filePath — used in another document");
          continue;
        }

        try {
          await deleteFile(filePath);
          debugPrint("Deleted file: $filePath");
        } catch (e, st) {
          debugPrint("Failed to delete $filePath: $e");
          debugPrintStack(stackTrace: st);
          // продолжаем, не падаем
        }
      }
    }
  }

  static Future<bool> validateFileSize(String path) async {
    final file = File(path);
    final size = await file.length();
    return size <= maxFileSize;
  }

  static Future<String> calculateFileHash(File file) async {
    final bytes = await file.readAsBytes();
    return sha256.convert(bytes).toString();
  }

  static Future<String> _generateUniqueFilePath(
    String dir,
    String fileName,
  ) async {
    final name = p.basenameWithoutExtension(fileName);
    final ext = p.extension(fileName);

    int counter = 1;
    String newPath;

    do {
      final newName = "${name}_$counter$ext";
      newPath = p.join(dir, newName);
      counter++;
    } while (await File(newPath).exists());

    return newPath;
  }

  static Future<ResultOr<void>> shareFiles(List<String> paths) async {
    debugPrint("Share files: $paths");
    if (paths.isEmpty) return ResultOr.error(ErrorKeys.filesNotFound);
    try {
      final files =
          paths
              .toSet()
              .map((path) => File(path))
              .where((file) => file.existsSync())
              .map((file) => XFile(file.path))
              .toList();

      if (files.isEmpty) return ResultOr.error(ErrorKeys.filesNotFound);

      await SharePlus.instance.share(ShareParams(files: files));
      return ResultOr<void>.success(null);
    } catch (e) {
      debugPrint("Share files error: $e");
      return ResultOr.error(ErrorKeys.failedToShare);
    }
  }

  static Future<ResultOr<List<Document>>> importData() async {
    return ResultOr.error(ErrorKeys.notImplemented);
    // try {
    //   // 1️⃣ Выбор zip
    //   final result = await FilePicker.platform.pickFiles(
    //     type: FileType.custom,
    //     allowedExtensions: ['zip'],
    //   );
    //   if (result == null) {
    //     return ResultOr.error(ErrorKeys.filesNotFound);
    //   }

    //   final zipPath = result.files.single.path;
    //   if (zipPath == null) {
    //     return ResultOr.error(ErrorKeys.filesNotFound);
    //   }

    //   // 2️⃣ Распаковка
    //   final bytes = await File(zipPath).readAsBytes();
    //   final archive = ZipDecoder().decodeBytes(bytes);

    //   final tempDir = await getTemporaryDirectory();
    //   final extractDir = Directory(
    //     p.join(tempDir.path, 'import_${DateTime.now().millisecondsSinceEpoch}'),
    //   );
    //   await extractDir.create(recursive: true);

    //   for (final file in archive) {
    //     final outPath = p.join(extractDir.path, file.name);

    //     if (file.isFile) {
    //       final outFile = File(outPath);
    //       await outFile.create(recursive: true);
    //       await outFile.writeAsBytes(file.content as List<int>);
    //     }
    //   }

    //   // 3️⃣ Проверка manifest.json
    //   final manifestFile = File(p.join(extractDir.path, 'manifest.json'));
    //   if (!await manifestFile.exists()) {
    //     return ResultOr.error(ErrorKeys.invalidImportFormat);
    //   }

    //   final manifest = jsonDecode(await manifestFile.readAsString());
    //   if (manifest['format'] != 'my_documents_export') {
    //     return ResultOr.error(ErrorKeys.invalidImportFormat);
    //   }

    //   // 4️⃣ Чтение documents.json
    //   final documentsFile = File(p.join(extractDir.path, 'documents.json'));
    //   if (!await documentsFile.exists()) {
    //     return ResultOr.error(ErrorKeys.invalidImportFormat);
    //   }

    //   final documentsJson =
    //       jsonDecode(await documentsFile.readAsString())['documents']
    //           as List<dynamic>;

    //   // 5️⃣ Копирование файлов
    //   final filesDir = Directory(p.join(extractDir.path, 'files'));
    //   final appDir = await getApplicationSupportDirectory();

    //   final Map<String, String> importedFiles = {};

    //   for (final file in filesDir.listSync()) {
    //     if (file is! File) continue;

    //     final hash = p.basenameWithoutExtension(file.path);
    //     final targetPath = p.join(appDir.path, p.basename(file.path));

    //     if (!await File(targetPath).exists()) {
    //       await file.copy(targetPath);
    //     }

    //     importedFiles[hash] = targetPath;
    //   }

    //   // 6️⃣ Восстановление документов
    //   for (final docJson in documentsJson) {
    //     final exportDoc = ExportDocument.fromJson(docJson);

    //     // Тут ты должен:
    //     // - создать Document
    //     // - создать версии
    //     // - подставить filePath по hash

    //     // Псевдокод:
    //     /*
    //     final document = Document(
    //       id: uuid,
    //       title: exportDoc.title,
    //       ...
    //     );

    //     for (final v in exportDoc.versions) {
    //       final filePath = importedFiles[v.hash];
    //       if (filePath == null) continue;

    //       document.addVersion(
    //         filePath: filePath,
    //         uploadedAt: v.uploadedAt,
    //         comment: v.comment,
    //       );
    //     }

    //     repository.save(document);
    //     */
    //   }

    //   return ResultOr.success(null);
    // } catch (e, st) {
    //   debugPrint("Import data error: $e");
    //   debugPrintStack(stackTrace: st);
    //   return ResultOr.error(ErrorKeys.failedToImport);
    // }
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
      folderId: document.folderId,
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

  static Future<ResultOr<void>> exportData({
    required List<Document> documents,
  }) async {
    if (!kDebugMode) return ResultOr.error(ErrorKeys.notImplemented);
    try {
      final tempDir = await getTemporaryDirectory();

      final exportDir = Directory(
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
        () => buildZipInIsolate(exportDir.path),
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
    }
  }
}
