import 'dart:ui' show Color;

import 'package:my_documents/src/utils/theme/theme.dart';

part 'document_version.dart';
part 'document_extension.dart';
part 'document_status.dart';

class Document {
  final int id;
  final String title;
  final int? folderId;
  final bool isFavorite;
  final DateTime createdAt;
  final int currentVersionId;
  final List<DocumentVersion> versions;

  Document({
    required this.id,
    required this.title,
    this.folderId,
    this.isFavorite = false,
    required this.currentVersionId,
    required this.createdAt,
    required this.versions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'folderId': folderId,
      'isFavorite': isFavorite ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'currentVersionId': currentVersionId,
    };
  }

  factory Document.fromMap(
    Map<String, dynamic> map, {
    List<DocumentVersion> versions = const [],
  }) {
    return Document(
      id: map['id'] as int,
      title: map['title'] as String,
      folderId: map['folderId'] as int?,
      isFavorite: (map['isFavorite'] as int) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      currentVersionId: map['currentVersionId'] as int,
      versions: versions,
    );
  }
  @override
  String toString() => """
  Document(
    id: $id,
    title: $title,
    folderId: $folderId,
    isFavorite: $isFavorite,
    createdAt: $createdAt,
    currentVersionId: $currentVersionId,
    versions: ${versions.map((e) => e.id).toList()},
  )
""";

  Document copyWith({
    int? id,
    String? title,
    int? folderId,
    bool? isFavorite,
    DateTime? createdAt,
    int? currentVersionId,
    List<DocumentVersion>? versions,
  }) {
    return Document(
      id: id ?? this.id,
      title: title ?? this.title,
      folderId: switch (folderId) {
        null => this.folderId,
        -3 => null,
        _ => folderId,
      },
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      currentVersionId: currentVersionId ?? this.currentVersionId,
      versions: versions ?? this.versions,
    );
  }
}
