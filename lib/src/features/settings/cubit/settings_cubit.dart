import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/core/constants.dart';
import 'package:my_documents/src/utils/sevices/observer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final ThemeMode themeMode;
  final bool useBiometrics;
  final Locale locale;
  final bool isFurstLaunch;

  SettingsState({
    required this.themeMode,
    required this.useBiometrics,
    required this.isFurstLaunch,
    this.locale = Constants.defaultLocale,
  });

  factory SettingsState.initial() => SettingsState(
    themeMode: ThemeMode.system,
    useBiometrics: false,
    isFurstLaunch: true,
    locale: Constants.defaultLocale,
  );

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? useBiometrics,
    Locale? locale,
    bool? isFurstLaunch,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      useBiometrics: useBiometrics ?? this.useBiometrics,
      locale: locale ?? this.locale,
      isFurstLaunch: isFurstLaunch ?? this.isFurstLaunch,
    );
  }
}

class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences prefs;
  final bool canUseBiometrics;
  SettingsCubit({required this.canUseBiometrics, required this.prefs})
    : super(SettingsState.initial()) {
    MyClassObserver.instance.onCreate(name);
    loadSettings();
  }
  static const name = 'SettingsCubit';

  @override
  Future<void> close() {
    MyClassObserver.instance.onClose(name);
    return super.close();
  }

  Future<void> loadSettings() async {
    final themeIndex =
        prefs.getInt(Constants.themeModeKey) ?? ThemeMode.system.index;
    final biometrics = prefs.getBool(Constants.useBiometricsKey) ?? false;
    final languageCode =
        prefs.getString(Constants.localeKey) ??
        Constants.defaultLocale.languageCode;
    final isFurstLaunch = prefs.getBool(Constants.isFirstLaunchKey) ?? true;
    emit(
      SettingsState(
        themeMode: ThemeMode.values[themeIndex],
        useBiometrics: biometrics,
        locale: Locale(languageCode),
        isFurstLaunch: isFurstLaunch,
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

  Future<void> changeFirstLaunch() async {
    await prefs.setBool(Constants.isFirstLaunchKey, false);
    emit(state.copyWith(isFurstLaunch: false));
  }

  Future<void> resetFirstLaunch() async {
    await prefs.setBool(Constants.isFirstLaunchKey, true);
    emit(state.copyWith(isFurstLaunch: true));
  }
}
