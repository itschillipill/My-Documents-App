import 'dart:ui' show Locale;

class Constants {
  static const String appName = "My Documents";
  static const String appVersion = "1.0.0";
  static const String appRuStoreLink = "";
  static const supportedLocales = [Locale('en'), Locale('ru')];
  static const defaultLocale = Locale('en');

  // keys
  static const localeKey = "language_code";
  static const themeModeKey = "themeMode";
  static const useBiometricsKey = "useBiometrics";
  static const isFirstLaunchKey = 'auth_key';
}
