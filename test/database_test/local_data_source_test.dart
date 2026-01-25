import 'package:flutter_test/flutter_test.dart';
import 'package:my_documents/src/database/src/local_data_source.dart';
import 'package:my_documents/src/features/documents/model/document.dart';
import 'package:my_documents/src/features/folders/model/folder.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalDataSource dataSource;
  setUp(() async {
    dataSource = LocalDataSource();
    await dataSource.init(path: inMemoryDatabasePath);
  });

  group('LocalDataSource DB tests', () {
    test('insertFolder + getAllFolders', () async {
      final folder = Folder(id: 0, name: 'Test');

      final inserted = await dataSource.insertFolder(folder);

      expect(inserted.id, isNotNull);

      final all = await dataSource.getAllFolders();

      expect(all.length, 1);
      expect(all.first.name, 'Test');
    });

    test('insertDocument + getAllDocuments', () async {
      final title = 'Doc 1';
      final folderId = 1;
      final isFavorite = true;
      final filePath = "$inMemoryDatabasePath/test.pdf";
      final comment = "This is a test document";
      final expirationDate = null;
      final doc = Document(
        id: 0,
        title: title,
        folderId: folderId,
        isFavorite: isFavorite,
        createdAt: DateTime.now(),
        currentVersionId: null,
        versions: [
          DocumentVersion(
            id: 0,
            documentId: 0,
            filePath: filePath,
            uploadedAt: DateTime.now(),
            comment: comment,
            expirationDate: expirationDate,
          ),
        ],
      );

      final inserted = await dataSource.insertDocument(doc);

      expect(inserted.id, isNotNull);

      final all = await dataSource.getAllDocuments();

      expect(all.length, 1);
      expect(all.first.title, title);
      expect(all.first.folderId, folderId);
      expect(all.first.isFavorite, isFavorite);
      expect(all.first.versions.length, 1);
      expect(all.first.versions.first.filePath, filePath);
      expect(all.first.versions.first.comment, comment);
      expect(all.first.versions.first.expirationDate, expirationDate);
      expect(all.first.currentVersionId, 1);
    });
  });
}
