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

extension DocumentExportExtension on Document {
  Future<Map<String, dynamic>> exportMap(ExportBuildContext ctx) async {
    final versions = <Map<String, dynamic>>[];
    
    for (final version in this.versions) {
      versions.add(await version.exportMap(ctx));
    }
    
    final currentIndex = this.versions.indexWhere(
      (v) => v.id == currentVersionId,
    );
    
    return {
      'token': TokenGenerator.generateToken(),
      'title': title,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'currentVersionIndex': currentIndex == -1 ? 0 : currentIndex,
      'versions': versions,
    };
  }
}

extension DocumentVersionExportExtension on DocumentVersion {
  Future<Map<String, dynamic>> exportMap(ExportBuildContext ctx) async {
    final zipFileName = await ctx.registerFile(filePath);
    
    return {
      'file': zipFileName,
      'hash': p.basenameWithoutExtension(zipFileName),
      'uploadedAt': uploadedAt.toIso8601String(),
      'comment': comment,
      'expirationDate': expirationDate?.toIso8601String(),
    };
  }
}
