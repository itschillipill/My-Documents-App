import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show ValueNotifier;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class AuthenticationExecutor extends ChangeNotifier {
  final FlutterSecureStorage prefs;

  AuthenticationExecutor(this.prefs) {
    _init();
  }

  final ValueNotifier<bool> hasPasswordNotifier = ValueNotifier(false);
  bool _authenticated = false;
  bool get authenticated => _authenticated;
  set authenticated(bool value) {
    _authenticated = value;
    notifyListeners();
  }

  static const _storageKey = 'auth_key';
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> get canCheckBiometrics async => await _auth.canCheckBiometrics;

  Future<bool> authenticateByBiometrics({
    String reason = "Please authenticate",
  }) async {
    bool? result;
    try {
      result = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      Clipboard.setData(ClipboardData(text: e.toString()));
    }
    authenticated = result == true;
    return authenticated;
  }

  Future<bool> authenticateByPIN(String pin) async {
    authenticated = await verefyPin(pin);
    return authenticated;
  }

  Future<bool> verefyPin(String pin) async {
    return await prefs.read(key: _storageKey) == pin;
  }

  Future<void> savePin(String pin) async {
    await prefs.write(key: _storageKey, value: pin);
    _updateHasPassword();
  }

  Future<void> clearPin() async {
    await prefs.delete(key: _storageKey);
    _updateHasPassword();
  }

  Future<void> createOrChangePin(String pin) async {
    await prefs.write(key: _storageKey, value: pin);
    _updateHasPassword();
  }

  Future<void> _init() async {
    final exists = await prefs.containsKey(key: _storageKey);
    hasPasswordNotifier.value = exists;
  }

  Future<void> _updateHasPassword() async {
    final exists = await prefs.containsKey(key: _storageKey);
    // обновляем ValueNotifier, а не напрямую hasPassword
    hasPasswordNotifier.value = exists;
  }
}
