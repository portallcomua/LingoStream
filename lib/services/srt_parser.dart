import '../models/subtitle_line.dart';

class SrtParser {
  static List<SubtitleLine> parse(String content) {
    final normalized = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final blocks = normalized.split(RegExp(r'\n\s*\n'));

    final List<SubtitleLine> result = [];

    for (final block in blocks) {
      final parts = block.trim().split('\n');
      if (parts.length < 3) continue;

      final index = int.tryParse(parts[0].trim()) ?? result.length + 1;
      final timeParts = parts[1].split('-->');

      if (timeParts.length != 2) continue;

      final start = _parseTime(timeParts[0].trim());
      final end = _parseTime(timeParts[1].trim());

      final text = parts
          .sublist(2)
          .join(' ')
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      if (text.isNotEmpty) {
        result.add(
          SubtitleLine(
            index: index,
            start: start,
            end: end,
            text: text,
          ),
        );
      }
    }

    return result;
  }

  static Duration _parseTime(String value) {
    final clean = value.replaceAll(',', '.');
    final parts = clean.split(':');

    if (parts.length != 3) return Duration.zero;

    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    final secondsParts = parts[2].split('.');

    final seconds = int.tryParse(secondsParts[0]) ?? 0;
    final milliseconds = secondsParts.length > 1
        ? int.tryParse(secondsParts[1].padRight(3, '0').substring(0, 3)) ?? 0
        : 0;

    return Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      milliseconds: milliseconds,
    );
  }
}
