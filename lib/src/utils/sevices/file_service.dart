import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_documents/src/utils/sevices/message_service.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../features/documents/model/document.dart' show Document;

class FileService {
  static const int maxFileSize = 50 * 1024 * 1024; // 50 MB
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  /// Сохраняет файл в директорию приложения.
  /// Если файл с таким содержимым уже есть — возвращает его путь.
  /// Если файл с таким именем, но другим содержимым — сохраняет с новым именем.
  static Future<String> saveFileToAppDir(String originalPath) async {
    final appDir = await getApplicationSupportDirectory();
    final fileName = p.basename(originalPath);
    String newPath = p.join(appDir.path, fileName);

    final newFile = File(newPath);

    // Проверка размера
    final isValid = await validateFileSize(originalPath);
    if (!isValid) {
      throw Exception(
        "File is too large. Max allowed size is ${maxFileSize ~/ (1024 * 1024)} MB",
      );
    }

    // Если файл уже есть
    if (await newFile.exists()) {
      final existingHash = await calculateFileHash(newFile);
      final incomingHash = await calculateFileHash(File(originalPath));

      if (existingHash == incomingHash) {
        // Содержимое совпадает → используем существующий
        return newFile.path;
      } else {
        // Разное содержимое → генерируем новое имя
        newPath = await _generateUniqueFilePath(appDir.path, fileName);
      }
    }

    // Копируем файл в папку приложения
    return (await File(originalPath).copy(newPath)).path;
  }

  static Future<String?> pickFile(
    BuildContext context, {
    ImageSource? imageSource,
    Function(String?)? onSelected,
  }) async {
    String? path;
    if (imageSource != null) {
      if (imageSource == ImageSource.camera && !isMobile) {
        MessageService.showToast("This feature is not available on desktop");
        return null;
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
    onSelected?.call(path);
    return path;
  }

  static int getFileSize(String path) {
    try {
      return File(path).lengthSync();
    } catch (e) {
      debugPrint("Error getting file size: $e");
      return 0;
    }
  }

  /// Удаляет файл
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

  static Future<void> deleteFiles(List<String> paths) async {
    await Future.wait(
      paths.map((path) async {
        await deleteFile(path);
      }),
    );
  }

  static Future<void> deleteDocumentFiles(
    Document document,
    List<Document> allDocuments,
  ) async {
    for (final version in document.versions) {
      final filePath = version.filePath;

      // Проверяем, используется ли этот файл в других документах
      final isUsedElsewhere = allDocuments.any(
        (doc) =>
            doc.id != document.id &&
            doc.versions.any((v) => v.filePath == filePath),
      );

      if (!isUsedElsewhere) {
        await FileService.deleteFile(filePath);
      } else {
        debugPrint("File $filePath is used in another document, not deleting");
      }
    }
  }

  /// Проверяет размер файла
  static Future<bool> validateFileSize(String path) async {
    final file = File(path);
    final size = await file.length();
    return size <= maxFileSize;
  }

  /// Считает SHA256 хэш файла
  static Future<String> calculateFileHash(File file) async {
    final bytes = await file.readAsBytes();
    return sha256.convert(bytes).toString();
  }

  /// Генерация уникального имени для файла
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

  static Future<void> shareFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await SharePlus.instance.share(ShareParams(files: [XFile(path)]));
      } else {
        debugPrint("File not found: $path");
        MessageService.showErrorSnack("File not found: $path");
      }
    } catch (e) {
      MessageService.showErrorSnack(e.toString());
    }
  }

  static Future<void> importData() async {
    MessageService.showErrorToast("Not implemented yet");
  }

  static Future<void> exportData({List<Document> documents = const []}) async {
    if (documents.isEmpty) {
      MessageService.showErrorSnack("No documents to export");
      return;
    }
    final tmpDir = await getTemporaryDirectory();
    final backupPath = p.join(tmpDir.path, "backup.zip");
    final encoder = ZipFileEncoder();
    encoder.create(backupPath);

    final dbFile = File(
      '${(await getApplicationDocumentsDirectory()).path}/my_database.db',
    );
    if (await dbFile.exists()) {
      encoder.addFile(dbFile);
    }

    final addedPaths = <String>{};

    for (final doc in documents) {
      for (final version in doc.versions) {
        final path = version.filePath;
        if (path.isEmpty || addedPaths.contains(path)) continue;

        final file = File(path);
        if (await file.exists()) {
          try {
            encoder.addFile(file);
            addedPaths.add(path);
          } catch (e) {
            debugPrint("Failed to add file $path: $e");
          }
        } else {
          debugPrint("Missing file: $path");
        }
      }
    }

    encoder.close();
    debugPrint("saved to $backupPath");
    await SharePlus.instance.share(
      ShareParams(files: [XFile(backupPath)], text: "My Documents Backup"),
    );
  }
}
