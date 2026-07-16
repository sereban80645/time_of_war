import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'dart:io';

@pragma('vm:entry-point')
void updateWidgetBackground() async {
  // Ця функція буде викликатись системою Android у фоні.
  // Сюди ми автоматично інтегруємо твою логіку перерахунку днів та збереження у віджет.
}

Future<void> configureWidgetAlarms(bool showHours) async {
  await AndroidAlarmManager.initialize();

  // Налаштування точного оновлення днів о 00:01
  final now = DateTime.now();
  var midnight = DateTime(now.year, now.month, now.day, 0, 1);
  if (now.isAfter(midnight)) {
    midnight = midnight.add(const Duration(days: 1));
  }

  await AndroidAlarmManager.periodic(
    const Duration(days: 1),
    0, // Унікальний ID для таймера днів
    updateWidgetBackground,
    startAt: midnight,
    exact: true,
    wakeup: true,
  );

  // Налаштування погодинного оновлення
  if (showHours) {
    await AndroidAlarmManager.periodic(
      const Duration(hours: 1),
      1, // Унікальний ID для таймера годин
      updateWidgetBackground,
      exact: true,
      wakeup: true,
    );
  } else {
    // Скасування погодинного оновлення
    await AndroidAlarmManager.cancel(1);
  }
}
