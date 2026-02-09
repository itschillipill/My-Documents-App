import 'dart:io' show Platform;

import 'package:my_documents/src/core/app_context.dart';
import 'package:my_documents/src/core/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'package:my_documents/src/features/documents/model/document.dart';
import 'package:my_documents/src/features/folders/model/folder.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    show databaseFactoryFfi, sqfliteFfiInit;
import 'data_sourse.dart';
import 'services/document_service.dart';
import 'services/folder_service.dart';

class LocalDataSource implements DataSource {
  late Database _db;
  late final DocumentService _documentService;
  late final FolderService _folderService;

  @override
  Future<void> init({String? path}) async {
    try {
      if (!Platform.isAndroid && !Platform.isIOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      String? $path = path;
      $path ??= join(
        (await getApplicationDocumentsDirectory()).path,
        !AppContext.instance.config.isProd ? 'my_documents_debug.db' : 'my_documents.db',
      );

      _db = await openDatabase(
        $path,
        version: Constants.currentDatabaseVersion,
        onCreate: _onCreate,
        onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
        onDowngrade: _onDowngrade,
        onUpgrade: _onUpgrade,
      );
      _documentService = DocumentService(_db);
      _folderService = FolderService(_db);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  static Future<void> _onDowngrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {}

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _migrateV1ToV2(db);
    }
  }

  static Future<void> _migrateV1ToV2(Database db) async {
    await db.transaction((txn) async {
      final batch = txn.batch();

      batch.execute('ALTER TABLE documents RENAME TO documents_old;');
      batch.execute(
        'ALTER TABLE document_versions RENAME TO document_versions_old;',
      );

      batch.execute('''
      CREATE TABLE documents(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        folderId INTEGER,
        isFavorite INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        currentVersionId INTEGER,
        FOREIGN KEY(folderId) REFERENCES folders(id) ON DELETE SET NULL
      )
    ''');

      batch.execute('''
      CREATE TABLE document_versions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        documentId INTEGER NOT NULL,
        filePath TEXT NOT NULL,
        uploadedAt TEXT NOT NULL,
        comment TEXT,
        expirationDate TEXT,
        FOREIGN KEY(documentId) REFERENCES documents(id) ON DELETE CASCADE
      )
    ''');

      // чистим битые ссылки
      batch.execute('''
      UPDATE documents_old SET currentVersionId = NULL WHERE currentVersionId = 0;
    ''');

      batch.execute('''
      INSERT INTO documents (id, title, folderId, isFavorite, createdAt, currentVersionId)
      SELECT id, title, folderId, isFavorite, createdAt, currentVersionId
      FROM documents_old;
    ''');

      batch.execute('''
      INSERT INTO document_versions (id, documentId, filePath, uploadedAt, comment, expirationDate)
      SELECT id, documentId, filePath, uploadedAt, comment, expirationDate
      FROM document_versions_old;
    ''');

      batch.execute('DROP TABLE document_versions_old;');
      batch.execute('DROP TABLE documents_old;');

      await batch.commit(noResult: true, continueOnError: false);
    });
  }

  static Future<void> _onCreate(Database db, int _) async {
    final batch = db.batch();

    batch.execute('''
    CREATE TABLE folders(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
    )
  ''');

    batch.execute('''
    CREATE TABLE documents(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      folderId INTEGER,
      isFavorite INTEGER NOT NULL,
      createdAt TEXT NOT NULL,
      currentVersionId INTEGER,
      FOREIGN KEY(folderId) REFERENCES folders(id) ON DELETE SET NULL
    )
  ''');

    batch.execute('''
    CREATE TABLE document_versions(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      documentId INTEGER NOT NULL,
      filePath TEXT NOT NULL,
      uploadedAt TEXT NOT NULL,
      comment TEXT,
      expirationDate TEXT,
      FOREIGN KEY(documentId) REFERENCES documents(id) ON DELETE CASCADE
    )
  ''');

    await batch.commit();
  }

  @override
  Future<void> close() async {
    await _db.close();
  }

  @override
  Future<List<Document>> getAllDocuments() =>
      _documentService.getAllDocuments();

  @override
  Future<Document?> getDocumentById(int id) =>
      _documentService.getDocumentById(id);

  @override
  Future<Document> insertDocument(Document document) =>
      _documentService.insertDocument(document);

  @override
  Future<DocumentVersion> addNewVersion(
    int documentId,
    DocumentVersion version,
  ) => _documentService.addNewVersion(documentId, version);

  @override
  Future<bool> updateDocument(Document document) =>
      _documentService.updateDocument(document);

  @override
  Future<bool> deleteDocument(int id) => _documentService.deleteDocument(id); 
  @override
  Future<List<Document>> insertAllDocuments(List<Document> documents) =>
      _documentService.insertAllDocuments(documents);
  @override
  Future<bool> deleteDocumentsByIds(List<int> ids) =>
      _documentService.deleteDocumentsByIds(ids);

  @override
  Future<List<Folder>> getAllFolders() => _folderService.getAllFolders();

  @override
  Future<Folder> insertFolder(Folder folder) =>
      _folderService.insertFolder(folder);

  @override
  Future<Folder> updateFolder(Folder folder) =>
      _folderService.updateFolder(folder);

  @override
  Future<bool> deleteFolder(int id) => _folderService.deleteFolder(id);
}
