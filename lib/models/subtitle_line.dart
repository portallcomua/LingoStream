class SubtitleLine {
  final int index;
  final Duration start;
  final Duration end;
  final String text;

  const SubtitleLine({
    required this.index,
    required this.start,
    required this.end,
    required this.text,
  });
}
