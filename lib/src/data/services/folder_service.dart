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

  Future<Folder> insertFolder(Folder folder) async {
  final id = await _db!.insert('folders', {'name': folder.name});
  return folder.copyWith(id: id);
}


 Future<Folder> updateFolder(Folder folder) async {
  final count = await _db?.update(
    'folders',
    {'name': folder.name},
    where: 'id = ?',
    whereArgs: [folder.id],
  );

  if (count == 0) throw Exception('Could not update folder'); 
  return folder; 
}


  Future<bool> deleteFolder(int id) async {
  if (_db == null) return false;

  try {
    await _db.update(
      'documents',
      {'folderId': null},
      where: 'folderId = ?',
      whereArgs: [id],
    );

    final count = await _db.delete('folders', where: 'id = ?', whereArgs: [id]);

    return count > 0; 
  } catch (e) {
    debugPrint("Error deleting folder: $e");
    return false;
  }
}

}
