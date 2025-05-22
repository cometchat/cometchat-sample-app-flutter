import 'package:shared_preferences/shared_preferences.dart';

class BoolSingleton {
  BoolSingleton._internal();
  static final BoolSingleton _instance = BoolSingleton._internal();
  factory BoolSingleton() => _instance;

  bool _value = false;

  bool get value => _value;

  // Synchronous setter (no await)
  set value(bool newValue) {
    _value = newValue;
    _saveToPrefs(newValue); // Fire and forget
  }

  // Preferred async method for setting and persisting
  Future<void> setValue(bool newValue) async {
    _value = newValue;
    await _saveToPrefs(newValue);
  }

  Future<void> _saveToPrefs(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('singleton_value', val);
  }

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _value = prefs.getBool('singleton_value') ?? false;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('singleton_value');
    _value = false;
  }
}
