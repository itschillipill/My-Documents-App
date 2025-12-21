part of 'document.dart';

extension DocumentExtensions on Document {
  DocumentVersion get currentVersion => versions.firstWhere(
    (v) => v.id == currentVersionId,
    orElse: () => versions.first,
  );

  DocumentStatus get status {
    if (currentVersion.isExpired) return DocumentStatus.expired;
    if (currentVersion.isExpiringSoon) return DocumentStatus.expairing;
    return DocumentStatus.functionating;
  }
}

extension DocumentVersionExtensions on DocumentVersion {
  bool get isExpired =>
      expirationDate != null && expirationDate!.isBefore(DateTime.now());

  bool get isExpiringSoon {
    if (expirationDate == null) return false;
    final now = DateTime.now();
    return expirationDate!.isAfter(now) &&
        expirationDate!.isBefore(now.add(const Duration(days: 15)));
  }
}
