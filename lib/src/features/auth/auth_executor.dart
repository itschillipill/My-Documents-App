import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jailbreak_root_detection/jailbreak_root_detection.dart';
import 'package:local_auth/local_auth.dart';
import 'package:crypto/crypto.dart';

class AuthenticationExecutor {
  AuthenticationExecutor(this._prefs) {
    _init();
  }

  final FlutterSecureStorage _prefs;
  final LocalAuthentication _auth = LocalAuthentication();

  static const _storageKey = 'auth_key';

  final ValueNotifier<String> securityLogNotifier = ValueNotifier<String>('');

  final ValueNotifier<bool> hasPasswordNotifier = ValueNotifier<bool>(false);

  final ValueNotifier<bool> authenticatedNotifier = ValueNotifier<bool>(false);

  bool get hasPassword => hasPasswordNotifier.value;
  bool get authenticated => authenticatedNotifier.value;

  Future<void> _init() async {
    final exists = await _prefs.containsKey(key: _storageKey);
    hasPasswordNotifier.value = exists;
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  bool _verifyPinHash(String pin, String hashed) {
    return _hashPin(pin) == hashed;
  }

  Future<bool> _isDeviceSecure() async {
    if(!(Platform.isAndroid || Platform.isIOS)) return true;
    if (await JailbreakRootDetection.instance.isJailBroken) {
      _log('Device is jailbroken/rooted');
      return false;
    }
    return true;
  }

  void _log(String message) {
    securityLogNotifier.value += '${DateTime.now()}: $message\n';
    debugPrint('[SECURITY] $message');
  }

  Future<bool> verifyPin(String pin) async {
    if (!await _isDeviceSecure()) {
      _log('PIN verification blocked on insecure device');
      return false;
    }

    final savedHashedPin = await _prefs.read(key: _storageKey);
    if (savedHashedPin == null) {
      _log('No PIN set');
      return false;
    }

    final success = _verifyPinHash(pin, savedHashedPin);
    if (!success) _log('Invalid PIN attempt');
    return success;
  }

  Future<bool> authenticateByPIN(String pin) async {
    final success = await verifyPin(pin);
    authenticatedNotifier.value = success;
    return success;
  }

  Future<bool> authenticateByBiometrics({
    String reason = 'Please authenticate',
  }) async {
    if (!await _isDeviceSecure()) {
      _log('Biometric auth blocked on insecure device');
      return false;
    }

    bool result = false;
    try {
      result = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      if (!result) _log('Biometric authentication failed');
    } catch (e) {
      _log('Biometric error: $e');
    }

    authenticatedNotifier.value = result;
    return result;
  }

  Future<bool> get canCheckBiometrics async => await _auth.canCheckBiometrics;

  Future<void> createOrChangePin(String pin) async {
    if (!await _isDeviceSecure()) {
      _log('Cannot set PIN on insecure device');
      return;
    }
    final hashed = _hashPin(pin);
    await _prefs.write(key: _storageKey, value: hashed);
    authenticatedNotifier.value = true;
    await _updateHasPassword();
  }

  Future<void> clearPin() async {
    await _prefs.delete(key: _storageKey);
    authenticatedNotifier.value = false;
    await _updateHasPassword();
  }

  Future<void> _updateHasPassword() async {
    final exists = await _prefs.containsKey(key: _storageKey);
    hasPasswordNotifier.value = exists;
  }

  void dispose() {
    hasPasswordNotifier.dispose();
    authenticatedNotifier.dispose();
    securityLogNotifier.dispose();
  }
}