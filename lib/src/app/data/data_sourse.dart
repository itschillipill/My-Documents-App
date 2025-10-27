import '../features/documents/model/document.dart';
import '../features/folders/model/folder.dart';

abstract class DataSource {
  Future<void> init();
  Future<void> close();

  // CRUD для документов
  Future<List<Document>> getAllDocuments();
  Future<Document?> getDocumentById(int id);
  Future<int> insertDocument(Document document);
  Future<void> updateDocument(Document document);
  Future<void> deleteDocument(int id);
  Future<int> addNewVersion(int documentId, DocumentVersion version);
  Future<DocumentVersion?> getDocumentVersionByDocumentId(int documentId);

  // CRUD для папок
  Future<List<Folder>> getAllFolders();
  Future<int> insertFolder(Folder folder);
  Future<void> updateFolder(Folder folder);
  Future<void> deleteFolder(int id);
}
