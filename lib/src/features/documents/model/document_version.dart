part of 'document.dart';

class DocumentVersion {
  final int id;
  final int documentId;
  final String filePath;
  final DateTime uploadedAt;
  final String? comment;
  final DateTime? expirationDate;

  DocumentVersion({
    required this.id,
    required this.documentId,
    required this.filePath,
    required this.uploadedAt,
    this.comment,
    this.expirationDate,
  });

  Map<String, dynamic> toMap({bool includeId = true}) {
    return {
      if (includeId) 'id': id,
      'documentId': documentId,
      'filePath': filePath,
      'uploadedAt': uploadedAt.toIso8601String(),
      'comment': comment,
      'expirationDate': expirationDate?.toIso8601String(),
    };
  }

  factory DocumentVersion.fromMap(Map<String, dynamic> map) => switch (map) {
    {
      'id': int id,
      'documentId': int documentId,
      'filePath': String filePath,
      'uploadedAt': String uploadedAt,
      'comment': String? comment,
      'expirationDate': String? expirationDate,
    } =>
      DocumentVersion(
        id: id,
        documentId: documentId,
        filePath: filePath,
        uploadedAt: DateTime.parse(uploadedAt),
        comment: comment,
        expirationDate: DateTime.tryParse(expirationDate ?? ''),
      ),
    _ => throw ArgumentError('Invalid map format'),
  };

  DocumentVersion copyWith({
    int? id,
    int? documentId,
    String? filePath,
    DateTime? uploadedAt,
    String? comment,
    DateTime? expirationDate,
  }) => DocumentVersion(
    id: id ?? this.id,
    documentId: documentId ?? this.documentId,
    filePath: filePath ?? this.filePath,
    uploadedAt: uploadedAt ?? this.uploadedAt,
    comment: comment ?? this.comment,
    expirationDate: expirationDate ?? this.expirationDate,
  );

  bool get isImage =>
      filePath.endsWith(".jpg") ||
      filePath.endsWith(".jpeg") ||
      filePath.endsWith(".png");


  @override
  String toString() => "DocumentVersion(id: $id, documentId: $documentId, filePath: $filePath, uploadedAt: $uploadedAt, comment: $comment, expirationDate: $expirationDate)";
}