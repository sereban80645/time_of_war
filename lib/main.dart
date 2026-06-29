import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_widget/home_widget.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF121212)),
      home: const TimeOfWarScreen(),
    );
  }
}

class TimeOfWarScreen extends StatefulWidget {
  const TimeOfWarScreen({super.key});
  @override
  State<TimeOfWarScreen> createState() => _TimeOfWarScreenState();
}

class _TimeOfWarScreenState extends State<TimeOfWarScreen> {
  bool _show2022 = true, _show2014 = false, _showHour = true, _showDaysOnly = false;
  double _fontSize = 22.0, _strokeWidth = 3.0, _opacity = 0.5;
  double _br = 30.0, _bg = 30.0, _bb = 30.0, _tr = 255.0, _tg = 255.0, _tb = 255.0, _sr = 0.0, _sg = 0.0, _sb = 0.0;
  String? _imagePath;

  // КОРЕКТНА ЛОГІКА РОЗРАХУНКУ
  String _calculate(DateTime start) {
    final now = DateTime.now();
    // Розрахунок поточного дня (ordinal day)
    int totalDays = now.difference(start).inDays + 1;
    int h = now.hour;

    if (_showDaysOnly) {
      return "$totalDays д." + (_showHour ? " ${h}г." : "");
    } else {
      int y = (totalDays / 365.25).floor();
      int rem = (totalDays - (y * 365.25)).round();
      int m = (rem / 30.44).floor();
      int d = (rem - (m * 30.44)).round();
      if (d < 1) d = 1;
      return "${y}р. ${m}міс. ${d}д." + (_showHour ? " ${h}г." : "");
    }
  }

  // --- Базові функції інтерфейсу залишаються стабільними ---
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _show2022 = p.getBool('show2022') ?? true;
      _show2014 = p.getBool('show2014') ?? false;
      _showDaysOnly = p.getBool('showDaysOnly') ?? false;
      _showHour = p.getBool('showHour') ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Налаштування")),
      body: ListView(children: [
        SwitchListTile(title: const Text("Облік в днях"), value: _showDaysOnly, onChanged: (v) { setState(() => _showDaysOnly = v;); }),
        SwitchListTile(title: const Text("Показ годин"), value: _showHour, onChanged: (v) { setState(() => _showHour = v;); }),
        const Divider(),
        ListTile(title: Text("Війна 2022: ${_calculate(DateTime(2022, 2, 24))}")),
      ]),
    );
  }
}
