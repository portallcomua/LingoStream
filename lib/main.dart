
import 'package:flutter/material.dart';
import 'dart:ui';

void main() {
  runApp(const LingoStreamApp());
}

class LingoStreamApp extends StatelessWidget {
  const LingoStreamApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Автоматично визначаємо мову системи (якщо українська - вмикаємо її, інакше - англійська)
    final String systemLocale = PlatformDispatcher.instance.locale.languageCode;
    final String defaultLang = systemLocale == 'uk' ? 'UK' : 'EN';

    return MaterialApp(
      title: 'LingoStream AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xff0d0d0d),
        colorScheme: const ColorScheme.dark(
          primary: Colors.cyanAccent,
          secondary: Colors.purpleAccent,
        ),
      ),
      home: MainDashboard(initialLanguage: defaultLang),
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
  int freeMinutesLeft = 30; // Безкоштовний ліміт для прогріву клієнта
  String selectedMode = 'movie'; // за замовчуванням режим Кіно
  
  final TextEditingController _licenseController = TextEditingController();

  // Локалізація текстів (UA та EN)
  final Map<String, Map<String, String>> localizedText = {
    'UK': {
      'status_on': 'Перекладач: ПРАЦЮЄ',
      'status_off': 'Перекладач: ВИМКНЕНО',
      'start': 'СТАРТ',
      'stop': 'СТОП',
      'mode_title': 'Оберіть режим оптимізації ШІ:',
      'mode_movie': 'Кіно & Серіали',
      'mode_pop': 'Поп-музика (Чітка мова)',
      'mode_rock': 'Рок-музика (Важкий вокал)',
      'free_limit': 'Залишилося безкоштовного ШІ-голосу:',
      'min': 'хв',
      'premium_title': 'Активація Premium (Payhip)',
      'premium_desc': 'Введіть ліцензійний ключ, отриманий після оплати, щоб вимкнути ліміти та відкрити режим Рок.',
      'btn_activate': 'АКТИВУВАТИ ПРЕМІУМ',
      'dict_title': 'Мій Словник LingoStream',
    },
    'EN': {
      'status_on': 'Translator: RUNNING',
      'status_off': 'Translator: OFF',
      'start': 'START',
      'stop': 'STOP',
      'mode_title': 'Select AI Optimization Mode:',
      'mode_movie': 'Movies & Series',
      'mode_pop': 'Pop Music (Clear Vocals)',
      'mode_rock': 'Rock Music (Heavy Vocals)',
      'free_limit': 'Remaining Free AI Voice:',
      'min': 'min',
      'premium_title': 'Activate Premium (Payhip)',
      'premium_desc': 'Enter the license key received after payment to remove limits and unlock Rock mode.',
      'btn_activate': 'ACTIVATE PREMIUM',
      'dict_title': 'My LingoStream Dictionary',
    }
  };

  @override
  void initState() {
    super.initState();
    currentLanguage = widget.initialLanguage;
  }

  String t(String key) => localizedText[currentLanguage]?[key] ?? key;

  void handleServiceToggle() {
    setState(() {
      isServiceRunning = !isServiceRunning;
      if (isServiceRunning && !isPremium && freeMinutesLeft > 0) {
        freeMinutesLeft -= 1; // Симуляція зменшення ліміту
      }
    });
  }

  void verifyLicense() {
    if (_licenseController.text.trim().isNotEmpty) {
      setState(() {
        isPremium = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(currentLanguage == 'UK' ? 'Преміум успішно активовано! 🎸' : 'Premium successfully activated! 🎸'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛸 LingoStream AI', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        backgroundColor: const Color(0xff141414),
        actions: [
          // Кнопка швидкої зміни мови
          TextButton(
            onPressed: () {
              setState(() {
                currentLanguage = currentLanguage == 'UK' ? 'EN' : 'UK';
              });
            },
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
          _buildDictionaryScreen(),
          _buildPremiumScreen(),
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
          // Індикатор статусу
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xff141414),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isServiceRunning ? Colors.cyanAccent : Colors.transparent),
            ),
            child: Row(
              children: [
                Icon(Icons.circle, color: isServiceRunning ? Colors.greenAccent : Colors.grey, size: 14),
                const SizedBox(width: 12),
                Text(isServiceRunning ? t('status_on') : t('status_off'), style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 25),

          // Показ ліміту для безкоштовних користувачів
          if (!isPremium) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.purple.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.between,
                children: [
                  Text(t('free_limit'), style: const TextStyle(fontSize: 13, color: Colors.purpleAccent)),
                  Text('$freeMinutesLeft ${t('min')}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purpleAccent)),
                ],
              ),
            ),
            const SizedBox(height: 25),
          ],

          // Кнопка Старт/Стоп
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: handleServiceToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isServiceRunning ? Colors.redAccent.withOpacity(0.1) : Colors.cyanAccent.withOpacity(0.05),
                    border: Border.all(color: isServiceRunning ? Colors.redAccent : Colors.cyanAccent, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: isServiceRunning ? Colors.redAccent.withOpacity(0.3) : Colors.cyanAccent.withOpacity(0.2),
                        blurRadius: 15,
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(isServiceRunning ? Icons.power_settings_new : Icons.play_arrow, size: 50, color: isServiceRunning ? Colors.redAccent : Colors.cyanAccent),
                      const SizedBox(height: 8),
                      Text(isServiceRunning ? t('stop') : t('start'), style: TextStyle(fontWeight: FontWeight.bold, color: isServiceRunning ? Colors.redAccent : Colors.cyanAccent)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),

          // Вибір режимів роботи ШІ
          Text(t('mode_title'), style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 10),
          _buildModeRadio(t('mode_movie'), 'movie', Icons.movie_filter),
          _buildModeRadio(t('mode_pop'), 'pop', Icons.music_note),
          _buildModeRadio(t('mode_rock'), 'rock', Icons.album, isRock: true),
        ],
      ),
    );
  }

  Widget _buildModeRadio(String title, String value, IconData icon, {bool isRock = false}) {
    bool isSelected = selectedMode == value;
    return Card(
      color: const Color(0xff141414),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: Border.all(color: isSelected ? Colors.cyanAccent : Colors.transparent),
      ),
      child: RadioListTile(
        title: Row(
          children: [
            Icon(icon, color: isRock ? Colors.purpleAccent : Colors.cyanAccent, size: 20),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 15)),
            if (isRock && !isPremium) const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Icon(Icons.lock, size: 14, color: Colors.amber),
            )
          ],
        ),
        value: value,
        groupValue: selectedMode,
