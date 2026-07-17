import os

# 1. Додаємо дозвіл на точні будильники в Manifest
manifest = 'android/app/src/main/AndroidManifest.xml'
with open(manifest, 'r', encoding='utf-8') as f:
    mani = f.read()

if 'SCHEDULE_EXACT_ALARM' not in mani:
    mani = mani.replace('<application', '<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />\n    <application')
    with open(manifest, 'w', encoding='utf-8') as f:
        f.write(mani)

# 2. Виправляємо main.dart
dart = 'lib/main.dart'
with open(dart, 'r', encoding='utf-8') as f:
    code = f.read()

# Додаємо погодинний таймер, якщо його немає
if 'Duration(hours: 1)' not in code:
    code = code.replace(
        'await AndroidAlarmManager.periodic(const Duration(days: 1), 1, backgroundUpdate, startAt: nextMidnight, exact: true, wakeup: true);',
        'await AndroidAlarmManager.periodic(const Duration(days: 1), 1, backgroundUpdate, startAt: nextMidnight, exact: true, wakeup: true);\n  await AndroidAlarmManager.periodic(const Duration(hours: 1), 2, backgroundUpdate, exact: true, wakeup: true);'
    )

# Повністю замінюємо фонову функцію на надійну
start_idx = code.find('void backgroundUpdate() async {')
if start_idx != -1:
    new_func = r"""void backgroundUpdate() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  
  bool showHours = false;
  for (String key in prefs.getKeys()) {
    dynamic val = prefs.get(key);
    if (val is bool && (key.toLowerCase().contains('hour') || key.toLowerCase().contains('год') || key.toLowerCase().contains('time'))) {
      showHours = val;
    }
  }
  
  DateTime now = DateTime.now();
  DateTime start2022 = DateTime(2022, 2, 24);
  DateTime start2014 = DateTime(2014, 2, 20);
  
  int d2022 = now.difference(start2022).inDays;
  int h2022 = now.difference(start2022).inHours % 24;
  
  int d2014 = now.difference(start2014).inDays;
  int h2014 = now.difference(start2014).inHours % 24;
  
  String text22 = "${d2022}д.";
  if (showHours) text22 += " ${h2022}г.";
  
  String text14 = "${d2014}д.";
  if (showHours) text14 += " ${h2014}г.";
  
  for (String key in prefs.getKeys()) {
    dynamic val = prefs.get(key);
    if (val is String && val.contains('д.')) {
      RegExp regExp = RegExp(r'(\d+)д\.');
      Match? match = regExp.firstMatch(val);
      if (match != null) {
        int days = int.parse(match.group(1)!);
        if (days > 4000) {
          await prefs.setString(key, text14);
        } else if (days > 1000 && days < 2000) {
          await prefs.setString(key, text22);
        }
      }
    }
  }
  
  await HomeWidget.updateWidget(name: "WidgetProvider", androidName: "WidgetProvider");
}
"""
    code = code[:start_idx] + new_func

with open(dart, 'w', encoding='utf-8') as f:
    f.write(code)
