import '../../features/documents/model/document.dart';
import '../../features/folders/model/folder.dart';

abstract class DataSource {
  Future<void> init();
  Future<void> close();

  // CRUD для документов
  Future<List<Document>> getAllDocuments();
  Future<Document?> getDocumentById(int id);
  Future<Document> insertDocument(Document document);
  Future<bool> updateDocument(Document document);
  Future<bool> deleteDocument(int id);
  Future<bool> deleteDocumentsByIds(List<int> ids);
  Future<List<Document>> insertAllDocuments(List<Document> documents);
  Future<DocumentVersion> addNewVersion(
    int documentId,
    DocumentVersion version,
  );

  // CRUD для папок
  Future<List<Folder>> getAllFolders();
  Future<Folder> insertFolder(Folder folder);
  Future<Folder> updateFolder(Folder folder);
  Future<bool> deleteFolder(int id);
}
