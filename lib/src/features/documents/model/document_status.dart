part of 'document.dart';

enum DocumentStatus {
  functioning,
  expiring,
  expired;

  Color get color {
    switch (this) {
      case DocumentStatus.functioning:
        return Colors.indigo;
      case DocumentStatus.expiring:
        return Colors.red;
      case DocumentStatus.expired:
        return Colors.redAccent.shade700;
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
    }
  }
}
