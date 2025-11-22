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

  // Для SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'documentId': documentId,
      'filePath': filePath,
      'uploadedAt': uploadedAt.toIso8601String(),
      'comment': comment,
      'expirationDate': expirationDate?.toIso8601String(),
    };
  }

  factory DocumentVersion.fromMap(Map<String, dynamic> map) {
    return DocumentVersion(
      id: map['id'] as int,
      documentId: map['documentId'] as int,
      filePath: map['filePath'] as String,
      uploadedAt: DateTime.parse(map['uploadedAt'] as String),
      comment: map['comment'] as String?,
      expirationDate:
          map['expirationDate'] != null
              ? DateTime.tryParse(map['expirationDate'] as String)
              : null,
    );
  }

  bool get isImage => filePath.endsWith(".jpg") || filePath.endsWith(".jpeg") || filePath.endsWith(".png");
}
