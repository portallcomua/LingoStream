enum LearningDirection {
  englishToUkrainian,
  ukrainianToEnglish,
}

class AppSettings {
  final LearningDirection direction;
  final bool proEnabled;
  final bool adsEnabled;

  const AppSettings({
    required this.direction,
    required this.proEnabled,
    required this.adsEnabled,
  });

  factory AppSettings.defaults() {
    return const AppSettings(
      direction: LearningDirection.englishToUkrainian,
      proEnabled: false,
      adsEnabled: true,
    );
  }

  AppSettings copyWith({
    LearningDirection? direction,
    bool? proEnabled,
    bool? adsEnabled,
  }) {
    return AppSettings(
      direction: direction ?? this.direction,
      proEnabled: proEnabled ?? this.proEnabled,
      adsEnabled: adsEnabled ?? this.adsEnabled,
    );
  }
}
