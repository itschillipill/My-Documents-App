import 'dart:io';
import 'package:my_documents/src/utils/sevices/file_service.dart';
import 'package:path/path.dart' as p;


class ExportBuildContext {
  final Map<String, String> hashToFileName = {};
  final Directory filesDir;

  ExportBuildContext(this.filesDir);

  Future<String> registerFile(String filePath) async {
    final file = File(filePath);
    final hash = await FileService.calculateFileHash(file);

    return hashToFileName.putIfAbsent(hash, () {
      final ext = p.extension(filePath);
      final name = '$hash$ext';
      file.copySync(p.join(filesDir.path, name));
      return name;
    });
  }
  
}
