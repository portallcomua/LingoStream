
import 'package:flutter/material.dart';
import 'dart:ui';
import 'localization.dart';
import 'tabs.dart';

void main() => runApp(const LingoStreamApp());

class LingoStreamApp extends StatelessWidget {
  const LingoStreamApp({super.key});
  @override
  Widget build(BuildContext context) {
    final String systemLocale = PlatformDispatcher.instance.locale.languageCode;
    return MaterialApp(
      title: 'LingoStream AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xff0d0d0d),
        colorScheme: const ColorScheme.dark(primary: Colors.cyanAccent, secondary: Colors.purpleAccent),
      ),
      home: MainDashboard(initialLanguage: systemLocale == 'uk' ? 'UK' : 'EN'),
    );
  }
}

class MainDashboard extends StatefulWidget {
  final String initialLanguage;
  const MainDashboard({super.key, required this.initialLanguage});
  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentTab = 0;
  late String currentLanguage;
  bool isServiceRunning = false;
  bool isPremium = false;
  int freeMinutesLeft = 30;
  String selectedMode = 'movie';
  final TextEditingController _licenseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentLanguage = widget.initialLanguage;
  }

  String t(String key) => LingoLang.data[currentLanguage]?[key] ?? key;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛸 LingoStream AI', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xff141414),
        actions: [
          TextButton(
            onPressed: () => setState(() => currentLanguage = currentLanguage == 'UK' ? 'EN' : 'UK'),
            child: Text(currentLanguage, style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
          ),
          Icon(Icons.stars, color: isPremium ? Colors.amber : Colors.grey),
          const SizedBox(width: 15),
        ],
      ),
      body: IndexedStack(
        index: _currentTab,
        children: [
          _buildMainScreen(),
          buildDictionaryView(t('dict_title')),
          buildPremiumView(t('premium_title'), t('premium_desc'), t('btn_activate'), _licenseController, () {
            if (_licenseController.text.isNotEmpty) setState(() => isPremium = true);
          }),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (index) => setState(() => _currentTab = index),
        selectedItemColor: Colors.cyanAccent,
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xff141414),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.flash_on), label: '⚡'),
          BottomNavigationBarItem(icon: Icon(Icons.g_translate), label: '📚'),
          BottomNavigationBarItem(icon: Icon(Icons.workspace_premium), label: '💎'),
        ],
      ),
    );
  }

  Widget _buildMainScreen() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(isServiceRunning ? t('status_on') : t('status_off'), style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 25),
          if (!isPremium) Text('${t('free_limit')} $freeMinutesLeft ${t('min')}'),
          Expanded(
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(35)),
                onPressed: () => setState(() => isServiceRunning = !isServiceRunning),
                child: Icon(isServiceRunning ? Icons.stop : Icons.play_arrow, size: 40),
              ),
            ),
          ),
          Text(t('mode_title'), style: const TextStyle(color: Colors.grey)),
          RadioListTile(title: Text(t('mode_movie')), value: 'movie', groupValue: selectedMode, onChanged: (v) => setState(() => selectedMode = v!)),
          RadioListTile(title: Text(t('mode_pop')), value: 'pop', groupValue: selectedMode, onChanged: (v) => setState(() => selectedMode = v!)),
          RadioListTile(title: Text(t('mode_rock')), value: 'rock', groupValue: selectedMode, onChanged: (v) {
            if (!isPremium) { setState(() => _currentTab = 2); } else { setState(() => selectedMode = v!); }
          }),
        ],
      ),
    );
  }
}
