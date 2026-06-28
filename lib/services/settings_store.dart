import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

class SettingsStore {
  static const String directionKey = 'learning_direction';
  static const String proKey = 'pro_enabled';
  static const String adsKey = 'ads_enabled';

  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();

    final directionRaw = prefs.getString(directionKey) ?? 'en_uk';
    final proEnabled = prefs.getBool(proKey) ?? false;
    final adsEnabled = prefs.getBool(adsKey) ?? true;

    return AppSettings(
      direction: directionRaw == 'uk_en'
          ? LearningDirection.ukrainianToEnglish
          : LearningDirection.englishToUkrainian,
      proEnabled: proEnabled,
      adsEnabled: adsEnabled,
    );
  }

  Future<void> saveDirection(LearningDirection direction) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      directionKey,
      direction == LearningDirection.ukrainianToEnglish ? 'uk_en' : 'en_uk',
    );
  }

  Future<void> activatePro() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(proKey, true);
    await prefs.setBool(adsKey, false);
  }
}
