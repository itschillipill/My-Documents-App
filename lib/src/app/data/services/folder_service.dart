import 'package:flutter/foundation.dart' show debugPrint;
import 'package:sqflite/sqflite.dart';

import '../../features/folders/model/folder.dart';

class FolderService {
  final Database? _db;

  FolderService(this._db);

  Future<List<Folder>> getAllFolders() async {
    final result = await _db!.query('folders');
    return result
        .map((f) => Folder(id: f['id'] as int, name: f['name'] as String))
        .toList();
  }

  Future<int> insertFolder(Folder folder) async {
    return await _db!.insert('folders', {'name': folder.name});
  }

  Future<void> updateFolder(Folder folder) async {
    await _db!.update(
      'folders',
      {'name': folder.name},
      where: 'id = ?',
      whereArgs: [folder.id],
    );
  }

  Future<void> deleteFolder(int id) async {
   try {
      await _db?.update(
      'documents',
      {'folderId': null},
      where: 'folderId = ?',
      whereArgs: [id],
    );
    await _db?.delete('folders', where: 'id = ?', whereArgs: [id]);
   } catch (e) {
    debugPrint(e.toString());
   }
  }
}
