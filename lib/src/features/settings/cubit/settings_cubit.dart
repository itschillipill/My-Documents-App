import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/core/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final ThemeMode themeMode;
  final bool useBiometrics;
  final Locale locale;

  SettingsState({
    required this.themeMode,
    required this.useBiometrics,
    this.locale = Constants.defaultLocale,
  });

  factory SettingsState.initial() => SettingsState(
    themeMode: ThemeMode.system,
    useBiometrics: false,
    locale: Constants.defaultLocale,
  );

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? useBiometrics,
    Locale? locale,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      useBiometrics: useBiometrics ?? this.useBiometrics,
      locale: locale ?? this.locale,
    );
  }
}

class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences prefs;
  final bool canUseBiometrics;
  SettingsCubit({required this.canUseBiometrics, required this.prefs})
    : super(SettingsState.initial()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final themeIndex =
        prefs.getInt(Constants.themeModeKey) ?? ThemeMode.system.index;
    final biometrics = prefs.getBool(Constants.useBiometricsKey) ?? false;
    final languageCode =
        prefs.getString(Constants.localeKey) ??
        Constants.defaultLocale.languageCode;

    emit(
      SettingsState(
        themeMode: ThemeMode.values[themeIndex],
        useBiometrics: biometrics,
        locale: Locale(languageCode),
      ),
    );
  }

  Future<void> changeThemeMode(ThemeMode themeMode) async {
    await prefs.setInt(Constants.themeModeKey, themeMode.index);
    emit(state.copyWith(themeMode: themeMode));
  }

  Future<void> changeBiometricAuthentication(bool useBiometrics) async {
    await prefs.setBool(Constants.useBiometricsKey, useBiometrics);
    emit(state.copyWith(useBiometrics: useBiometrics));
  }

  Future<void> changeLocale(Locale locale) async {
    await prefs.setString(Constants.localeKey, locale.languageCode);
    emit(state.copyWith(locale: locale));
  }
}
