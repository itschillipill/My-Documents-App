import 'dart:io' show Platform;

import 'package:my_documents/src/app/data/services/document_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:my_documents/src/app/features/documents/model/document.dart';
import 'package:my_documents/src/app/features/folders/model/folder.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    show databaseFactoryFfi, sqfliteFfiInit;
import 'data_sourse.dart';
import 'services/folder_service.dart';

class LocalDataSource implements DataSource {
  static Database? _db;
  late DocumentService _documentService;
  late FolderService _folderService;

  @override
  Future<void> init() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, 'my_documents.db');

    _db = await openDatabase(path, version: 1, onCreate: _onCreate);

    _documentService = DocumentService(_db);
    _folderService = FolderService(_db);
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE folders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE documents(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        folderId INTEGER,
        isFavorite INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        currentVersionId INTEGER NOT NULL,
        FOREIGN KEY(folderId) REFERENCES folders(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE document_versions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        documentId INTEGER NOT NULL,
        filePath TEXT NOT NULL,
        uploadedAt TEXT NOT NULL,
        comment TEXT,
        expirationDate TEXT,
        FOREIGN KEY(documentId) REFERENCES documents(id)
      )
    ''');
  }

  @override
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  @override
  Future<List<Document>> getAllDocuments() =>
      _documentService.getAllDocuments();

  @override
  Future<Document?> getDocumentById(int id) =>
      _documentService.getDocumentById(id);

  @override
  Future<int> insertDocument(Document document) =>
      _documentService.insertDocument(document);

  @override
  Future<int> addNewVersion(int documentId, DocumentVersion version) =>
      _documentService.addNewVersion(documentId, version);

  @override
  Future<void> updateDocument(Document document) =>
      _documentService.updateDocument(document);

  @override
  Future<bool> deleteDocument(int id) => _documentService.deleteDocument(id);

  @override
  Future<DocumentVersion?> getDocumentVersionByDocumentId(int documentId) =>
      _documentService.getDocumentVersionByDocumentId(documentId);

  @override
  Future<List<Folder>> getAllFolders() => _folderService.getAllFolders();

  @override
  Future<int> insertFolder(Folder folder) =>
      _folderService.insertFolder(folder);

  @override
  Future<void> updateFolder(Folder folder) =>
      _folderService.updateFolder(folder);

  @override
  Future<void> deleteFolder(int id) => _folderService.deleteFolder(id);
}
