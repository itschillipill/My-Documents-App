part of 'document.dart';

extension DocumentExtensions on Document {
  DocumentVersion get currentVersion => versions.firstWhere(
    (v) => v.id == currentVersionId,
    orElse: () => versions.first,
  );

  DocumentStatus get status => currentVersion.status;

  DateTime? get expirationDate => currentVersion.expirationDate;

  DateTime get uploadDate => versions.first.uploadedAt;
}

extension DocumentVersionExtensions on DocumentVersion {
  bool get isExpired =>
      expirationDate != null && expirationDate!.isBefore(DateTime.now());

  bool get isExpiringSoon {
    if (expirationDate == null) return false;
    final now = DateTime.now();
    return expirationDate!.isAfter(now) &&
        expirationDate!.isBefore(now.add(const Duration(days: 30)));
  }

  DocumentStatus get status {
    if (isExpired) return DocumentStatus.expired;
    if (isExpiringSoon) return DocumentStatus.expiring;
    return DocumentStatus.functioning;
  }
}
