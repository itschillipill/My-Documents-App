import 'package:flutter/material.dart' show ChangeNotifier, debugPrint;
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationExecutor extends ChangeNotifier {
  final SharedPreferences prefs;

  AuthenticationExecutor(this.prefs);

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
  //TODO: Change savig password method

  Future<bool> authenticateByPIN(String pin) async {
    authenticated = await verefyPin(pin);
    return authenticated;
  }

  Future<bool> verefyPin(String pin) async {
    return prefs.getString(_storageKey) == pin;
  }

  Future<void> savePin(String pin) async {
    await prefs.setString(_storageKey, pin);
  }

  Future<void> clearPin() async {
    await prefs.remove(_storageKey);
  }

  Future<void> createOrChangePin(String pin) async {
    await prefs.setString(_storageKey, pin);
    notifyListeners();
  }

  bool get hasPassword => prefs.containsKey(_storageKey);
}
