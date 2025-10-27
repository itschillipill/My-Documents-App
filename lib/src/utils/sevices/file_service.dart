import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FileService {
  static const int maxFileSize = 50 * 1024 * 1024; // 50 MB
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  /// Сохраняет файл в директорию приложения.
  /// Если файл с таким содержимым уже есть — возвращает его путь.
  /// Если файл с таким именем, но другим содержимым — сохраняет с новым именем.
  static Future<String> saveFileToAppDir(String originalPath) async {
    final appDir = await getApplicationDocumentsDirectory();
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
      final existingHash = await _calculateFileHash(newFile);
      final incomingHash = await _calculateFileHash(File(originalPath));

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("This feature is not available on desktop"),
          ),
        );
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
    return null;
  }

  /// Удаляет файл
  static Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Проверяет размер файла
  static Future<bool> validateFileSize(String path) async {
    final file = File(path);
    final size = await file.length();
    return size <= maxFileSize;
  }

  /// Считает SHA256 хэш файла
  static Future<String> _calculateFileHash(File file) async {
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
}
