import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
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
      title: 'Час Війни',
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _show2022 = true;
  bool _show2014 = false;
  bool _showHour = true;
  double _opacity = 0.5;
  double _fontSize = 24.0;
  
  // Кольори тексту (RGB)
  double _tr = 255.0, _tg = 255.0, _tb = 255.0;
  // Кольори фону (RGB)
  double _br = 30.0, _bg = 30.0, _bb = 30.0;
  // Кольори контуру (RGB)
  double _sr = 0.0, _sg = 0.0, _sb = 0.0;
  double _strokeWidth = 3.0;

  File? _bgFile;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _show2022 = prefs.getBool('show2022') ?? true;
      _show2014 = prefs.getBool('show2014') ?? false;
      _showHour = prefs.getBool('showHour') ?? true;
      _opacity = prefs.getDouble('opacity') ?? 0.5;
      _fontSize = prefs.getDouble('fontSize') ?? 24.0;
      _tr = prefs.getDouble('tr') ?? 255.0;
      _tg = prefs.getDouble('tg') ?? 255.0;
      _tb = prefs.getDouble('tb') ?? 255.0;
      _br = prefs.getDouble('br') ?? 30.0;
      _bg = prefs.getDouble('bg') ?? 30.0;
      _bb = prefs.getDouble('bb') ?? 30.0;
      _sr = prefs.getDouble('sr') ?? 0.0;
      _sg = prefs.getDouble('sg') ?? 0.0;
      _sb = prefs.getDouble('sb') ?? 0.0;
      _strokeWidth = prefs.getDouble('strokeWidth') ?? 3.0;
      final path = prefs.getString('bgFilePath');
      if (path != null && path.isNotEmpty) {
        _bgFile = File(path);
      }
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) await prefs.setBool(key, value);
    if (value is double) await prefs.setDouble(key, value);
    if (value is String) await prefs.setString(key, value);
    _updateHomeWidget();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _bgFile = File(pickedFile.path);
      });
      await _saveSetting('bgFilePath', pickedFile.path);
    }
  }

  Map<String, int> _calculateTime(DateTime startDate) {
    final now = DateTime.now();
    int years = now.year - startDate.year;
    int months = now.month - startDate.month;
    int days = now.day - startDate.day;
    int hours = now.hour - startDate.hour;

    if (hours < 0) {
      hours += 24;
      days--;
    }
    if (days < 0) {
      final prevMonth = now.month - 1 == 0 ? 12 : now.month - 1;
      final prevYear = now.month - 1 == 0 ? now.year - 1 : now.year;
      final daysInPrevMonth = DateTime(prevYear, prevMonth + 1, 0).day;
      days += daysInPrevMonth;
      months--;
    }
    if (months < 0) {
      months += 12;
      years--;
    }
    return {'years': years, 'months': months, 'days': days, 'hours': hours};
  }

  Future<void> _updateHomeWidget() async {
    String widgetText = "";
    if (_show2022) {
      final t = _calculateTime(DateTime(2022, 2, 24));
      widgetText += "Повномасштабна війна:\n${t['years']}р. ${t['months']}міс. ${t['days']}д.";
      if (_showHour) widgetText += " ${t['hours']}г.";
    }
    if (_show2014) {
      if (widgetText.isNotEmpty) widgetText += "\n\n";
      final t = _calculateTime(DateTime(2014, 2, 20));
      widgetText += "Війна з 2014 року:\n${t['years']}р. ${t['months']}міс. ${t['days']}д.";
      if (_showHour) widgetText += " ${t['hours']}г.";
    }

    await HomeWidget.saveWidgetData<String>('widget_text', widgetText);
    await HomeWidget.updateWidget(
      name: 'HomeWidgetProvider',
      androidName: 'HomeWidgetProvider',
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Color.fromRGBO(_br.toInt(), _bg.toInt(), _bb.toInt(), 1);
    final textColor = Color.fromRGBO(_tr.toInt(), _tg.toInt(), _tb.toInt(), 1);
    final strokeColor = Color.fromRGBO(_sr.toInt(), _sg.toInt(), _sb.toInt(), 1);

    String previewText = "";
    if (_show2022) {
      final t = _calculateTime(DateTime(2022, 2, 24));
      previewText += "Повномасштабна війна:\n${t['years']}р. ${t['months']}міс. ${t['days']}д.";
      if (_showHour) previewText += " ${t['hours']}г.";
    }
    if (_show2014) {
      if (previewText.isNotEmpty) previewText += "\n\n";
      final t = _calculateTime(DateTime(2014, 2, 20));
      previewText += "Війна з 2014 року:\n${t['years']}р. ${t['months']}міс. ${t['days']}д.";
      if (_showHour) previewText += " ${t['hours']}г.";
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Верхня робоча зона прев'ю (завжди відкрита)
            Positioned.fill(
              bottom: 400, // Фіксований відступ знизу для панелі
              child: Container(
                color: bgColor,
                child: Stack(
                  children: [
                    if (_bgFile != null && _bgFile!.existsSync())
                      Positioned.fill(
                        child: Opacity(
                          opacity: _opacity,
                          child: Image.file(_bgFile!, fit: BoxFit.cover),
                        ),
                      ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Stack(
                          children: [
                            // Контур тексту
                            Text(
                              previewText,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: _fontSize,
                                fontWeight: FontWeight.bold,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = _strokeWidth
                                  ..color = strokeColor,
                              ),
                            ),
                            // Основний текст
                            Text(
                              previewText,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: _fontSize,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Нижня фіксована панель налаштувань (виправлено перекриття)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 400, // Чіткі межі, меню більше не розтягується на весь екран
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      const TabBar(
                        indicatorColor: Colors.deepPurpleAccent,
                        tabs: [
                          Tab(text: "Головне"),
                          Tab(text: "Кольори"),
                          Tab(text: "Контур"),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Вкладка 1: Головне
                            ListView(
                              padding: const EdgeInsets.all(12),
                              children: [
                                SwitchListTile(
                                  title: const Text("Війна 2022"),
                                  value: _show2022,
                                  onChanged: (val) {
                                    setState(() => _show2022 = val);
                                    _saveSetting('show2022', val);
                                  },
                                ),
                                SwitchListTile(
                                  title: const Text("Війна 2014"),
                                  value: _show2014,
                                  onChanged: (val) {
                                    setState(() => _show2014 = val);
                                    _saveSetting('show2014', val);
                                  },
                                ),
                                SwitchListTile(
                                  title: const Text("Показ годин"),
                                  value: _showHour,
                                  onChanged: (val) {
                                    setState(() => _showHour = val);
                                    _saveSetting('showHour', val);
                                  },
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                  child: Text("Прозорість фону", style: TextStyle(color: Colors.grey)),
                                ),
                                Slider(
                                  value: _opacity,
                                  min: 0.0,
                                  max: 1.0,
                                  onChanged: (val) {
                                    setState(() => _opacity = val);
                                    _saveSetting('opacity', val);
                                  },
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                  child: Text("Розмір тексту", style: TextStyle(color: Colors.grey)),
                                ),
                                Slider(
                                  value: _fontSize,
                                  min: 12.0,
                                  max: 60.0,
                                  onChanged: (val) {
                                    setState(() => _fontSize = val);
                                    _saveSetting('fontSize', val);
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: ElevatedButton.icon(
                                    onPressed: _pickImage,
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                                    icon: const Icon(Icons.image, color: Colors.white),
                                    label: const Text("Вибрати ФОТО з галереї", style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ],
                            ),
                            
                            // Вкладка 2: Кольори
                            ListView(
                              padding: const EdgeInsets.all(12),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Колір тексту (RGB)", style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                Slider(
                                  value: _tr, min: 0, max: 255, activeColor: Colors.red,
                                  onChanged: (val) { setState(() => _tr = val); _saveSetting('tr', val); },
                                ),
                                Slider(
                                  value: _tg, min: 0, max: 255, activeColor: Colors.green,
                                  onChanged: (val) { setState(() => _tg = val); _saveSetting('tg', val); },
                                ),
                                Slider(
                                  value: _tb, min: 0, max: 255, activeColor: Colors.blue,
                                  onChanged: (val) { setState(() => _tb = val); _saveSetting('tb', val); },
                                ),
                                const Divider(),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Колір фону (RGB)", style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                Slider(
                                  value: _br, min: 0, max: 255, activeColor: Colors.redAccent,
                                  onChanged: (val) { setState(() => _br = val); _saveSetting('br', val); },
                                ),
                                Slider(
                                  value: _bg, min: 0, max: 255, activeColor: Colors.greenAccent,
                                  onChanged: (val) { setState(() => _bg = val); _saveSetting('bg', val); },
                                ),
                                Slider(
                                  value: _bb, min: 0, max: 255, activeColor: Colors.blueAccent,
                                  onChanged: (val) { setState(() => _bb = val); _saveSetting('bb', val); },
                                ),
                              ],
                            ),
                            
                            // Вкладка 3: Контур
                            ListView(
                              padding: const EdgeInsets.all(12),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Товщина контуру", style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                Slider(
                                  value: _strokeWidth, min: 0.0, max: 10.0,
                                  onChanged: (val) { setState(() => _strokeWidth = val); _saveSetting('strokeWidth', val); },
                                ),
                                const Divider(),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Колір контуру (RGB)", style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                Slider(
                                  value: _sr, min: 0, max: 255, activeColor: Colors.red,
                                  onChanged: (val) { setState(() => _sr = val); _saveSetting('sr', val); },
                                ),
                                Slider(
                                  value: _sg, min: 0, max: 255, activeColor: Colors.green,
                                  onChanged: (val) { setState(() => _sg = val); _saveSetting('sg', val); },
                                ),
                                Slider(
                                  value: _sb, min: 0, max: 255, activeColor: Colors.blue,
                                  onChanged: (val) { setState(() => _sb = val); _saveSetting('sb', val); },
                                ),
                              ],
                            ),
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
