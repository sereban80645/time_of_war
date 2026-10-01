import re

with open("lib/main.dart", "r") as f:
    code = f.read()

new_main = """void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  DateTime now = DateTime.now();
  DateTime nextTrigger = DateTime(now.year, now.month, now.day, now.hour, 2);
  if (nextTrigger.isBefore(now)) {
    nextTrigger = nextTrigger.add(const Duration(hours: 1));
  }
  await AndroidAlarmManager.periodic(
    const Duration(hours: 1),
    0,
    backgroundUpdate,
    startAt: nextTrigger,
    exact: true,
    wakeup: true,
    rescheduleOnReboot: true,
  );
  runApp(const MyApp());
}"""

code = re.sub(r'void\s+main\(\)\s*async\s*\{.*?\n\s*runApp\(const\s+MyApp\(\)\);\s*\}', new_main, code, flags=re.DOTALL)

with open("lib/main.dart", "w") as f:
    f.write(code)

print("ГОТОВО: Функцію main успішно оновлено!")
