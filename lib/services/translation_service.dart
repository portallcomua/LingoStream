import '../models/app_settings.dart';

class TranslationService {
  String translate(String text, LearningDirection direction) {
    final clean = text.trim();

    if (clean.isEmpty) return '';

    if (direction == LearningDirection.englishToUkrainian) {
      return _enToUk(clean);
    }

    return _ukToEn(clean);
  }

  String _enToUk(String text) {
    final dictionary = {
      'hello': 'привіт',
      'friend': 'друг',
      'movie': 'фільм',
      'music': 'музика',
      'learn': 'вивчати',
      'english': 'англійська',
      'interesting': 'цікавий',
      'love': 'любов',
      'world': 'світ',
      'life': 'життя',
    };

    final lower = text.toLowerCase();
    for (final entry in dictionary.entries) {
      if (lower.contains(entry.key)) {
        return 'Переклад частково: ${entry.value}';
      }
    }

    return 'Переклад буде додано в наступній версії: $text';
  }

  String _ukToEn(String text) {
    final dictionary = {
      'привіт': 'hello',
      'друг': 'friend',
      'фільм': 'movie',
      'музика': 'music',
      'вивчати': 'learn',
      'англійська': 'English',
      'цікавий': 'interesting',
      'любов': 'love',
      'світ': 'world',
      'життя': 'life',
    };

    final lower = text.toLowerCase();
    for (final entry in dictionary.entries) {
      if (lower.contains(entry.key)) {
        return 'Partial translation: ${entry.value}';
      }
    }

    return 'Translation will be added in next version: $text';
  }
}
