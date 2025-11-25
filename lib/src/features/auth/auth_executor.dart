import 'package:flutter/material.dart' show ChangeNotifier, debugPrint;
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class AuthenticationExecutor extends ChangeNotifier {
  final FlutterSecureStorage prefs;

  AuthenticationExecutor(this.prefs) {
    _checkPassword();
  }

  bool _authenticated = false;
  bool hasPassword = false;
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
      debugPrint('Authentication failed: $e');
    }
    if (result == true) {
      _authenticated = true;
    } else {
      _authenticated = false;
    }
    notifyListeners();
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
    _checkPassword();
  }

  Future<void> clearPin() async {
    await prefs.delete(key: _storageKey);
    _checkPassword();
  }

  Future<void> createOrChangePin(String pin) async {
    await prefs.write(key: _storageKey, value: pin);
    _checkPassword();
  }

  Future<void> _checkPassword() async {
    hasPassword = await prefs.containsKey(key: _storageKey);
    notifyListeners();
  }
}
