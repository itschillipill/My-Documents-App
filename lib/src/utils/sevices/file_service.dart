import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
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
        MessageService.showToast(context.l10n.notAvailableOnDesktop);
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

  static Future<void> shareFiles(List<String> paths, BuildContext context) async {
    debugPrint("Share files: $paths");
    if (paths.isEmpty) return;
    try {
      final files =
          paths
              .map((path) => File(path))
              .where((file) => file.existsSync())
              .map((file) => XFile(file.path))
              .toList();

      if (files.isEmpty) {
        MessageService.showErrorSnack(context.l10n.filesNotFound);
        return;
      }

      await SharePlus.instance.share(ShareParams(files: files));
    } catch (e) {
      debugPrint("Share files error: $e");
     if(context.mounted) MessageService.showErrorSnack(context.l10n.failedToShare);
    }
  }

  static Future<void> importData(BuildContext context) async {
    MessageService.showErrorToast(context.l10n.notImplemented);
  }

  static Future<void> exportData(BuildContext context,{List<Document> documents = const []}) async {
    MessageService.showErrorToast(context.l10n.notImplemented);
  }
}
