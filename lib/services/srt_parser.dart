import '../models/subtitle_line.dart';

class SrtParser {
  static List<SubtitleLine> parse(String content) {
    final normalized = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final blocks = normalized.split(RegExp(r'\n\s*\n'));

    final List<SubtitleLine> lines = [];

    for (final block in blocks) {
      final parts = block.trim().split('\n');
      if (parts.length < 3) continue;

      final index = int.tryParse(parts[0].trim()) ?? lines.length + 1;
      final timeLine = parts[1];

      final timeParts = timeLine.split('-->');
      if (timeParts.length != 2) continue;

      final start = _parseTime(timeParts[0].trim());
      final end = _parseTime(timeParts[1].trim());

      final text = parts.sublist(2).join(' ').replaceAll(RegExp(r'<[^>]*>'), '').trim();

      if (text.isNotEmpty) {
        lines.add(
          SubtitleLine(
            index: index,
            start: start,
            end: end,
            text: text,
          ),
        );
      }
    }

    return lines;
  }

  static Duration _parseTime(String value) {
    final clean = value.replaceAll(',', '.');
    final parts = clean.split(':');

    if (parts.length != 3) return Duration.zero;

    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;

    final secParts = parts[2].split('.');
    final seconds = int.tryParse(secParts[0]) ?? 0;
    final milliseconds = secParts.length > 1 ? int.tryParse(secParts[1].padRight(3, '0').substring(0, 3)) ?? 0 : 0;

    return Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      milliseconds: milliseconds,
    );
  }
}
