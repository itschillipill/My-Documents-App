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
