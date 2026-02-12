import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:my_documents/src/core/model/errors.dart';
import 'package:my_documents/src/sevices/observer.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/app_context.dart';
import '../core/result_or.dart';
import '../features/documents/model/document.dart';
import 'file_service.dart';

class ImportService {
  static Future<ResultOr<void>> import({
    required Function() onClearAllDocuments,
    required Function(List<Document>) onAddAllDocuments,
  }) async {
    final log = StringBuffer();
    final stopwatch = Stopwatch()..start();
    
    log.writeln('🚀 ========== НАЧАЛО ИМПОРТА ==========');
    log.writeln('🕐 Время старта: ${DateTime.now().toIso8601String()}');
    
    Directory? tempDir;

    if (AppContext.instance.config.isProd) {
      log.writeln('❌ Импорт пока отключен в PROD режиме');
      SessionLogger.instance.warning("ImportService.import", log.toString());
      return ResultOr.error(ErrorKeys.notImplemented);
    }

    try {
      // ================= 📦 ВЫБОР ZIP =================
      log.writeln('\n📦 ШАГ 1: Выбор ZIP файла');
      
      final result = await FilePicker.platform.pickFiles(
        allowedExtensions: ['zip'],
        type: FileType.custom
      );

      if (result == null || result.files.single.path == null) {
        log.writeln('❌ Файл не выбран или путь пустой');
        SessionLogger.instance.error("ImportService.import", log.toString());
        return ResultOr.error(ErrorKeys.filesNotFound);
      }

      final zipPath = result.files.single.path!;
      log.writeln('✅ Выбран файл: $zipPath');
      log.writeln('📁 Размер файла: ${File(zipPath).lengthSync()} байт');

      final zipFile = File(zipPath);

      // ================= 📂 РАСПАКОВКА =================
      log.writeln('\n📂 ШАГ 2: Распаковка ZIP');
      
      tempDir = await Directory(
        p.join(
          (await getTemporaryDirectory()).path,
          'import_${DateTime.now().millisecondsSinceEpoch}',
        ),
      ).create(recursive: true);
      
      log.writeln('📁 Временная папка: ${tempDir.path}');

      final archiveBytes = await zipFile.readAsBytes();
      log.writeln('📦 ZIP прочитан: ${archiveBytes.length} байт');
      
      final archive = ZipDecoder().decodeBytes(archiveBytes);
      log.writeln('📦 Архив содержит ${archive.length} файлов');

      int extractedCount = 0;
      for (final file in archive) {
        final outPath = p.join(tempDir.path, file.name);
        if (file.isFile) {
          final outFile = File(outPath);
          await outFile.parent.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
          extractedCount++;
          
          if (extractedCount % 10 == 0) {
            log.writeln('   ⏳ Распаковано $extractedCount/${archive.length} файлов...');
          }
        }
      }
      log.writeln('✅ Распаковано $extractedCount файлов');

      // ================= 📄 ПРОВЕРКИ =================
      log.writeln('\n📄 ШАГ 3: Проверка структуры бэкапа');
      
      final manifestFile = File(p.join(tempDir.path, 'manifest.json'));
      final docsFile = File(p.join(tempDir.path, 'documents.json'));
      final filesDir = Directory(p.join(tempDir.path, 'files'));

      log.writeln('📄 Проверка manifest.json: ${await manifestFile.exists()}');
      log.writeln('📄 Проверка documents.json: ${await docsFile.exists()}');
      log.writeln('📁 Проверка папки files/: ${await filesDir.exists()}');

      if (!await manifestFile.exists() ||
          !await docsFile.exists() ||
          !await filesDir.exists()) {
        log.writeln('❌ Неверная структура бэкапа');
        SessionLogger.instance.error("ImportService.import", log.toString());
        return ResultOr.error(ErrorKeys.invalidBackupFormat);
      }

      final manifest = jsonDecode(await manifestFile.readAsString());
      log.writeln('📋 Манифест: format=${manifest['format']}, version=${manifest['version']}');
      
      if (manifest['format'] != 'my_documents_export') {
        log.writeln('❌ Неверный формат манифеста: ${manifest['format']}');
        SessionLogger.instance.error("ImportService.import", log.toString());
        return ResultOr.error(ErrorKeys.invalidBackupFormat);
      }

      final docsJson = jsonDecode(await docsFile.readAsString());
      final List docsList = docsJson['documents'];
      log.writeln('📋 Найдено документов в бэкапе: ${docsList.length}');

      // ================= 🔐 ВАЛИДАЦИЯ ФАЙЛОВ =================
      log.writeln('\n🔐 ШАГ 4: Валидация файлов (хеширование)');
      
      int totalFiles = 0;
      int validatedFiles = 0;
      
      for (final doc in docsList) {
        final versions = doc['versions'] as List;
        totalFiles += versions.length;
      }
      log.writeln('📁 Всего файлов для проверки: $totalFiles');

      for (int d = 0; d < docsList.length; d++) {
        final doc = docsList[d];
        final versions = doc['versions'] as List;
        
        for (int v = 0; v < versions.length; v++) {
          final version = versions[v];
          final fileName = version['file'];
          final expectedHash = version['hash'];

          final f = File(p.join(filesDir.path, fileName));
          
          if (!await f.exists()) {
            log.writeln('❌ Документ #$d, версия #$v: файл $fileName НЕ НАЙДЕН');
            SessionLogger.instance.error("ImportService.import", log.toString());
            return ResultOr.error(ErrorKeys.corruptedBackup);
          }

          final actualHash = await FileService.calculateFileHash(f);
          validatedFiles++;
          
          if (actualHash != expectedHash) {
            log.writeln('❌ Документ #$d, версия #$v: хеш НЕ СОВПАДАЕТ');
            log.writeln('   Ожидаемый: $expectedHash');
            log.writeln('   Фактический: $actualHash');
            SessionLogger.instance.error("ImportService.import", log.toString());
            return ResultOr.error(ErrorKeys.corruptedBackup);
          }
          
          if (validatedFiles % 5 == 0 || validatedFiles == totalFiles) {
            log.writeln('   ✅ Проверено $validatedFiles/$totalFiles файлов');
          }
        }
      }
      log.writeln('✅ Все $validatedFiles файлов успешно проверены');

      // ================= 🗑️ ОЧИСТКА СУЩЕСТВУЮЩИХ ДАННЫХ =================
      log.writeln('\n🧹 ШАГ 5: Очистка существующих данных');
      
      await onClearAllDocuments();
      log.writeln('✅ База данных очищена');

      final appDir = await FileService.getDocumentsStorageDir();
      log.writeln('📁 Папка приложения: ${appDir.path}');
      
      if (await appDir.exists()) {
        final oldFiles = await appDir.list().length;
        await appDir.delete(recursive: true);
        log.writeln('🗑️ Удалено $oldFiles старых файлов');
      }
      await appDir.create(recursive: true);
      log.writeln('📁 Создана чистая папка для файлов');

      final List<Document> documentsToImport = [];

      // ================= 📄 ПОДГОТОВКА ДОКУМЕНТОВ =================
      log.writeln('\n📄 ШАГ 6: Подготовка документов к импорту');
      log.writeln('📊 Всего документов для обработки: ${docsList.length}');

      for (int d = 0; d < docsList.length; d++) {
        final docJson = docsList[d];
        final versionsJson = docJson['versions'] as List;
        final int currentVersionIndex = docJson['currentVersionIndex'] ?? 0;
        
        log.writeln('\n   📄 Документ #${d + 1}/${docsList.length}: ${docJson['title']}');
        log.writeln('   📎 Версий: ${versionsJson.length}');

        if (versionsJson.isEmpty) {
          log.writeln('   ⚠️ Пропуск: нет версий');
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
          final fileSize = await File(newPath).length();
          
          log.writeln('      📄 Версия ${i + 1}/${versionsJson.length}: $fileName');
          log.writeln('         📁 Скопирован в: ${p.basename(newPath)}');
          log.writeln('         📦 Размер: $fileSize байт');
          log.writeln('         💬 Комментарий: ${v['comment'] ?? 'нет'}');

          documentVersions.add(
            DocumentVersion(
              id: 0,
              documentId: 0,
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
            ? 0
            : null;

        final doc = Document(
          id: 0,
          title: docJson['title'],
          folderId: null,
          isFavorite: docJson['isFavorite'] ?? false,
          createdAt: DateTime.parse(docJson['createdAt']),
          currentVersionId: currentVersionId,
          versions: documentVersions,
        );

        documentsToImport.add(doc);
        log.writeln('   ✅ Документ #${d + 1} подготовлен');
      }

      // ================= 📥 ДОБАВЛЕНИЕ ВСЕХ ДОКУМЕНТОВ =================
      log.writeln('\n📥 ШАГ 7: Сохранение документов в базу данных');
      log.writeln('📊 Всего документов к импорту: ${documentsToImport.length}');
      
      final totalVersions = documentsToImport.fold<int>(0, (sum, doc) => sum + doc.versions.length);
      log.writeln('📊 Всего версий: $totalVersions');

      await onAddAllDocuments(documentsToImport);
      log.writeln('✅ Документы успешно сохранены в БД');

      // ================= 🏁 ФИНИШ =================
      stopwatch.stop();
      log.writeln('\n🏁 ========== ИМПОРТ ЗАВЕРШЕН ==========');
      log.writeln('✅ Статус: УСПЕХ');
      log.writeln('⏱️ Время выполнения: ${stopwatch.elapsedMilliseconds} мс');
      log.writeln('📊 Импортировано документов: ${documentsToImport.length}');
      log.writeln('📊 Импортировано версий: $totalVersions');
      log.writeln('📁 Файлы сохранены в: ${appDir.path}');
      log.writeln('🕐 Время завершения: ${DateTime.now().toIso8601String()}');

      // ВЫВОД ВСЕГО ЛОГА РАЗОМ
      SessionLogger.instance.info("ImportService.import", log.toString());

      return ResultOr.success(null);
      
    } catch (e, st) {
      stopwatch.stop();
      log.writeln('\n❌ ========== ИМПОРТ ПРЕРВАН ==========');
      log.writeln('❌ Ошибка: $e');
      log.writeln('📍 Стэк: $st');
      log.writeln('⏱️ Время до ошибки: ${stopwatch.elapsedMilliseconds} мс');
      
      SessionLogger.instance.error("ImportService.import", log.toString(), error: e, stackTrace: st);
      return ResultOr.error(ErrorKeys.failedToImport);
      
    } finally {
      if (tempDir != null && await tempDir.exists()) {
        final fileCount = await tempDir.list().length;
        await tempDir.delete(recursive: true);
        SessionLogger.instance.info("ImportService.import", "'🧹 Временная папка удалена: ${tempDir.path} ($fileCount файлов)'");
      }
    }
  }
}