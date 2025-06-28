import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_entry.dart';

class StorageService {
  static const _key = 'user_entries';

  static Future<void> saveEntries(List<UserEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = entries.map((e) => e.toJson()).toList();
    await prefs.setString(_key, json.encode(jsonList));
  }

  static Future<List<UserEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => UserEntry.fromJson(e)).toList();
  }
}
