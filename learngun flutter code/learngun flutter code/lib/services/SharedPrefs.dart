import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class prefs {
  static getString(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static setString(String key, String Value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, Value);
  }

  static getStringList(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key);
  }

  static setStringList(String key, List<String> Value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(key, Value);
  }

  static setInt(String key, int Value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(key, Value);
  }

  static getInt(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  static setJson(String key, var Value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, jsonEncode(Value));
  }

  static getJson(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return jsonDecode(prefs.getString(key) ?? "{}");
  }

  static Removeall() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static remove(String Key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(Key);
  }
}
