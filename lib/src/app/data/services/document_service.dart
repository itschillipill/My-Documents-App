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

  Future<int> insertDocument(Document document) async {
    final documentId = await _db!.insert('documents', {
      'title': document.title,
      'folderId': document.folderId,
      'isFavorite': document.isFavorite ? 1 : 0,
      'createdAt': document.createdAt.toIso8601String(),
      'currentVersionId': 0,
    });

    int? firstVersionId;

    for (final version in document.versions) {
      final versionId = await _db.insert('document_versions', {
        'documentId': documentId,
        'filePath': version.filePath,
        'uploadedAt': version.uploadedAt.toIso8601String(),
        'comment': version.comment,
        'expirationDate': version.expirationDate?.toIso8601String(),
      });

      firstVersionId ??= versionId;
    }

    if (firstVersionId != null) {
      await _db.update(
        'documents',
        {'currentVersionId': firstVersionId},
        where: 'id = ?',
        whereArgs: [documentId],
      );
    }

    return documentId;
  }

  Future<int> addNewVersion(int documentId, DocumentVersion version) async {
    final versionId = await _db!.insert('document_versions', {
      'documentId': documentId,
      'filePath': version.filePath,
      'uploadedAt': version.uploadedAt.toIso8601String(),
      'comment': version.comment,
      'expirationDate': version.expirationDate?.toIso8601String(),
    });
    await _db.update(
      'documents',
      {'currentVersionId': versionId},
      where: 'id = ?',
      whereArgs: [documentId],
    );

    return versionId;
  }

  Future<void> updateDocument(Document document) async {
    await _db!.update(
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
  }

  Future<void> deleteDocument(int id) async {
    await _db!.delete(
      'document_versions',
      where: 'documentId = ?',
      whereArgs: [id],
    );
    await _db.delete('documents', where: 'id = ?', whereArgs: [id]);
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
