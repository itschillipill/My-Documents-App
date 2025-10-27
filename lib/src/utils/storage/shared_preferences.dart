import 'package:shared_preferences/shared_preferences.dart';
import 'storage.dart';

class SharedPreferencesStorage implements Storage {
  final SharedPreferences _sharedPreferences;

  SharedPreferencesStorage(this._sharedPreferences);

  Future<void> saveString(String key, String value) async {
    await _sharedPreferences.setString(key, value);
  }

  String? getString(String key) {
    return _sharedPreferences.getString(key);
  }

  Future<void> saveInt(String key, int value) async {
    await _sharedPreferences.setInt(key, value);
  }

  int? getInt(String key) {
    return _sharedPreferences.getInt(key);
  }

  Future<void> saveBool(String key, bool value) async {
    await _sharedPreferences.setBool(key, value);
  }

  bool? getBool(String key) {
    return _sharedPreferences.getBool(key);
  }

  Future<void> remove(String key) async {
    await _sharedPreferences.remove(key);
  }

  Future<void> clear() async {
    await _sharedPreferences.clear();
  }

  double? getDouble(String key) {
    return _sharedPreferences.getDouble(key);
  }

  List<String>? getListString(String key) {
    return _sharedPreferences.getStringList(key);
  }

  Future<void> saveDouble(String key, double value) async {
    await _sharedPreferences.setDouble(key, value);
  }

  Future<void> saveListString(String key, List<String> value) async {
    await _sharedPreferences.setStringList(key, value);
  }
}
