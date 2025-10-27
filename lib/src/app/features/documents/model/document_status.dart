part of 'document.dart';

enum DocumentStatus {
  functionating(color: AppPalette.secondaryColor, statusText: "Functionating"),
  expairing(color: AppPalette.warningColor, statusText: "Expiring soon"),
  expaired(color: AppPalette.errorColor, statusText: "Expired");

  final Color color;
  final String statusText;
  const DocumentStatus({required this.color, required this.statusText});
}
