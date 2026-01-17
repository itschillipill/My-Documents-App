import 'export_document_version.dart';

class ExportDocument {
  final String uuid; // стабильный id для экспорта
  final String title;
  final bool isFavorite;
  final DateTime createdAt;
  final int currentVersionIndex;
  final List<ExportDocumentVersion> versions;

  ExportDocument({
    required this.uuid,
    required this.title,
    required this.isFavorite,
    required this.createdAt,
    required this.currentVersionIndex,
    required this.versions,
  });

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'title': title,
    'isFavorite': isFavorite,
    'createdAt': createdAt.toIso8601String(),
    'currentVersionIndex': currentVersionIndex,
    'versions': versions.map((v) => v.toJson()).toList(),
  };
}
