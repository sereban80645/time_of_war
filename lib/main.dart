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
  bool _show2022 = true, _show2014 = false, _showHours = true;
  double _fontSize = 35, _strokeWidth = 3, _opacity = 0.8;
  Offset _pos = const Offset(50, 100);
  File? _bgFile;

  double _br = 30, _bg = 30, _bb = 30; // Фон RGB
  double _tr = 255, _tg = 255, _tb = 255; // Текст RGB
  double _sr = 0, _sg = 0, _sb = 0; // Контур RGB

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) => setState(() {}));
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _bgFile = File(picked.path));
  }

  String _time(DateTime d) {
    Duration diff = DateTime.now().difference(d);
    int y = diff.inDays ~/ 365;
    int d_off = diff.inDays % 365;
    return _showHours ? "$yр. $d_offд. ${diff.inHours % 24}г." : "$yр. $d_offд.";
  }

  Widget _rgbSlider(String name, double val, Color color, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$name: ${val.toInt()}", style: const TextStyle(color: Colors.white, fontSize: 12)),
        Slider(value: val, max: 255, activeColor: color, onChanged: onChanged),
      ],
    );
  }

  void _openMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121212),
      builder: (context) => StatefulBuilder(builder: (context, setM) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(20),
        child: DefaultTabController(
          length: 3,
          child: Column(children: [
            const TabBar(tabs: [Tab(text: "Головне"), Tab(text: "Кольори"), Tab(text: "Контур")]),
            Expanded(child: TabBarView(children: [
              // Вкладка 1
              ListView(children: [
                SwitchListTile(title: const Text("Війна 2022", style: TextStyle(color: Colors.white)), value: _show2022, onChanged: (v){setState(()=>_show2022=v);setM((){});}),
                SwitchListTile(title: const Text("Війна 2014", style: TextStyle(color: Colors.white)), value: _show2014, onChanged: (v){setState(()=>_show2014=v);setM((){});}),
                SwitchListTile(title: const Text("Показ годин", style: TextStyle(color: Colors.orange)), value: _showHours, onChanged: (v){setState(()=>_showHours=v);setM((){});}),
                const Text("Прозорість фону", style: TextStyle(color: Colors.grey)),
                Slider(value: _opacity, onChanged: (v){setState(()=>_opacity=v);setM((){});}),
                const Text("Розмір тексту", style: TextStyle(color: Colors.grey)),
                Slider(value: _fontSize, min: 10, max: 70, onChanged: (v){setState(()=>_fontSize=v);setM((){});}),
                ElevatedButton.icon(icon: const Icon(Icons.image), label: const Text("Вибрати ФОТО з галереї"), onPressed: _pickImage),
              ]),
              // Вкладка 2
              ListView(children: [
                const Text("ФОН ПАНЕЛІ", style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
                _rgbSlider("Червоний (R)", _br, Colors.red, (v){setState(()=>_br=v);setM((){});}),
                _rgbSlider("Зелений (G)", _bg, Colors.green, (v){setState(()=>_bg=v);setM((){});}),
                _rgbSlider("Синій (B)", _bb, Colors.blue, (v){setState(()=>_bb=v);setM((){});}),
                const Divider(color: Colors.white24),
                const Text("КОЛІР ТЕКСТУ", style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
                _rgbSlider("Червоний (R)", _tr, Colors.red, (v){setState(()=>_tr=v);setM((){});}),
                _rgbSlider("Зелений (G)", _tg, Colors.green, (v){setState(()=>_tg=v);setM((){});}),
                _rgbSlider("Синій (B)", _tb, Colors.blue, (v){setState(()=>_tb=v);setM((){});}),
              ]),
              // Вкладка 3
              ListView(children: [
                const Text("Товщина контуру", style: TextStyle(color: Colors.white)),
                Slider(value: _strokeWidth, min: 0, max: 15, onChanged: (v){setState(()=>_strokeWidth=v);setM((){});}),
                const Text("КОЛІР КОНТУРУ", style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
                _rgbSlider("R", _sr, Colors.red, (v){setState(()=>_sr=v);setM((){});}),
                _rgbSlider("G", _sg, Colors.green, (v){setState(()=>_sg=v);setM((){});}),
                _rgbSlider("B", _sb, Colors.blue, (v){setState(()=>_sb=v);setM((){});}),
              ]),
            ])),
          ]),
        ),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          image: _bgFile != null ? DecorationImage(image: FileImage(_bgFile!), fit: BoxFit.cover) : null,
        ),
        child: Stack(children: [
          Positioned(
            left: _pos.dx, top: _pos.dy,
            child: GestureDetector(
              onPanUpdate: (d) => setState(() => _pos += d.delta),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(_br.toInt(), _bg.toInt(), _bb.toInt(), _opacity),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  if (_show2022) _outlineText(_time(DateTime(2022, 2, 24, 4, 0))),
                  if (_show2014) _outlineText(_time(DateTime(2014, 2, 20))),
                ]),
              ),
            ),
          ),
          Positioned(bottom: 30, right: 30, child: FloatingActionButton(backgroundColor: Colors.yellow, onPressed: _openMenu, child: const Icon(Icons.tune, color: Colors.black))),
        ]),
      ),
    );
  }

  Widget _outlineText(String text) {
    return Stack(children: [
      Text(text, style: TextStyle(fontSize: _fontSize, fontWeight: FontWeight.w900, foreground: Paint()..style = PaintingStyle.stroke..strokeWidth = _strokeWidth..color = Color.fromARGB(255, _sr.toInt(), _sg.toInt(), _sb.toInt()))),
      Text(text, style: TextStyle(fontSize: _fontSize, fontWeight: FontWeight.w900, color: Color.fromARGB(255, _tr.toInt(), _tg.toInt(), _tb.toInt()))),
    ]);
  }
}
