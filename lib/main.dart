import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'models/subtitle_line.dart';
import 'services/dictionary_store.dart';
import 'services/srt_parser.dart';

void main() {
  runApp(const LingoStreamApp());
}

class LingoStreamApp extends StatelessWidget {
  const LingoStreamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LingoStream',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xff0d0d0d),
        colorScheme: const ColorScheme.dark(
          primary: Colors.cyanAccent,
          secondary: Colors.purpleAccent,
        ),
      ),
      home: const LingoHomePage(),
    );
  }
}

class LingoHomePage extends StatefulWidget {
  const LingoHomePage({super.key});

  @override
  State<LingoHomePage> createState() => _LingoHomePageState();
}

class _LingoHomePageState extends State<LingoHomePage> {
  final DictionaryStore dictionaryStore = DictionaryStore();

  List<SubtitleLine> subtitles = [];
  List<String> dictionary = [];

  Timer? timer;
  Duration position = Duration.zero;
  bool isPlaying = false;

  Offset bubbleOffset = const Offset(20, 180);

  @override
  void initState() {
    super.initState();
    loadDictionary();
  }

  Future<void> loadDictionary() async {
    final words = await dictionaryStore.load();
    setState(() => dictionary = words);
  }

  Future<void> pickSrtFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['srt'],
      withData: true,
    );

    if (result == null || result.files.single.bytes == null) return;

    final bytes = result.files.single.bytes!;
    final content = utf8.decode(bytes, allowMalformed: true);
    final parsed = SrtParser.parse(content);

    setState(() {
      subtitles = parsed;
      position = Duration.zero;
      isPlaying = false;
    });

    stopTimer();
  }

  void togglePlay() {
    if (subtitles.isEmpty) return;

    setState(() => isPlaying = !isPlaying);

    if (isPlaying) {
      timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
        setState(() {
          position += const Duration(milliseconds: 500);
        });
      });
    } else {
      stopTimer();
    }
  }

  void stopTimer() {
    timer?.cancel();
    timer = null;
  }

  SubtitleLine? get currentLine {
    for (final line in subtitles) {
      if (position >= line.start && position <= line.end) {
        return line;
      }
    }
    return null;
  }

  String translatePlaceholder(String text) {
    if (text.trim().isEmpty) return '';
    return 'Переклад: $text';
  }

  Future<void> addCurrentToDictionary() async {
    final line = currentLine;
    if (line == null) return;

    await dictionaryStore.add(line.text);
    await loadDictionary();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Додано в словник')),
    );
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final line = currentLine;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🛸 LingoStream'),
        backgroundColor: const Color(0xff141414),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: pickSrtFile,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Вибрати .srt субтитри'),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: togglePlay,
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  label: Text(isPlaying ? 'Пауза' : 'Старт караоке'),
                ),
                const SizedBox(height: 12),
                Text(
                  'Час: ${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Словник:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: dictionary.isEmpty
                      ? const Center(
                          child: Text(
                            'Поки словник порожній',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: dictionary.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: const Icon(Icons.bookmark),
                              title: Text(dictionary[index]),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          Positioned(
            left: bubbleOffset.dx,
            top: bubbleOffset.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  bubbleOffset += details.delta;
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width - 40,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.82),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.cyanAccent, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.25),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      line?.text ?? 'Тут буде англійський текст як караоке',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      line == null
                          ? 'Завантаж .srt і натисни Старт'
                          : translatePlaceholder(line.text),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.cyanAccent,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: line == null ? null : addCurrentToDictionary,
                      icon: const Icon(Icons.add),
                      label: const Text('В словник'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
