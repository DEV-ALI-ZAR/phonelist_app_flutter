import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static Future<void> saveData(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    } else {
      final jsonString = jsonEncode(value);
      await prefs.setString(key, jsonString);
    }
  }

  static Future<dynamic> getData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.get(key);

    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        return decoded;
      } catch (_) {
        return value; 
      }
    }
    return value;
  }

  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
