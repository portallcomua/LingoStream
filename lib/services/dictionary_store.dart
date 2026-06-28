import 'package:shared_preferences/shared_preferences.dart';

class DictionaryStore {
  static const String key = 'lingostream_dictionary';

  Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key) ?? [];
  }

  Future<void> add(String phrase) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(key) ?? [];

    if (!current.contains(phrase)) {
      current.insert(0, phrase);
      await prefs.setStringList(key, current);
    }
  }

  Future<void> remove(String phrase) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(key) ?? [];
    current.remove(phrase);
    await prefs.setStringList(key, current);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
