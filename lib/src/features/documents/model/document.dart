import 'package:flutter/material.dart' show BuildContext, Colors, Color;
import 'package:my_documents/src/core/extensions/extensions.dart';

part 'document_version.dart';
part 'document_extension.dart';
part 'document_status.dart';

class Document {
  final int id;
  final String title;
  final int? folderId;
  final bool isFavorite;
  final DateTime createdAt;
  final int? currentVersionId;
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

  Map<String, dynamic> toMap({bool includeId = true}) {
    return {
      if (includeId) 'id': id,
      'title': title,
      'folderId': folderId,
      'isFavorite': isFavorite ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'currentVersionId': includeId ? null : currentVersionId,
    };
  }

  factory Document.fromMap(
    Map<String, Object?> map,
    List<Map<String, Object?>> allVersions,
  ) {
    final docVersions =
        allVersions
            .where((v) => v['documentId'] == map['id'])
            .map((v) => DocumentVersion.fromMap(v))
            .toList();

    return switch (map) {
      {
        'id': int id,
        'title': String title,
        'folderId': int? folderId,
        'isFavorite': int isFavorite,
        'createdAt': String createdAt,
        'currentVersionId': int? currentVersionId,
      } =>
        Document(
          id: id,
          title: title,
          folderId: folderId,
          isFavorite: isFavorite == 1,
          createdAt: DateTime.parse(createdAt),
          currentVersionId: currentVersionId,
          versions: docVersions,
        ),
      _ => throw FormatException('Invalid Document map: $map'),
    };
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
        null || -3 => this.folderId,
        _ => folderId,
      },
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      currentVersionId: currentVersionId ?? this.currentVersionId,
      versions: versions ?? this.versions,
    );
  }
}
