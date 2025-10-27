part of 'document.dart';

extension DocumentExtensions on Document {
  DocumentVersion get currentVersion => versions.firstWhere(
    (v) => v.id == currentVersionId,
    orElse: () => versions.first,
  );

  bool get isExpired =>
      currentVersion.expirationDate != null &&
      currentVersion.expirationDate!.isBefore(DateTime.now());

  bool get isExpiringSoon {
    if (currentVersion.expirationDate == null) return false;
    final now = DateTime.now();
    return currentVersion.expirationDate!.isAfter(now) &&
        currentVersion.expirationDate!.isBefore(
          now.add(const Duration(days: 15)),
        );
  }

  DocumentStatus get status {
    if (isExpired) return DocumentStatus.expaired;
    if (isExpiringSoon) return DocumentStatus.expairing;
    return DocumentStatus.functionating;
  }
}
