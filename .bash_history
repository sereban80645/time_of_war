    content = re.sub(r"(<ImageView[^>]*?android:layout_height=\")[^\"]+(\")", r"\g<1>match_parent\g<2>", content)
    
    # Налаштовуємо масштабування зображення на заповнення (fitXY)
    if "android:scaleType" in content:
        content = re.sub(r"android:scaleType=\"[^\"]+\"", "android:scaleType=\"fitXY\"", content)
    else:
        content = re.sub(r"(<ImageView)", r"\1\n    android:scaleType=\"fitXY\"", content)
        
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)

print("Нативні XML-файли віджета успішно оновлено!")
'
git add android/app/src/main/res/layout/
git commit -m "UI: stretch Android widget to fill entire launcher cell"
git push origin main
# 1. Переходимо в папку проєкту
cd time_of_war
# 2. Виконуємо скрипт (тепер він побачить шлях android/app/...)
python3 -c '
import glob, re

layouts = glob.glob("android/app/src/main/res/layout/*.xml")
for path in layouts:
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    
    content = re.sub(r"android:padding=\"[^\"]+\"", "android:padding=\"0dp\"", content)
    content = re.sub(r"android:layout_margin=\"[^\"]+\"", "android:layout_margin=\"0dp\"", content)
    
    content = re.sub(r"(<ImageView[^>]*?android:layout_width=\")[^\"]+(\")", r"\g<1>match_parent\g<2>", content)
    content = re.sub(r"(<ImageView[^>]*?android:layout_height=\")[^\"]+(\")", r"\g<1>match_parent\g<2>", content)
    
    if "android:scaleType" in content:
        content = re.sub(r"android:scaleType=\"[^\"]+\"", "android:scaleType=\"fitXY\"", content)
    else:
        content = re.sub(r"(<ImageView)", r"\1\n    android:scaleType=\"fitXY\"", content)
        
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)

print("Нативні XML-файли віджета успішно оновлено!")
'
# 3. Додаємо та відправляємо реальні зміни до репозиторію
git add android/app/src/main/res/layout/
git commit -m "UI: stretch Android widget to fill entire launcher cell"
git push origin main
python3 -c '
import glob, re

layouts = glob.glob("android/app/src/main/res/layout/*.xml")
if not layouts:
    print("XML-файли не знайдено. Перевірте структуру папок.")
else:
    for path in layouts:
        with open(path, "r", encoding="utf-8") as f:
            content = f.read()
        
        # Прибираємо відступи
        content = re.sub(r"android:padding=\"[^\"]+\"", "android:padding=\"0dp\"", content)
        content = re.sub(r"android:layout_margin=\"[^\"]+\"", "android:layout_margin=\"0dp\"", content)
        
        # Розтягуємо на весь екран
        content = re.sub(r"(<ImageView[^>]*?android:layout_width=\")[^\"]+(\")", r"\g<1>match_parent\g<2>", content)
        content = re.sub(r"(<ImageView[^>]*?android:layout_height=\")[^\"]+(\")", r"\g<1>match_parent\g<2>", content)
        
        # Задаємо масштабування fitXY
        if "android:scaleType" in content:
            content = re.sub(r"android:scaleType=\"[^\"]+\"", "android:scaleType=\"fitXY\"", content)
        else:
            content = re.sub(r"(<ImageView)", r"\1\n    android:scaleType=\"fitXY\"", content)
            
        with open(path, "w", encoding="utf-8") as f:
            f.write(content)

    print("Нативні XML-файли віджета успішно оновлено!")
'
git add android/app/src/main/res/layout/
git commit -m "UI: stretch Android widget to fill entire launcher cell"
git push origin main
cat android/app/src/main/res/layout/*.xml
echo "---"
cat android/app/src/main/res/xml/*.xml
python3 -c '
import re

path = "lib/main.dart"
with open(path, "r", encoding="utf-8") as f:
    code = f.read()

# 1. Робимо ширину гумовою (double.infinity)
code = re.sub(r"width:\s*\d+\.0?,", "width: double.infinity, height: double.infinity,", code)
code = re.sub(r"width:\s*\d+,", "width: double.infinity, height: double.infinity,", code)

# 2. Змінюємо квадратний рендер на широкий (800x350)
code = re.sub(r"logicalSize:\s*const\s*Size\([^\)]+\)", "logicalSize: const Size(800, 350)", code)
code = re.sub(r"logicalSize:\s*Size\([^\)]+\)", "logicalSize: const Size(800, 350)", code)

# 3. Прибираємо зайві відступи навколо фону
code = re.sub(r"padding:\s*const\s*EdgeInsets\.symmetric\([^\)]+\),", "padding: const EdgeInsets.all(0),", code)

with open(path, "w", encoding="utf-8") as f:
    f.write(code)

print("Розміри віджета успішно оптимізовані у lib/main.dart!")
'
git add lib/main.dart
git commit -m "UI: stretch widget to fill entire frame and update aspect ratio"
git push origin main
# 1. Відновлюємо робочу версію main.dart
git checkout HEAD~1 lib/main.dart
# 2. Безпечно виправляємо ТІЛЬКИ пропорції рендеру віджета
python3 -c '
path = "lib/main.dart"
with open(path, "r", encoding="utf-8") as f:
    code = f.read()

# Змінюємо квадратний рендер 400x400 на широкий прямокутник 800x400
code = code.replace("const Size(400, 400)", "const Size(800, 400)")
code = code.replace("Size(400, 400)", "Size(800, 400)")

with open(path, "w", encoding="utf-8") as f:
    f.write(code)

print("Інтерфейс налаштувань відновлено, а віджет переведено у формат 800x400!")
'
# 3. Відправляємо виправлення на GitHub
git add lib/main.dart
git commit -m "Fix settings UI crash and safely set widget render resolution to 800x400"
git push origin main --force
python3 -c '
import os, re

# 1. Створюємо файли ресурсів Android для вимкнення системних відступів Android 12+
os.makedirs("android/app/src/main/res/values", exist_ok=True)
os.makedirs("android/app/src/main/res/values-v31", exist_ok=True)

with open("android/app/src/main/res/values-v31/dimens.xml", "w", encoding="utf-8") as f:
    f.write("""<?xml version="1.0" encoding="utf-8"?>
<resources>
    <dimen name="system_app_widget_internal_padding">0dp</dimen>
</resources>""")

with open("android/app/src/main/res/values/dimens.xml", "w", encoding="utf-8") as f:
    f.write("""<?xml version="1.0" encoding="utf-8"?>
<resources>
    <dimen name="app_widget_margin">0dp</dimen>
</resources>""")

# 2. Оновлюємо lib/main.dart: прибираємо порожні поля навколо фону віджета
path = "lib/main.dart"
with open(path, "r", encoding="utf-8") as f:
    code = f.read()

# Зменшуємо внутрішні відступи з 40px/24px до 8px (щоб фон розтягувався до самого краю)
code = re.sub(r"EdgeInsets\.symmetric\(vertical:\s*\d+(\.\d+)?,?\s*horizontal:\s*\d+(\.\d+)?\)", "EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0)", code)
code = re.sub(r"EdgeInsets\.all\(\s*(40|32|24|20)\.0?\s*\)", "EdgeInsets.all(8.0)", code)

# Зменшуємо радіус заокруглення кутів з 56 до 16 для акуратного вписування в рамку
code = re.sub(r"BorderRadius\.circular\((56|40|32|28)\)", "BorderRadius.circular(16)", code)

# Задаємо пропорції рендеру 800x360
code = re.sub(r"logicalSize:\s*(const\s*)?Size\(\s*\d+(\.\d+)?\s*,\s*\d+(\.\d+)?\s*\)", "logicalSize: const Size(800, 360)", code)

with open(path, "w", encoding="utf-8") as f:
    f.write(code)

print("Всі системні та внутрішні відступи успішно виправлено!")
'
# 3. Відправляємо зміни на GitHub
git add lib/main.dart android/app/src/main/res/
git commit -m "Fix: remove widget internal paddings and Android 12 margins to fill launcher cell"
git push origin main
python3 -c '
import re

path = "lib/main.dart"
with open(path, "r", encoding="utf-8") as f:
    code = f.read()

# 1. Прибираємо всі зовнішні margin у віджета
code = re.sub(r"margin:\s*EdgeInsets\.[^,\)\n]+(\([^\)]*\))?", "margin: EdgeInsets.zero", code)

# 2. Встановлюємо режим розтягування фонового зображення на весь контейнер (BoxFit.fill)
if "fit: BoxFit." in code:
    code = re.sub(r"fit:\s*BoxFit\.[a-zA-Z]+", "fit: BoxFit.fill", code)
else:
    code = re.sub(r"(DecorationImage\s*\()", r"\1fit: BoxFit.fill, ", code)

# 3. Встановлюємо пропорції прямокутника 800x400
code = re.sub(r"logicalSize:\s*(const\s*)?Size\([^\)]+\)", "logicalSize: const Size(800, 400)", code)

with open(path, "w", encoding="utf-8") as f:
    f.write(code)

print("Фон віджета успішно переведено в режим BoxFit.fill без відступів!")
'
git add lib/main.dart
git commit -m "UI: stretch widget background image to 100% full width and height with BoxFit.fill"
git push origin main
python3 -c '
import re

path = "lib/main.dart"
with open(path, "r", encoding="utf-8") as f:
    code = f.read()

# 1. Фіксуємо розмір кореневого контейнера віджета на 800x400
# Шукаємо Container/SizedBox, який рендерить віджет, і задаємо точні фіксовані параметри
code = re.sub(
    r"(Widget\s+buildWidget[^\{]+\{[\s\S]*?return\s+)(Container|SizedBox)\(",
    r"\1SizedBox(\n      width: 800.0,\n      height: 400.0,\n      child: \2(",
    code
)

# Якщо використовується окремий метод або макет для віджета, перевіряємо наявність SizedBox з фіксованими розмірами
if "width: 800.0" not in code:
    code = re.sub(
        r"(Container\(\s*width:\s*double\.infinity)",
        r"Container(width: 800.0, height: 400.0",
        code
    )

with open(path, "w", encoding="utf-8") as f:
    f.write(code)

print("Розміри полотна віджета зафіксовано на 800x400!")
'
git add lib/main.dart
git commit -m "UI: lock widget canvas size to 800x400 so font size changes only scale text inside fixed background"
git push origin main
cat lib/main.dart | grep -n -B 2 -A 15 "BoxDecoration"
python3 -c '
path = "lib/main.dart"
with open(path, "r", encoding="utf-8") as f:
    code = f.read()

# Прив'язуємо колір фону bgColor незалежно від наявності зображення
code = code.replace("color: imagePath == null ? bgColor : null,", "color: bgColor,")
code = code.replace("color: _imagePath == null ? bgColor : null,", "color: bgColor,")
with open(path, "w", encoding="utf-8") as f:
print("Колір фону з повзунків успішно активовано!")
'

git add lib/main.dart
git commit -m "Fix: enable background color sliders under image layer"
git push origin main
cat << 'EOF' > fix_color.py
path = "lib/main.dart"
with open(path, "r", encoding="utf-8") as f:
    code = f.read()

code = code.replace("color: imagePath == null ? bgColor : null,", "color: bgColor,")
code = code.replace("color: _imagePath == null ? bgColor : null,", "color: bgColor,")

with open(path, "w", encoding="utf-8") as f:
    f.write(code)

print("Колір фону з повзунків успішно активовано!")
EOF

python3 fix_color.py && rm fix_color.py

git add lib/main.dart
git commit -m "Fix: enable background color sliders under image layer"
git push origin main
git status && git log -1
git add lib/main.dart
git commit -m "Fix: enable background color sliders under image layer"
git push origin main
sed -i 's/color: imagePath == null ? bgColor : null,/color: bgColor,/g' lib/main.dart
sed -i 's/color: _imagePath == null ? bgColor : null,/color: bgColor,/g' lib/main.dart
git add lib/main.dart && git commit -m "Fix: enable background color under image" && git push origin main
cat lib/main.dart | grep -n -A 5 "DateTime(20" && echo "---" && cat lib/main.dart | grep -n -B 2 -A 2 "хв"
cat << 'EOF' > fix_times.py
path = "lib/main.dart"
with open(path, "r", encoding="utf-8") as f:
    code = f.read()

# 1. Синхронізуємо час для 2022 року в UI (05:00 -> 02:40)
code = code.replace("DateTime(2022, 2, 24, 5, 0)", "DateTime(2022, 2, 24, 2, 40)")

# 2. Виправляємо фонове оновлення віджета для 2022 року (00:00:00 -> 02:40:00)
code = code.replace("DateTime(2022, 2, 24, 0, 0, 0)", "DateTime(2022, 2, 24, 2, 40, 0)")

# 3. Виправляємо фонове оновлення віджета для 2014 року (щоб теж було 12:00:00 замість 00:00:00)
code = code.replace("DateTime(2014, 2, 20, 0, 0, 0)", "DateTime(2014, 2, 20, 12, 0, 0)")

with open(path, "w", encoding="utf-8") as f:
    f.write(code)

print("Час для 2022 року (02:40) та 2014 року (12:00) успішно застосовано!")
EOF

python3 fix_times.py && rm fix_times.py
git add lib/main.dart
git commit -m "Fix: set exact start times (2022 to 02:40, 2014 to 12:00) for UI and widget"
git push origin main
cat lib/main.dart | grep -n -A 25 "String _calculateTimeDifference"
cat << 'EOF' > fix_calc.py
import re

path = "lib/main.dart"
with open(path, "r", encoding="utf-8") as f:
    code = f.read()

new_calc = '''  String _calculateTimeDifference(DateTime startDate) {
    final now = DateTime.now();

    if (_showDaysOnly) {
      final difference = now.difference(startDate);
      int totalDays = difference.inDays;
      int hours = now.hour - startDate.hour;
      int minutes = now.minute - startDate.minute;
      if (minutes < 0) hours--;
      if (hours < 0) hours += 24;

      String output = "${totalDays}д.";
      if (_showHour) output += " ${hours}г.";
      return output;
    } else {
      int years = now.year - startDate.year;
      int months = now.month - startDate.month;
      int days = now.day - startDate.day;
      int hours = now.hour - startDate.hour;
      int minutes = now.minute - startDate.minute;

      if (minutes < 0) {
        hours--;
        minutes += 60;
      }
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

      return "${years}р. ${months}міс. ${days}д. ${hours}г.";
    }
  }'''

code = re.sub(
    r'String\s+_calculateTimeDifference\s*\([^)]*\)\s*\{[\s\S]*?\n  \}',
    new_calc,
    code
)

with open(path, "w", encoding="utf-8") as f:
    f.write(code)

print("Математику розрахунку виправлено (хвилини враховуються, але приховані)!")
EOF

python3 fix_calc.py && rm fix_calc.py
git add lib/main.dart
git commit -m "Fix: account for minutes in _calculateTimeDifference math without displaying them"
git push origin main
cat lib/main.dart | grep -n -B 4 -A 6 "saveWidgetData" && echo "---" && cat lib/main.dart | grep -n -A 30 "calculateTimeDifference"
cat << 'EOF' > fix_all.py
import re

path = "lib/main.dart"
with open(path, "r", encoding="utf-8") as f:
    code = f.read()

# 1. Створюємо єдину точну глобальну функцію
global_func = '''
String getGlobalAccurateTime(DateTime startDate, bool showDaysOnly, bool showHour) {
  final n = DateTime.now();
  if (showDaysOnly) {
    int totalDays = n.difference(startDate).inDays;
    int hours = n.hour - startDate.hour;
    int minutes = n.minute - startDate.minute;
    if (minutes < 0) hours--;
    if (hours < 0) hours += 24;
    String out = "${totalDays}д.";
    if (showHour) out += " ${hours}г.";
    return out;
  } else {
    int years = n.year - startDate.year;
    int months = n.month - startDate.month;
    int days = n.day - startDate.day;
    int hours = n.hour - startDate.hour;
    int minutes = n.minute - startDate.minute;
    if (minutes < 0) { hours--; minutes += 60; }
    if (hours < 0) { days--; hours += 24; }
    if (days < 0) { months--; final pMonth = DateTime(n.year, n.month, 0); days += pMonth.day; }
    if (months < 0) { years--; months += 12; }
    return "${years}р. ${months}міс. ${days}д. ${hours}г.";
  }
}
'''
if "String getGlobalAccurateTime" not in code:
    code = code.replace("void main()", global_func + "\nvoid main()")

# 2. Виправляємо перший фоновий сервіс (рядки 17-22)
code = re.sub(
    r'final diff2022 = now\.difference[^;]+;\s*final diff2014 = now\.difference[^;]+;\s*await HomeWidget\.saveWidgetData\(\'text_2022\',[^;]+;\s*await HomeWidget\.saveWidgetData\(\'text_2014\',[^;]+;',
    '''final prefs = await SharedPreferences.getInstance();
    bool dO = prefs.getBool('showDaysOnly') ?? false;
    bool sh = prefs.getBool('showHour') ?? true;
    await HomeWidget.saveWidgetData('text_2022', getGlobalAccurateTime(DateTime(2022, 2, 24, 2, 40), dO, sh));
    await HomeWidget.saveWidgetData('text_2014', getGlobalAccurateTime(DateTime(2014, 2, 20, 12, 0), dO, sh));''',
    code
)

# 3. Виправляємо другий фоновий цикл із "Regex милицями" (рядки 528-541)
code = code.replace(
    r"String newVal = val.replaceAll(RegExp(r'\d+г\.'), '${h2014}г.');",
    "bool dO = prefs.getBool('showDaysOnly') ?? false; bool sh = prefs.getBool('showHour') ?? true; String newVal = getGlobalAccurateTime(DateTime(2014, 2, 20, 12, 0), dO, sh);"
)
code = code.replace(
    r"String newVal = val.replaceAll(RegExp(r'\d+г\.'), '${h2022}г.');",
    "bool dO = prefs.getBool('showDaysOnly') ?? false; bool sh = prefs.getBool('showHour') ?? true; String newVal = getGlobalAccurateTime(DateTime(2022, 2, 24, 2, 40), dO, sh);"
)

# 4. Переводимо UI на використання глобальної функції (видаляємо стару дубльовану логіку)
code = re.sub(
    r'String\s+_calculateTimeDifference\s*\([^)]*\)\s*\{[\s\S]*?return\s+"[^"]+";\s*\}\s*\}',
    '''String _calculateTimeDifference(DateTime startDate) {
    return getGlobalAccurateTime(startDate, _showDaysOnly, _showHour);
  }''',
    code
)

with open(path, "w", encoding="utf-8") as f:
    f.write(code)

print("Успіх! Усі алгоритми синхронізовано!")
EOF

python3 fix_all.py && rm fix_all.py
git add lib/main.dart
git commit -m "Fix: unify exact time calculation globally for UI and all background workers"
git push origin main
git show HEAD
cat lib/main.dart | grep -n -A 20 "void callbackDispatcher" && echo "---" && cat lib/main.dart | grep -n -A 15 "void main"
cat << 'EOF' > fix_smart_schedule.py
import re

path = "lib/main.dart"
with open(path, "r", encoding="utf-8") as f:
    code = f.read()

# 1. Задаємо 1 годину для періодичного оновлення Workmanager (коли увімкнено години)
code = re.sub(
    r'frequency:\s*const\s*Duration\([^)]+\)',
    'frequency: const Duration(hours: 1)',
    code
)

# 2. Налаштовуємо точні щоденні спрацьовування в AlarmManager (о 02:40 та 12:00)
alarm_setup = '''
  await AndroidAlarmManager.initialize();
  DateTime now = DateTime.now();

  // Точний час зміни дня для 2022 року (02:40)
  DateTime next2022 = DateTime(now.year, now.month, now.day, 2, 40);
  if (now.isAfter(next2022)) next2022 = next2022.add(const Duration(days: 1));

  // Точний час зміни дня для 2014 року (12:00)
  DateTime next2014 = DateTime(now.year, now.month, now.day, 12, 0);
  if (now.isAfter(next2014)) next2014 = next2014.add(const Duration(days: 1));

  await AndroidAlarmManager.periodic(const Duration(days: 1), 101, callbackDispatcher, startAt: next2022, exact: true, wakeup: true);
  await AndroidAlarmManager.periodic(const Duration(days: 1), 102, callbackDispatcher, startAt: next2014, exact: true, wakeup: true);
'''

# Замінюємо старий запуск AlarmManager на новий розклад
code = re.sub(
    r'await\s+AndroidAlarmManager\.initialize\(\);[\s\S]*?await\s+AndroidAlarmManager\.periodic[^;]+;',
    alarm_setup.strip(),
    code
)

with open(path, "w", encoding="utf-8") as f:
    f.write(code)

print("Розумний розклад успішно застосовано (1г для годин, 02:40 та 12:00 для днів)!")
EOF

python3 fix_smart_schedule.py && rm fix_smart_schedule.py
git add lib/main.dart
git commit -m "Optimize: set 1h update interval and exact alarms at 02:40 and 12:00"
git push origin main
adb logcat | grep -E -i "flutter|time_of_war|widget"
git status
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
python fix_timer_bg.py
git diff
proot-distro login ubuntu
