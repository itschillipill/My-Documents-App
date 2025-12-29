part of 'document.dart';

enum DocumentStatus {
  functioning,
  expiring,
  expired,
  archivated;

  Color get color {
    switch (this) {
      case DocumentStatus.functioning:
        return Colors.indigo;
      case DocumentStatus.expiring:
        return Colors.red;
      case DocumentStatus.expired:
        return Colors.redAccent.shade700;
      case DocumentStatus.archivated:
        return Colors.grey;
    }
  }

  String localizedText(BuildContext context) {
    switch (this) {
      case DocumentStatus.functioning:
        return context.l10n.functioning;
      case DocumentStatus.expiring:
        return context.l10n.expiringSoon;
      case DocumentStatus.expired:
        return context.l10n.expired;
      case DocumentStatus.archivated:
        return context.l10n.archivated;
    }
  }
}
