import 'package:flutter/material.dart';

Widget buildDictionaryView(String title) {
  return Padding(
    padding: const EdgeInsets.all(20.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        const Expanded(child: Center(child: Text('Тут будуть ваші слова з фільмів та пісень', style: TextStyle(color: Colors.grey)))),
      ],
    ),
  );
}

Widget buildPremiumView(String title, String desc, String btn, TextEditingController ctrl, VoidCallback onAction) {
  return Padding(
    padding: const EdgeInsets.all(20.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
        const SizedBox(height: 15),
        Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.4)),
        const SizedBox(height: 30),
        TextField(
          controller: ctrl,
          decoration: InputDecoration(filled: true, fillColor: const Color(0xff141414), hintText: 'XXXX-XXXX-XXXX-XXXX'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent),
          onPressed: onAction,
          child: Text(btn, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}

