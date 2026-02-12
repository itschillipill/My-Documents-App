import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../../features/documents/model/document.dart';

class DocumentService {
  final Database _db;

  DocumentService(this._db);

  Future<List<Document>> getAllDocuments() async {
    final docs = await _db.query('documents');
    final versions = await _db.query('document_versions');

    return docs.map((doc) => Document.fromMap(doc, versions)).toList();
  }

  Future<Document?> getDocumentById(int id) async {
    final docs = await _db.query('documents', where: 'id = ?', whereArgs: [id]);
    if (docs.isEmpty) return null;

    final versions = await _db.query(
      'document_versions',
      where: 'documentId = ?',
      whereArgs: [id],
    );
    return Document.fromMap(docs.first, versions);
  }

  Future<Document> insertDocument(Document document) async {
    assert(
      document.versions.isNotEmpty,
      "Document must have at least one version",
    );

    // Вставляем сам документ
    final documentId = await _db.insert(
      'documents',
      document.toMap(includeId: false),
    );

    int? firstVersionId;
    List<DocumentVersion> insertedVersions = [];

    // Вставляем версии документа
    for (final version in document.versions) {
      final versionId = await _db.insert(
        'document_versions',
        version.copyWith(documentId: documentId).toMap(includeId: false),
      );

      firstVersionId ??= versionId;

      // Добавляем в список с новым id
      insertedVersions.add(
        version.copyWith(id: versionId, documentId: documentId),
      );
    }

    // Обновляем currentVersionId
    if (firstVersionId != null) {
      await _db.update(
        'documents',
        {'currentVersionId': firstVersionId},
        where: 'id = ?',
        whereArgs: [documentId],
      );
    }

    // Возвращаем новый Document с id и версиями
    return document.copyWith(
      id: documentId,
      currentVersionId: firstVersionId,
      versions: insertedVersions,
    );
  }

  Future<DocumentVersion> addNewVersion(
    int documentId,
    DocumentVersion version,
  ) async {
    // Вставляем версию
    final versionId = await _db.insert(
      'document_versions',
      version.toMap(includeId: false),
    );

    // Обновляем currentVersionId в документе
    await _db.update(
      'documents',
      {'currentVersionId': versionId},
      where: 'id = ?',
      whereArgs: [documentId],
    );

    // Возвращаем новый объект с реальным id
    return version.copyWith(id: versionId, documentId: documentId);
  }

  Future<bool> updateDocument(Document document) async {
    final count = await _db.update(
      'documents',
      document.toMap(includeId: false),
      where: 'id = ?',
      whereArgs: [document.id],
    );
    return count > 0;
  }

Future<List<Document>> insertAllDocuments(List<Document> documents, {bool replace = false}) async {
  if (documents.isEmpty) return [];

  // Проверяем, что все документы имеют хотя бы одну версию
  for (final doc in documents) {
    if (doc.versions.isEmpty) {
      throw ArgumentError('Document "${doc.title}" must have at least one version');
    }
  }

  final List<Document> insertedDocuments = [];

  await _db.transaction((txn) async {
    // ================= 🗑️ ПОЛНАЯ ОЧИСТКА ПРИ replace = true =================
    if (replace) {
      debugPrint('🧹 REPLACE MODE: Полная очистка базы данных');
      
      // Важно! Сначала удаляем версии (внешний ключ), потом документы
      await txn.delete('document_versions');
      await txn.delete('documents');
      
      debugPrint('✅ База данных очищена');
    }
    
    // Map для связи временного ID с реальным ID версии
    final Map<String, int> versionIdMap = {};
    
    for (int docIndex = 0; docIndex < documents.length; docIndex++) {
      final doc = documents[docIndex];
      
      // Вставляем документ
      final documentId = await txn.insert(
        'documents',
        doc.toMap(includeId: false),
      );

      final List<DocumentVersion> insertedVersions = [];
      int? currentVersionId;

      // Вставляем версии документа
      for (int verIndex = 0; verIndex < doc.versions.length; verIndex++) {
        final version = doc.versions[verIndex];
        final versionId = await txn.insert(
          'document_versions',
          version.copyWith(documentId: documentId).toMap(includeId: false),
        );

        // Сохраняем соответствие временного ID реальному
        final tempKey = '${docIndex}_${version.id}';
        versionIdMap[tempKey] = versionId;

        final insertedVersion = version.copyWith(
          id: versionId,
          documentId: documentId,
        );
        insertedVersions.add(insertedVersion);

        // Определяем текущую версию
        if (doc.currentVersionId == version.id) {
          currentVersionId = versionId;
        }
      }

      // Если текущая версия не указана, берем первую
      currentVersionId ??= insertedVersions.isNotEmpty 
          ? insertedVersions.first.id 
          : null;

      // Обновляем currentVersionId
      if (currentVersionId != null) {
        await txn.update(
          'documents',
          {'currentVersionId': currentVersionId},
          where: 'id = ?',
          whereArgs: [documentId],
        );
      }

      insertedDocuments.add(
        doc.copyWith(
          id: documentId,
          currentVersionId: currentVersionId,
          versions: insertedVersions,
        ),
      );
    }
  });

  debugPrint('📥 Импортировано документов: ${insertedDocuments.length} (replace: $replace)');
  return insertedDocuments;
}
  Future<bool> deleteDocument(int id) async {
    try {
      final deletedCount = await _db.delete(
        'documents',
        where: 'id = ?',
        whereArgs: [id],
      );

      return deletedCount > 0;
    } catch (e) {
      debugPrint('Error deleting document $id: $e');
      return false;
    }
  }

  Future<bool> deleteDocumentsByIds(List<int> ids) async {
    if (ids.isEmpty) return true;

    final placeholders = List.filled(ids.length, '?').join(',');

    try {
      final deletedCount = await _db.delete(
        'documents',
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );

      return deletedCount > 0;
    } catch (e) {
      debugPrint('Error deleting documents $ids: $e');
      return false;
    }
  }
}
