import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class AuthenticationExecutor {
  AuthenticationExecutor(this._prefs) {
    _init();
  }

  final FlutterSecureStorage _prefs;
  final LocalAuthentication _auth = LocalAuthentication();

  static const _storageKey = 'auth_key';

  /// Есть ли сохранённый PIN
  final ValueNotifier<bool> hasPasswordNotifier = ValueNotifier<bool>(false);

  /// Пользователь аутентифицирован
  final ValueNotifier<bool> authenticatedNotifier =
      ValueNotifier<bool>(false);

  bool get hasPassword => hasPasswordNotifier.value;
  bool get authenticated => authenticatedNotifier.value;

  /// ================= INIT =================

  Future<void> _init() async {
    final exists = await _prefs.containsKey(key: _storageKey);
    hasPasswordNotifier.value = exists;
  }

  /// ================= AUTH =================

  /// ЧИСТАЯ проверка PIN (НЕ меняет состояние)
  Future<bool> verifyPin(String pin) async {
    final savedPin = await _prefs.read(key: _storageKey);
    return savedPin == pin;
  }

  /// Проверка PIN + изменение состояния
  Future<bool> authenticateByPIN(String pin) async {
    final success = await verifyPin(pin);
    authenticatedNotifier.value = success;
    return success;
  }

  Future<bool> authenticateByBiometrics({
    String reason = 'Please authenticate',
  }) async {
    bool result = false;

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

    authenticatedNotifier.value = result;
    return result;
  }

  Future<bool> get canCheckBiometrics async =>
      await _auth.canCheckBiometrics;

  /// ================= PIN =================

  Future<void> savePin(String pin) async {
    await _prefs.write(key: _storageKey, value: pin);
    await _updateHasPassword();
  }

  Future<void> createOrChangePin(String pin) async {
    await _prefs.write(key: _storageKey, value: pin);
    await _updateHasPassword();
  }

  Future<void> clearPin() async {
    await _prefs.delete(key: _storageKey);
    authenticatedNotifier.value = false;
    await _updateHasPassword();
  }

  /// ================= HELPERS =================

  Future<void> _updateHasPassword() async {
    final exists = await _prefs.containsKey(key: _storageKey);
    hasPasswordNotifier.value = exists;
  }

  /// ================= DISPOSE =================

  void dispose() {
    hasPasswordNotifier.dispose();
    authenticatedNotifier.dispose();
  }
}
