import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final ThemeMode themeMode;
  final bool useBiometrics;

  SettingsState({required this.themeMode, required this.useBiometrics});

  factory SettingsState.initial() =>
      SettingsState(themeMode: ThemeMode.system, useBiometrics: false);

  SettingsState copyWith({ThemeMode? themeMode, bool? useBiometrics}) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      useBiometrics: useBiometrics ?? this.useBiometrics,
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
    final themeIndex = prefs.getInt('themeMode') ?? ThemeMode.system.index;
    final biometrics = prefs.getBool('useBiometrics') ?? false;

    emit(
      SettingsState(
        themeMode: ThemeMode.values[themeIndex],
        useBiometrics:biometrics,
      ),
    );
  }

  Future<void> changeThemeMode(ThemeMode themeMode) async {
    await prefs.setInt('themeMode', themeMode.index);
    emit(state.copyWith(themeMode: themeMode));
  }

  Future<void> changeBiometricAuthentication(bool useBiometrics) async {
    await prefs.setBool('useBiometrics', useBiometrics);
    emit(state.copyWith(useBiometrics: useBiometrics));
  }
}
