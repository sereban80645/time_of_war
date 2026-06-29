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
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const TimeOfWarScreen(),
    );
  }
}

// --- КЛАС ДЛЯ РЕНДЕРУ ВІДЖЕТА ---
class TimeOfWarWidgetRender extends StatelessWidget {
  final bool show2022;
  final bool show2014;
  final String time2022;
  final String time2014;
  final double fontSize;
  final double strokeWidth;
  final double opacity;
  final Color bgColor;
  final Color textColor;
  final Color strokeColor;
  final String? imagePath;

  const TimeOfWarWidgetRender({
    Key? key,
    required this.show2022,
    required this.show2014,
    required this.time2022,
    required this.time2014,
    required this.fontSize,
    required this.strokeWidth,
    required this.opacity,
    required this.bgColor,
    required this.textColor,
    required this.strokeColor,
    this.imagePath,
  }) : super(key: key);

  Widget _buildOutlinedText(String text) {
    return Stack(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = strokeColor,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 800,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(56),
        color: imagePath == null ? bgColor : null,
        image: imagePath != null
            ? DecorationImage(
                image: FileImage(File(imagePath!)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(56),
          color: imagePath != null ? bgColor : null,
        ),
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (show2022) ...[
              Text("Повномасштабна війна:", style: TextStyle(color: Colors.white70, fontSize: fontSize * 0.5, fontWeight: FontWeight.w500)),
              _buildOutlinedText(time2022),
            ],
            if (show2014) ...[
              if (show2022) const SizedBox(height: 20),
              Text("Війна з 2014 року:", style: TextStyle(color: Colors.white70, fontSize: fontSize * 0.5, fontWeight: FontWeight.w500)),
              _buildOutlinedText(time2014),
            ],
          ],
        ),
      ),
    );
  }
}

// --- ГОЛОВНИЙ ЕКРАН ---
class TimeOfWarScreen extends StatefulWidget {
  const TimeOfWarScreen({Key? key}) : super(key: key);
  @override
  State<TimeOfWarScreen> createState() => _TimeOfWarScreenState();
}

class _TimeOfWarScreenState extends State<TimeOfWarScreen> {
  bool _show2022 = true;
  bool _show2014 = false;
  bool _showHour = true;
  double _fontSize = 22.0;
  double _strokeWidth = 3.0;
  double _opacity = 0.5;

  double _br = 30.0, _bg = 30.0, _bb = 30.0;
  double _tr = 255.0, _tg = 255.0, _tb = 255.0;
  double _sr = 0.0, _sg = 0.0, _sb = 0.0;

  String? _imagePath;
  Timer? _timer;
  Timer? _debounce;

  // Крапки відліку за вашим запитом
  final DateTime _date2022Start = DateTime(2022, 2, 24, 5, 0); // Повномасштабна з 05:00 ранку
  final DateTime _date2014Start = DateTime(2014, 2, 20, 0, 0); // Війна 2014 з 20 лютого

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
        if (DateTime.now().second == 0) {
          _debouncedUpdate();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _debounce?.cancel();
    super.dispose();
  }

  void _debouncedUpdate() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _updateHomeWidget();
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _show2022 = prefs.getBool('show2022') ?? true;
      _show2014 = prefs.getBool('show2014') ?? false;
      _showHour = prefs.getBool('showHour') ?? true;
      _fontSize = prefs.getDouble('fontSize') ?? 22.0;
      _strokeWidth = prefs.getDouble('strokeWidth') ?? 3.0;
      _opacity = prefs.getDouble('opacity') ?? 0.5;
      _br = prefs.getDouble('br') ?? 30.0;
      _bg = prefs.getDouble('bg') ?? 30.0;
      _bb = prefs.getDouble('bb') ?? 30.0;
      _tr = prefs.getDouble('tr') ?? 255.0;
      _tg = prefs.getDouble('tg') ?? 255.0;
      _tb = prefs.getDouble('tb') ?? 255.0;
      _sr = prefs.getDouble('sr') ?? 0.0;
      _sg = prefs.getDouble('sg') ?? 0.0;
      _sb = prefs.getDouble('sb') ?? 0.0;
      _imagePath = prefs.getString('imagePath');
    });
    _updateHomeWidget();
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) await prefs.setBool(key, value);
    if (value is double) await prefs.setDouble(key, value);
    if (value is String) await prefs.setString(key, value);
    
    _debouncedUpdate(); 
  }

  Future<void> _updateHomeWidget() async {
    try {
      final bgColor = Color.fromRGBO(_br.toInt(), _bg.toInt(), _bb.toInt(), 1.0).withOpacity(_opacity);
      final textColor = Color.fromRGBO(_tr.toInt(), _tg.toInt(), _tb.toInt(), 1.0);
      final strokeColor = Color.fromRGBO(_sr.toInt(), _sg.toInt(), _sb.toInt(), 1.0);

      final time2022 = _calculateTimeDifference(_date2022Start);
      final time2014 = _calculateTimeDifference(_date2014Start);

      double dynamicHeight = 150.0; 
      if (_show2022 && _show2014) {
        dynamicHeight = 400.0;
      } else if (_show2022 || _show2014) {
        dynamicHeight = 240.0;
      }

      await HomeWidget.renderFlutterWidget(
        TimeOfWarWidgetRender(
          show2022: _show2022,
          show2014: _show2014,
          time2022: time2022,
          time2014: time2014,
          fontSize: _fontSize * 2.5,
          strokeWidth: _strokeWidth * 2.5,
          opacity: _opacity,
          bgColor: bgColor,
          textColor: textColor,
          strokeColor: strokeColor,
          imagePath: _imagePath,
        ),
        key: 'widget_image',
        logicalSize: Size(800, dynamicHeight),
      );

      await HomeWidget.updateWidget(name: 'WidgetProvider', androidName: 'WidgetProvider');
    } catch (e) {
      debugPrint("HomeWidget Error: $e");
    }
  }

  String _calculateTimeDifference(DateTime startDate) {
    final now = DateTime.now();
    int years = now.year - startDate.year;
    int months = now.month - startDate.month;
    int days = now.day - startDate.day;
    int hours = now.hour - startDate.hour;

    if (hours < 0) {
      days--;
      hours += 24;
    }
    if (days < 0) {
      months--;
      final prevMonth = DateTime(now.year, now.month, 0);
      days += prevMonth.day;
    }
    if (months < 0) {
      years--;
      months += 12;
    }

    String output = "${years}р. ${months}міс. ${days}д.";
    if (_showHour) output += " ${hours}г.";
    return output;
  }

  Widget _buildOutlinedText(String text) {
    final textColor = Color.fromRGBO(_tr.toInt(), _tg.toInt(), _tb.toInt(), 1.0);
    final strokeColor = Color.fromRGBO(_sr.toInt(), _sg.toInt(), _sb.toInt(), 1.0);
    return Stack(
      children: [
        Text(text, style: TextStyle(fontSize: _fontSize, fontWeight: FontWeight.bold, foreground: Paint()..style = PaintingStyle.stroke..strokeWidth = _strokeWidth..color = strokeColor)),
        Text(text, style: TextStyle(fontSize: _fontSize, fontWeight: FontWeight.bold, color: textColor)),
      ],
    );
  }

  Widget _buildWidgetPreview() {
    final bgColor = Color.fromRGBO(_br.toInt(), _bg.toInt(), _bb.toInt(), _opacity);
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Прев'ю віджета на робочому столі:", style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: _imagePath == null ? bgColor : null,
              image: _imagePath != null ? DecorationImage(image: FileImage(File(_imagePath!)), fit: BoxFit.cover) : null,
              border: Border.all(color: Colors.white10, width: 1),
            ),
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), color: _imagePath != null ? bgColor : null),
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_show2022) ...[
                    const Text("Повномасштабна війна:", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                    _buildOutlinedText(_calculateTimeDifference(_date2022Start)),
                  ],
                  if (_show2014) ...[
                    if (_show2022) const SizedBox(height: 10),
                    const Text("Війна з 2014 року:", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                    _buildOutlinedText(_calculateTimeDifference(_date2014Start)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imagePath = pickedFile.path);
      _saveSetting('imagePath', pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Час Війни"), elevation: 0, backgroundColor: Colors.transparent,
          bottom: const TabBar(indicatorColor: Colors.deepPurpleAccent, tabs: [Tab(text: "Головне"), Tab(text: "Кольори"), Tab(text: "Контур")]),
        ),
        body: Column(
          children: [
            _buildWidgetPreview(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(color: Color(0xFF1E1E1E), borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
                child: TabBarView(children: [_buildMainTab(), _buildColorsTab(), _buildContourTab()]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SwitchListTile(title: const Text("Війна 2022"), value: _show2022, activeColor: Colors.deepPurpleAccent, onChanged: (v) { setState(() => _show2022 = v); _saveSetting('show2022', v); }),
        SwitchListTile(title: const Text("Війна 2014"), value: _show2014, activeColor: Colors.deepPurpleAccent, onChanged: (v) { setState(() => _show2014 = v); _saveSetting('show2014', v); }),
        SwitchListTile(title: const Text("Показ годин"), value: _showHour, activeColor: Colors.deepPurpleAccent, onChanged: (v) { setState(() => _showHour = v); _saveSetting('showHour', v); }),
        const Divider(color: Colors.white10),
        const Text("Прозорість фону", style: TextStyle(fontSize: 14)),
        Slider(value: _opacity, min: 0.0, max: 1.0, activeColor: Colors.deepPurpleAccent, onChanged: (v) { setState(() => _opacity = v); _saveSetting('opacity', v); }),
        const Text("Розмір тексту", style: TextStyle(fontSize: 14)),
        Slider(value: _fontSize, min: 12.0, max: 40.0, activeColor: Colors.deepPurpleAccent, onChanged: (v) { setState(() => _fontSize = v); _saveSetting('fontSize', v); }),
        const SizedBox(height: 10),
        ElevatedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.image), label: const Text("Вибрати ФОТО"), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D2D2D), padding: const EdgeInsets.symmetric(vertical: 14))),
      ],
    );
  }

  Widget _buildColorsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Колір тексту", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent)), const SizedBox(height: 8),
        _buildRGBSliders(_tr, _tg, _tb, (r, g, b) { setState(() { _tr = r; _tg = g; _tb = b; }); _saveSetting('tr', r); _saveSetting('tg', g); _saveSetting('tb', b); }),
        const Divider(color: Colors.white10, height: 32),
        const Text("Колір фону", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent)), const SizedBox(height: 8),
        _buildRGBSliders(_br, _bg, _bb, (r, g, b) { setState(() { _br = r; _bg = g; _bb = b; }); _saveSetting('br', r); _saveSetting('bg', g); _saveSetting('bb', b); }),
      ],
    );
  }

  Widget _buildContourTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Колір контуру", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent)), const SizedBox(height: 8),
        _buildRGBSliders(_sr, _sg, _sb, (r, g, b) { setState(() { _sr = r; _sg = g; _sb = b; }); _saveSetting('sr', r); _saveSetting('sg', g); _saveSetting('sb', b); }),
        const Divider(color: Colors.white10, height: 32),
        const Text("Товщина контуру", style: TextStyle(fontSize: 14)),
        Slider(value: _strokeWidth, min: 0.0, max: 8.0, activeColor: Colors.deepPurpleAccent, onChanged: (v) { setState(() => _strokeWidth = v); _saveSetting('strokeWidth', v); }),
      ],
    );
  }

  Widget _buildRGBSliders(double r, double g, double b, Function(double, double, double) onChanged) {
    return Column(children: [
      Row(children: [const SizedBox(width: 20, child: Text("R", style: TextStyle(color: Colors.red))), Expanded(child: Slider(value: r, min: 0, max: 255, activeColor: Colors.red, onChanged: (v) => onChanged(v, g, b)))]),
      Row(children: [const SizedBox(width: 20, child: Text("G", style: TextStyle(color: Colors.green))), Expanded(child: Slider(value: g, min: 0, max: 255, activeColor: Colors.green, onChanged: (v) => onChanged(r, v, b)))]),
      Row(children: [const SizedBox(width: 20, child: Text("B", style: TextStyle(color: Colors.blue))), Expanded(child: Slider(value: b, min: 0, max: 255, activeColor: Colors.blue, onChanged: (v) => onChanged(r, g, v)))]),
    ]);
  }
}
