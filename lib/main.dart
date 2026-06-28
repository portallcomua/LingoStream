import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'data/content_catalog.dart';
import 'models/app_settings.dart';
import 'models/subtitle_line.dart';
import 'services/dictionary_store.dart';
import 'services/settings_store.dart';
import 'services/srt_parser.dart';
import 'services/translation_service.dart';

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
  final SettingsStore settingsStore = SettingsStore();
  final TranslationService translationService = TranslationService();

  List<SubtitleLine> subtitles = [];
  List<String> dictionary = [];

  AppSettings settings = AppSettings.defaults();

  Timer? timer;
  Duration position = Duration.zero;
  Duration subtitleOffset = Duration.zero;

  bool isPlaying = false;
  int currentTab = 0;

  Offset bubbleOffset = const Offset(18, 185);

  final TextEditingController licenseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadAll();
  }

  Future<void> loadAll() async {
    final loadedDictionary = await dictionaryStore.load();
    final loadedSettings = await settingsStore.load();

    setState(() {
      dictionary = loadedDictionary;
      settings = loadedSettings;
    });
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
      subtitleOffset = Duration.zero;
      isPlaying = false;
    });

    stopTimer();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Завантажено рядків: ${parsed.length}')),
    );
  }

  void togglePlay() {
    if (subtitles.isEmpty) {
      showMessage('Спочатку вибери .srt субтитри');
      return;
    }

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

  void resetTime() {
    setState(() {
      position = Duration.zero;
      isPlaying = false;
    });
    stopTimer();
  }

  void shiftSubtitles(int seconds) {
    setState(() {
      subtitleOffset += Duration(seconds: seconds);
    });
  }

  SubtitleLine? get currentLine {
    final effectivePosition = position + subtitleOffset;

    for (final line in subtitles) {
      if (effectivePosition >= line.start && effectivePosition <= line.end) {
        return line;
      }
    }

    return null;
  }

  Future<void> addCurrentToDictionary() async {
    final line = currentLine;
    if (line == null) return;

    await dictionaryStore.add(line.text);
    await loadAll();
    showMessage('Додано в словник');
  }

  Future<void> removeFromDictionary(String phrase) async {
    await dictionaryStore.remove(phrase);
    await loadAll();
  }

  Future<void> changeDirection(LearningDirection direction) async {
    await settingsStore.saveDirection(direction);
    await loadAll();
  }

  Future<void> activatePro() async {
    final key = licenseController.text.trim();

    if (key.length < 8) {
      showMessage('Введи ліцензійний ключ');
      return;
    }

    await settingsStore.activatePro();
    await loadAll();
    showMessage('PRO активовано. Реклама вимкнена.');
  }

  Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      showMessage('Не вдалося відкрити посилання');
    }
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String directionTitle() {
    if (settings.direction == LearningDirection.englishToUkrainian) {
      return 'Вчу англійську: EN → UA';
    }

    return 'Вчу українську: UA → EN';
  }

  String translatedText(String text) {
    return translationService.translate(text, settings.direction);
  }

  @override
  void dispose() {
    stopTimer();
    licenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      buildKaraokeScreen(),
      buildDictionaryScreen(),
      buildCatalogScreen(),
      buildSettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff141414),
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 32,
              errorBuilder: (_, __, ___) {
                return const Text('🛸', style: TextStyle(fontSize: 24));
              },
            ),
            const SizedBox(width: 10),
            const Text(
              'LingoStream',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          if (settings.proEnabled)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.workspace_premium, color: Colors.amber),
            ),
        ],
      ),
      body: screens[currentTab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTab,
        onTap: (index) => setState(() => currentTab = index),
        selectedItemColor: Colors.cyanAccent,
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xff141414),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.subtitles), label: 'Караоке'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Словник'),
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Каталог'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Налашт.'),
        ],
      ),
    );
  }

  Widget buildKaraokeScreen() {
    final line = currentLine;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildStatusCard(),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: pickSrtFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('Вибрати .srt субтитри'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: togglePlay,
                      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                      label: Text(isPlaying ? 'Пауза' : 'Старт'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: resetTime,
                    icon: const Icon(Icons.restart_alt),
                    tooltip: 'Скинути час',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => shiftSubtitles(-1),
                      child: const Text('-1 сек'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => shiftSubtitles(1),
                      child: const Text('+1 сек'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Час: ${formatDuration(position)} | Зсув: ${subtitleOffset.inSeconds} сек',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              if (settings.adsEnabled && !settings.proEnabled) buildAdPlaceholder(),
              const Spacer(),
              const Text(
                'Порада: завантаж .srt файл, натисни Старт і рухай вікно пальцем.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
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
            child: buildFloatingBubble(line),
          ),
        ),
      ],
    );
  }

  Widget buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(directionTitle(), style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Субтитрів: ${subtitles.length}'),
          Text(settings.proEnabled ? 'PRO активний' : 'Free режим'),
        ],
      ),
    );
  }

  Widget buildFloatingBubble(SubtitleLine? line) {
    return Container(
      width: MediaQuery.of(context).size.width - 36,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.86),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyanAccent, width: 1.4),
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
            line?.text ?? 'Тут буде текст як караоке',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            line == null ? 'Завантаж .srt і натисни Старт' : translatedText(line.text),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.cyanAccent),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: line == null ? null : addCurrentToDictionary,
            icon: const Icon(Icons.add),
            label: const Text('В словник'),
          ),
        ],
      ),
    );
  }

  Widget buildDictionaryScreen() {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: dictionary.isEmpty
          ? const Center(
              child: Text(
                'Словник поки порожній',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: dictionary.length,
              itemBuilder: (context, index) {
                final phrase = dictionary[index];

                return Card(
                  color: const Color(0xff141414),
                  child: ListTile(
                    leading: const Icon(Icons.bookmark, color: Colors.cyanAccent),
                    title: Text(phrase),
                    subtitle: Text(translatedText(phrase)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => removeFromDictionary(phrase),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget buildCatalogScreen() {
    return ListView.builder(
      padding: const EdgeInsets.all(18),
      itemCount: contentCatalog.length,
      itemBuilder: (context, index) {
        final item = contentCatalog[index];

        return Card(
          color: const Color(0xff141414),
          child: ListTile(
            leading: const Icon(Icons.play_circle, color: Colors.purpleAccent),
            title: Text(item.title),
            subtitle: Text('${item.category} • ${item.level}'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => openUrl(item.url),
          ),
        );
      },
    );
  }

  Widget buildSettingsScreen() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Мова навчання',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        RadioListTile<LearningDirection>(
          title: const Text('Вчу англійську'),
          subtitle: const Text('Переклад з англійської на українську'),
          value: LearningDirection.englishToUkrainian,
          groupValue: settings.direction,
          onChanged: (value) {
            if (value != null) changeDirection(value);
          },
        ),
        RadioListTile<LearningDirection>(
          title: const Text('Вчу українську'),
          subtitle: const Text('Переклад з української на англійську'),
          value: LearningDirection.ukrainianToEnglish,
          groupValue: settings.direction,
          onChanged: (value) {
            if (value != null) changeDirection(value);
          },
        ),
        const Divider(height: 30),
        const Text(
          'Монетизація',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(settings.proEnabled
            ? 'PRO активовано. Реклама вимкнена.'
            : 'Free режим: базові функції + місце під рекламу. PRO через Payhip буде підключено наступним етапом.'),
        const SizedBox(height: 12),
        TextField(
          controller: licenseController,
          decoration: const InputDecoration(
            labelText: 'Payhip / PRO ключ',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: activatePro,
          icon: const Icon(Icons.workspace_premium),
          label: const Text('Активувати PRO'),
        ),
        const Divider(height: 30),
        const Text(
          'Google Play підготовка',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Потрібно буде додати: іконку 512x512, скріншоти, privacy policy, опис UA/EN, Data Safety. Основа вже готується.',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget buildAdPlaceholder() {
    return Container(
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: const Text(
        'Місце під рекламу',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
