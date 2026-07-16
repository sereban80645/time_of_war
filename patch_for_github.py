import os, re

dart_file = 'lib/main.dart'
with open(dart_file, 'r', encoding='utf-8') as f:
    code = f.read()

if 'android_alarm_manager_plus' not in code:
    code = "import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';\n" + code
    main_match = re.search(r'void\s+main\s*\(\s*\)\s*(async\s*)?\{', code)
    if main_match:
        init_code = """WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  DateTime now = DateTime.now();
  DateTime nextMidnight = DateTime(now.year, now.month, now.day).add(const Duration(days: 1, minutes: 1));
  await AndroidAlarmManager.periodic(const Duration(days: 1), 1, backgroundUpdate, startAt: nextMidnight, exact: true, wakeup: true);
"""
        code = code[:main_match.end()] + "\n  " + init_code + code[main_match.end():]

    background_task = """
@pragma('vm:entry-point')
void backgroundUpdate() async {
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
      if (val.contains('159') || val.contains('160') || val.contains('161') || val.contains('162')) {
        await prefs.setString(key, text22);
      } else if (val.contains('452') || val.contains('453') || val.contains('454') || val.contains('455')) {
        await prefs.setString(key, text14);
      }
    }
  }
  
  await HomeWidget.updateWidget(name: "WidgetProvider", androidName: "WidgetProvider");
}
"""
    code += "\n" + background_task
    with open(dart_file, 'w', encoding='utf-8') as f:
        f.write(code)

manifest = 'android/app/src/main/AndroidManifest.xml'
with open(manifest, 'r', encoding='utf-8') as f:
    mani_code = f.read()
if 'AlarmService' not in mani_code:
    services = '\n        <service android:name="dev.fluttercommunity.plus.androidalarmmanager.AlarmService" android:permission="android.permission.BIND_JOB_SERVICE" android:exported="false"/>\n        <receiver android:name="dev.fluttercommunity.plus.androidalarmmanager.AlarmBroadcastReceiver" android:exported="false"/>\n    '
    mani_code = mani_code.replace('</application>', services + '</application>')
    with open(manifest, 'w', encoding='utf-8') as f:
        f.write(mani_code)
