class ExportDocumentVersion {
  final String file; // имя файла в ZIP
  final DateTime uploadedAt;
  final String? comment;
  final DateTime? expirationDate;
  final String hash;

  ExportDocumentVersion({
    required this.file,
    required this.uploadedAt,
    required this.hash,
    this.comment,
    this.expirationDate,
  });

  Map<String, dynamic> toJson() => {
        'file': file,
        'hash': hash,
        'uploadedAt': uploadedAt.toIso8601String(),
        'comment': comment,
        'expirationDate': expirationDate?.toIso8601String(),
      };
}
