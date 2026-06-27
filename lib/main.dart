import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:home_widget/home_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TimeOfWarApp());
}

class TimeOfWarApp extends StatelessWidget {
  const TimeOfWarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.deepPurpleAccent,
      ),
      home: const TimeOfWarHome(),
    );
  }
}

class TimeOfWarHome extends StatefulWidget {
  const TimeOfWarHome({super.key});

  @override
  State<TimeOfWarHome> createState() => _TimeOfWarHomeState();
}

class _TimeOfWarHomeState extends State<TimeOfWarHome> {
  bool _show2022 = true;
  bool _show2014 = false;
  bool _showHours = true;
  double _opacity = 0.5;
  double _fontSize = 35.0;
  bool _showSettings = false;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _show2022 = prefs.getBool('show2022') ?? true;
      _show2014 = prefs.getBool('show2014') ?? false;
      _showHours = prefs.getBool('showHours') ?? true;
      _opacity = prefs.getDouble('opacity') ?? 0.5;
      _fontSize = prefs.getDouble('fontSize') ?? 35.0;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show2022', _show2022);
    await prefs.setBool('show2014', _show2014);
    await prefs.setBool('showHours', _showHours);
    await prefs.setDouble('opacity', _opacity);
    await prefs.setDouble('fontSize', _fontSize);
    
    // Синхронізація з віджетом на робочому столі Android
    try {
      await HomeWidget.updateWidget(
        name: 'TimerWidgetProvider',
        androidName: 'TimerWidgetProvider',
      );
    } catch (e) {
      debugPrint("Помилка оновлення віджета: \$e");
    }
  }

  String calculateTimeDifference(DateTime startDate) {
    final now = DateTime.now();
    final difference = now.difference(startDate);
    if (difference.isNegative) return "0р. 0міс. 0д. 0г.";
    
    int years = now.year - startDate.year;
    int months = now.month - startDate.month;
    int days = now.day - startDate.day;
    int hours = now.hour - startDate.hour;

    if (hours < 0) { hours += 24; days--; }
    if (days < 0) { days += DateTime(now.year, now.month, 0).day; months--; }
    if (months < 0) { months += 12; years--; }
    
    String res = "\${years}р. \${months}міс. \${days}д.";
    if (_showHours) res += " \${hours}г.";
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Час Війни', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            icon: Icon(_showSettings ? Icons.keyboard_arrow_down : Icons.settings, color: Colors.deepPurpleAccent),
            onPressed: () {
              setState(() => _showSettings = !_showSettings);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Головний віджет: динамічно адаптується під наявність меню налаштувань
            Expanded(
              flex: _showSettings ? 2 : 1,
              child: Container(
                width: double.infinity,
                color: Colors.grey[850]?.withOpacity(_opacity),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_show2022) ...[
                          Text("Повномасштабна війна:", style: TextStyle(fontSize: _fontSize * 0.4, color: Colors.white70)),
                          Text(calculateTimeDifference(DateTime(2022, 2, 24, 5, 0)), 
                            style: TextStyle(fontSize: _fontSize, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 20),
                        ],
                        if (_show2014) ...[
                          Text("Війна з 2014 року:", style: TextStyle(fontSize: _fontSize * 0.4, color: Colors.white70)),
                          Text(calculateTimeDifference(DateTime(2014, 2, 20)), 
                            style: TextStyle(fontSize: _fontSize, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Меню налаштувань: займає нижню частину екрана, не перекриваючи таймер
            if (_showSettings)
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, -5))],
                  ),
                  child: DefaultTabController(
                    length: 3,
                    child: Column(
                      children: [
                        const TabBar(
                          indicatorColor: Colors.deepPurpleAccent,
                          labelColor: Colors.deepPurpleAccent,
                          unselectedLabelColor: Colors.grey,
                          tabs: [Tab(text: "Головне"), Tab(text: "Кольори"), Tab(text: "Контур")],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              // Вкладка 1: Головне
                              ListView(
                                padding: const EdgeInsets.all(16.0),
                                children: [
                                  SwitchListTile(
                                    title: const Text("Війна 2022"),
                                    value: _show2022,
                                    activeColor: Colors.deepPurpleAccent,
                                    onChanged: (val) { setState(() => _show2022 = val); _saveSettings(); },
                                  ),
                                  SwitchListTile(
                                    title: const Text("Війна 2014"),
                                    value: _show2014,
                                    activeColor: Colors.deepPurpleAccent,
                                    onChanged: (val) { setState(() => _show2014 = val); _saveSettings(); },
                                  ),
                                  SwitchListTile(
                                    title: const Text("Показ годин"),
                                    value: _showHours,
                                    activeColor: Colors.deepPurpleAccent,
                                    onChanged: (val) { setState(() => _showHours = val); _saveSettings(); },
                                  ),
                                  const Padding(padding: EdgeInsets.only(top: 16), child: Text("Прозорість фону")),
                                  Slider(
                                    value: _opacity, min: 0.0, max: 1.0, activeColor: Colors.deepPurpleAccent,
                                    onChanged: (val) { setState(() => _opacity = val); },
                                    onChangeEnd: (val) { _saveSettings(); },
                                  ),
                                  const Padding(padding: EdgeInsets.only(top: 16), child: Text("Розмір тексту")),
                                  Slider(
                                    value: _fontSize, min: 15.0, max: 60.0, activeColor: Colors.deepPurpleAccent,
                                    onChanged: (val) { setState(() => _fontSize = val); },
                                    onChangeEnd: (val) { _saveSettings(); },
                                  ),
                                ],
                              ),
                              // Вкладка 2: Кольори
                              const Center(child: Text("Палітра кольорів", style: TextStyle(color: Colors.grey))),
                              // Вкладка 3: Контур
                              const Center(child: Text("Налаштування контуру", style: TextStyle(color: Colors.grey))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
