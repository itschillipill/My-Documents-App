import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../features/documents/model/document.dart';

class DocumentService {
  final Database? _db;

  DocumentService(this._db);

  Future<List<Document>> getAllDocuments() async {
    final docs = await _db!.query('documents');
    final versions = await _db.query('document_versions');

    return docs.map((doc) {
      final docVersions =
          versions
              .where((v) => v['documentId'] == doc['id'])
              .map(
                (v) => DocumentVersion(
                  id: v['id'] as int,
                  documentId: v['documentId'] as int,
                  filePath: v['filePath'] as String,
                  uploadedAt: DateTime.parse(v['uploadedAt'] as String),
                  comment: v['comment'] as String?,
                  expirationDate:
                      v['expirationDate'] != null
                          ? DateTime.tryParse(v['expirationDate'] as String)
                          : null,
                ),
              )
              .toList();

      return Document(
        id: doc['id'] as int,
        title: doc['title'] as String,
        folderId: doc['folderId'] as int?,
        isFavorite: (doc['isFavorite'] as int) == 1,
        createdAt: DateTime.parse(doc['createdAt'] as String),
        currentVersionId: doc['currentVersionId'] as int,
        versions: docVersions,
      );
    }).toList();
  }

  Future<Document?> getDocumentById(int id) async {
    final docs = await _db!.query(
      'documents',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (docs.isEmpty) return null;

    final versions = await _db.query(
      'document_versions',
      where: 'documentId = ?',
      whereArgs: [id],
    );

    return Document(
      id: docs.first['id'] as int,
      title: docs.first['title'] as String,
      folderId: docs.first['folderId'] as int?,
      isFavorite: (docs.first['isFavorite'] as int) == 1,
      createdAt: DateTime.parse(docs.first['createdAt'] as String),
      currentVersionId: docs.first['currentVersionId'] as int,
      versions:
          versions
              .map(
                (v) => DocumentVersion(
                  id: v['id'] as int,
                  documentId: v['documentId'] as int,
                  filePath: v['filePath'] as String,
                  uploadedAt: DateTime.parse(v['uploadedAt'] as String),
                  comment: v['comment'] as String?,
                  expirationDate:
                      v['expirationDate'] != null
                          ? DateTime.tryParse(v['expirationDate'] as String)
                          : null,
                ),
              )
              .toList(),
    );
  }

  Future<Document> insertDocument(Document document) async {
  // Вставляем сам документ
  final documentId = await _db!.insert('documents', {
    'title': document.title,
    'folderId': document.folderId,
    'isFavorite': document.isFavorite ? 1 : 0,
    'createdAt': document.createdAt.toIso8601String(),
    'currentVersionId': 0,
  });

  int? firstVersionId;
  List<DocumentVersion> insertedVersions = [];

  // Вставляем версии документа
  for (final version in document.versions) {
    final versionId = await _db.insert('document_versions', {
      'documentId': documentId,
      'filePath': version.filePath,
      'uploadedAt': version.uploadedAt.toIso8601String(),
      'comment': version.comment,
      'expirationDate': version.expirationDate?.toIso8601String(),
    });

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


  Future<DocumentVersion> addNewVersion(int documentId, DocumentVersion version) async {
  if (_db == null) {
    throw Exception("Database is null");
  }

  // Вставляем версию
  final versionId = await _db.insert('document_versions', {
    'documentId': documentId,
    'filePath': version.filePath,
    'uploadedAt': version.uploadedAt.toIso8601String(),
    'comment': version.comment,
    'expirationDate': version.expirationDate?.toIso8601String(),
  });

  // Обновляем currentVersionId в документе
  await _db.update(
    'documents',
    {'currentVersionId': versionId},
    where: 'id = ?',
    whereArgs: [documentId],
  );

  // Возвращаем новый объект с реальным id
  return version.copyWith(
    id: versionId,
    documentId: documentId,
  );
}

  Future<bool> updateDocument(Document document) async {
  if (_db == null) return false;

  final count = await _db.update(
    'documents',
    {
      'title': document.title,
      'folderId': document.folderId,
      'isFavorite': document.isFavorite ? 1 : 0,
      'createdAt': document.createdAt.toIso8601String(),
      'currentVersionId': document.currentVersionId,
    },
    where: 'id = ?',
    whereArgs: [document.id],
  );
  return count > 0;
}

  Future<bool> deleteDocument(int id) async {
    if (_db == null) {
      if (kDebugMode) {
        throw Exception('Database not initialized');
      } else {
        return false;
      }
    }

    return await _db.transaction((txn) async {
      await txn.delete(
        'document_versions',
        where: 'documentId = ?',
        whereArgs: [id],
      );

      final deletedCount = await txn.delete(
        'documents',
        where: 'id = ?',
        whereArgs: [id],
      );

      return deletedCount > 0;
    });
  }

  Future<bool> deleteDocumentsByIds(List<int> ids) async {
    if (_db == null) {
      if (kDebugMode) {
        throw Exception('Database not initialized');
      }
      return false;
    }

    if (ids.isEmpty) {
      return true; // нечего удалять — не ошибка
    }

    final placeholders = List.filled(ids.length, '?').join(',');

    return await _db.transaction((txn) async {
      // 1️⃣ удаляем версии
      await txn.delete(
        'document_versions',
        where: 'documentId IN ($placeholders)',
        whereArgs: ids,
      );

      // 2️⃣ удаляем документы
      final deletedCount = await txn.delete(
        'documents',
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );

      return deletedCount > 0;
    });
  }

  Future<DocumentVersion?> getDocumentVersionByDocumentId(
    int documentId,
  ) async {
    final versions = await _db?.query(
      'document_versions',
      where: 'documentId = ?',
      whereArgs: [documentId],
    );

    if (versions == null || versions.isEmpty) return null;

    return DocumentVersion(
      id: versions.first['id'] as int,
      documentId: versions.first['documentId'] as int,
      filePath: versions.first['filePath'] as String,
      uploadedAt: DateTime.parse(versions.first['uploadedAt'] as String),
      comment: versions.first['comment'] as String?,
      expirationDate:
          versions.first['expirationDate'] != null
              ? DateTime.tryParse(versions.first['expirationDate'] as String)
              : null,
    );
  }
}
