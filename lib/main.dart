import 'package:home_widget/home_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';

void main() => runApp(const MaterialApp(home: TimeOfWar(), debugShowCheckedModeBanner: false));

class TimeOfWar extends StatefulWidget {
  const TimeOfWar({super.key});
  @override
  State<TimeOfWar> createState() => _TimeOfWarState();
}

class _TimeOfWarState extends State<TimeOfWar> {
  bool _show2022 = true, _show2014 = false, _showHour = true;
  double _fontSize = 35, _strokeWidth = 3, _opacity = 0.5;
  Offset _pos = const Offset(50, 100);
  File? _bgFile;

  double _br = 30, _bg = 30, _bb = 30; // Фон RGB
  double _tr = 255, _tg = 255, _tb = 255; // Текст RGB
  double _sr = 0, _sg = 0, _sb = 0; // Контур RGB

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
      _updateHomeWidget();
    });
  }

  String calculateTimeDifference(DateTime startDate) {
    DateTime now = DateTime.now();
    int years = now.year - startDate.year;
    int months = now.month - startDate.month;
    int days = now.day - startDate.day;
    int hours = now.hour - startDate.hour;

    if (hours < 0) {
      hours += 24;
      days--;
    }
    if (days < 0) {
      var prevMonth = DateTime(now.year, now.month, 0);
      days += prevMonth.day;
      months--;
    }
    if (months < 0) {
      months += 12;
      years--;
    }

    if (_showHour) {
      return '$yearsр. $monthsміс. $daysд. $hoursг.';
    } else {
      return '$yearsр. $monthsміс. $daysд.';
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _bgFile = File(pickedFile.path));
  }

  Widget _buildText(String text, double size, Color color, Color stroke) {
    return Stack(
      children: [
        Text(text,
            style: TextStyle(
                fontSize: size,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = _strokeWidth
                  ..color = stroke)),
        Text(text, style: TextStyle(fontSize: size, color: color)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Color.fromRGBO(_br.toInt(), _bg.toInt(), _bb.toInt(), 1);
    final textColor = Color.fromRGBO(_tr.toInt(), _tg.toInt(), _tb.toInt(), 1);
    final strokeColor = Color.fromRGBO(_sr.toInt(), _sg.toInt(), _sb.toInt(), 1);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          if (_bgFile != null)
            Positioned.fill(
              child: Opacity(
                opacity: _opacity,
                child: Image.file(_bgFile!, fit: BoxFit.cover),
              ),
            ),
          Positioned(
            left: _pos.dx,
            top: _pos.dy,
            child: GestureDetector(
              onPanUpdate: (details) => setState(() => _pos += details.delta),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_show2022) _buildText(calculateTimeDifference(DateTime(2022, 2, 24)), _fontSize, textColor, strokeColor),
                  if (_show2014) _buildText(calculateTimeDifference(DateTime(2014, 2, 20)), _fontSize, textColor, strokeColor),
                ],
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.1,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      const TabBar(
                        indicatorColor: Colors.deepPurpleAccent,
                        labelColor: Colors.deepPurpleAccent,
                        unselectedLabelColor: Colors.grey,
                        tabs: [
                          Tab(text: 'Головне'),
                          Tab(text: 'Кольори'),
                          Tab(text: 'Контур'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Tab 1
                            ListView(
                              controller: scrollController,
                              children: [
                                SwitchListTile(
                                  title: const Text('Війна 2022', style: TextStyle(color: Colors.white)),
                                  value: _show2022,
                                  activeColor: Colors.deepPurpleAccent,
                                  onChanged: (v) => setState(() => _show2022 = v),
                                ),
                                SwitchListTile(
                                  title: const Text('Війна 2014', style: TextStyle(color: Colors.white)),
                                  value: _show2014,
                                  activeColor: Colors.deepPurpleAccent,
                                  onChanged: (v) => setState(() => _show2014 = v),
                                ),
                                SwitchListTile(
                                  title: const Text('Показ годин', style: TextStyle(color: Colors.orange)),
                                  value: _showHour,
                                  activeColor: Colors.deepPurpleAccent,
                                  onChanged: (v) => setState(() => _showHour = v),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Прозорість фону', style: TextStyle(color: Colors.grey)),
                                      Slider(value: _opacity, min: 0, max: 1, activeColor: Colors.deepPurpleAccent, onChanged: (v) => setState(() => _opacity = v)),
                                      const Text('Розмір тексту', style: TextStyle(color: Colors.grey)),
                                      Slider(value: _fontSize, min: 10, max: 100, activeColor: Colors.deepPurpleAccent, onChanged: (v) => setState(() => _fontSize = v)),
                                      const SizedBox(height: 10),
                                      ElevatedButton.icon(
                                        onPressed: _pickImage,
                                        icon: const Icon(Icons.image, color: Colors.black),
                                        label: const Text('Вибрати ФОТО з галереї', style: TextStyle(color: Colors.black)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFF3E5F5),
                                          minimumSize: const Size(double.infinity, 50),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // Tab 2
                            ListView(
                              controller: scrollController,
                              children: [
                                const Padding(padding: EdgeInsets.all(16), child: Text('Текст RGB', style: TextStyle(color: Colors.white))),
                                Slider(value: _tr, min: 0, max: 255, activeColor: Colors.red, onChanged: (v) => setState(() => _tr = v)),
                                Slider(value: _tg, min: 0, max: 255, activeColor: Colors.green, onChanged: (v) => setState(() => _tg = v)),
                                Slider(value: _tb, min: 0, max: 255, activeColor: Colors.blue, onChanged: (v) => setState(() => _tb = v)),
                                const Divider(color: Colors.grey),
                                const Padding(padding: EdgeInsets.all(16), child: Text('Фон RGB', style: TextStyle(color: Colors.white))),
                                Slider(value: _br, min: 0, max: 255, activeColor: Colors.red, onChanged: (v) => setState(() => _br = v)),
                                Slider(value: _bg, min: 0, max: 255, activeColor: Colors.green, onChanged: (v) => setState(() => _bg = v)),
                                Slider(value: _bb, min: 0, max: 255, activeColor: Colors.blue, onChanged: (v) => setState(() => _bb = v)),
                              ],
                            ),
                            // Tab 3
                            ListView(
                              controller: scrollController,
                              children: [
                                const Padding(padding: EdgeInsets.all(16), child: Text('Контур RGB', style: TextStyle(color: Colors.white))),
                                Slider(value: _sr, min: 0, max: 255, activeColor: Colors.red, onChanged: (v) => setState(() => _sr = v)),
                                Slider(value: _sg, min: 0, max: 255, activeColor: Colors.green, onChanged: (v) => setState(() => _sg = v)),
                                Slider(value: _sb, min: 0, max: 255, activeColor: Colors.blue, onChanged: (v) => setState(() => _sb = v)),
                                const Divider(color: Colors.grey),
                                const Padding(padding: EdgeInsets.all(16), child: Text('Товщина контуру', style: TextStyle(color: Colors.white))),
                                Slider(value: _strokeWidth, min: 0, max: 15, activeColor: Colors.deepPurpleAccent, onChanged: (v) => setState(() => _strokeWidth = v)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _updateHomeWidget() {
    DateTime now = DateTime.now();
    DateTime date2022 = DateTime(2022, 2, 24, 5, 0);
    DateTime date2014 = DateTime(2014, 2, 20, 0, 0);
    
    Duration diff2022 = now.difference(date2022);
    Duration diff2014 = now.difference(date2014);
    
    String txt2022 = "${diff2022.inDays}д ${diff2022.inHours % 24}г ${diff2022.inMinutes % 60}хв ${diff2022.inSeconds % 60}с";
    String txt14 = "${diff2014.inDays}д ${diff2014.inHours % 24}г ${diff2014.inMinutes % 60}хв ${diff2014.inSeconds % 60}с";
    
    HomeWidget.saveWidgetData("timer_2022", txt2022);
    HomeWidget.saveWidgetData("timer_2014", txt14);
    HomeWidget.updateWidget(name: "TimerWidgetProvider", androidName: "TimerWidgetProvider");
  }
}
