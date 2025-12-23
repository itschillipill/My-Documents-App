import '../../documents/model/document.dart';

class Folder {
  final int id;
  final String name;

  const Folder({required this.id, required this.name});

  // Константные виртуальные папки
  static const Folder allFolder = Folder(id: -1, name: "All");
  static const Folder warningFolder = Folder(
    id: -2,
    name: "Expiring Documents",
  );
  static const Folder noFolder = Folder(id: -3, name: "No Folder");

  bool get isVirtual => id < 0;

  List<Document> getDocuments(List<Document> documents) {
    switch (id) {
      case -1:
        return documents; // Все
      case -2:
        return documents
            .where(
              (e) =>
                  e.status == DocumentStatus.expired ||
                  e.status == DocumentStatus.expairing,
            )
            .toList();
      case -3:
        return documents.where((e) => e.folderId == null).toList();

      default:
        return documents.where((e) => e.folderId == id).toList();
    }
  }

  // Для SQLite
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(id: map['id'] as int, name: map['name'] as String);
  }

  Folder copyWith({String? name}) {
    return Folder(id: id, name: name ?? this.name);
  }

  @override
  String toString() => 'Folder(id: $id, name: $name)';
}
