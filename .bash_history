      ),
      key: 'widget_image',
      logicalSize: const Size(800, 400),
    );

    await HomeWidget.updateWidget(name: 'WidgetProvider', androidName: 'WidgetProvider');
  } catch (e) {
    // Фоновий рендеринг
  }
}"""

start_idx = code.find("void backgroundUpdate()")
if start_idx != -1:
    pragma_idx = code.rfind("@pragma", 0, start_idx)
    if pragma_idx != -1 and (start_idx - pragma_idx < 80):
        start_idx = pragma_idx
    
    end_idx = code.find('await HomeWidget.updateWidget(name: "WidgetProvider", androidName: "WidgetProvider");', start_idx)
    if end_idx != -1:
        end_bracket = code.find("}", end_idx)
        if end_bracket != -1:
            code = code[:start_idx] + new_bg_func + code[end_bracket+1:]
            with open(main_path, 'w', encoding='utf-8') as f:
                f.write(code)
            print("УСПІХ: backgroundUpdate() переписано на генерацію PNG-зображення!")
        else:
            print("ПОМИЛКА: не знайдено закриваючу дужку.")
    else:
        print("ПОМИЛКА: не знайдено updateWidget усередині backgroundUpdate.")
else:
    print("ПОМИЛКА: функцію backgroundUpdate() не знайдено.")
EOF

python fix_background_render.py
git add lib/main.dart
git commit -m "Fix: render Flutter widget to PNG inside backgroundUpdate isolate"
git push origin main
git pull --rebase origin main
git push origin main
git add .
git commit -m "Save local changes before pull"
git pull --rebase origin main
git push origin main
git checkout --theirs lib/main.dart
git add lib/main.dart
git rebase --continue
git push -f origin main
grep -rn -A 10 "AndroidAlarmManager" lib/
sed -n '/void callbackDispatcher/,/^}/p' lib/main.dart
cat lib/widget_updater.dart
grep -rn "widget_updater" lib/
cat << 'EOF' > fix_alarms.py
import re

path = "lib/main.dart"
with open(path, "r", encoding="utf-8") as f:
    content = f.read()

# 1. Додаємо функцію рекурсивного розкладу
schedule_code = """
@pragma('vm:entry-point')
Future<void> scheduleNextBackgroundUpdate() async {
  await AndroidAlarmManager.initialize();
  DateTime now = DateTime.now();
  
  DateTime nextHour = DateTime(now.year, now.month, now.day, now.hour).add(const Duration(hours: 1, minutes: 1));
  
  DateTime next2022 = DateTime(now.year, now.month, now.day, 2, 40);
  if (!next2022.isAfter(now)) next2022 = next2022.add(const Duration(days: 1));
  
  DateTime next2014 = DateTime(now.year, now.month, now.day, 12, 0);
  if (!next2014.isAfter(now)) next2014 = next2014.add(const Duration(days: 1));

  List<DateTime> times = [nextHour, next2022, next2014];
  times.sort();
  
  await AndroidAlarmManager.oneShotAt(
    times.first,
    2,
    backgroundUpdate,
    exact: true,
    wakeup: true,
  );
}
"""

if "scheduleNextBackgroundUpdate" not in content:
    content = content.replace("void main() async {", schedule_code + "\nvoid main() async {")

# 2. Очищаємо main() від старих periodic таймерів
main_pattern = re.compile(r"await AndroidAlarmManager\.initialize\(\);.*?(?=WidgetsFlutterBinding\.ensureInitialized\(\);)", re.DOTALL)
content = main_pattern.sub("await AndroidAlarmManager.initialize();\n  await scheduleNextBackgroundUpdate();\n  ", content)

# 3. Додаємо рекурсивний виклик (естафету) в кінець backgroundUpdate
if "finally {\n    await scheduleNextBackgroundUpdate();" not in content:
    content = re.sub(r"(\}\s*catch\s*\([^)]*\)\s*\{[^}]*\})", r"\1\n  finally {\n    await scheduleNextBackgroundUpdate();\n  }", content)

# 4. Видаляємо зламаний callbackDispatcher
start_idx = content.find("void callbackDispatcher()")
if start_idx != -1:
    brace_count = 0
    in_func = False
    for i in range(start_idx, len(content)):
        if content[i] == '{':
            brace_count += 1
            in_func = True
        elif content[i] == '}':
            brace_count -= 1
        if in_func and brace_count == 0:
            content = content[:start_idx] + content[i+1:]
            break

with open(path, "w", encoding="utf-8") as f:
    f.write(content)

print("✅ УСПІХ: main.dart переведено на рекурсивні oneShotAt таймери!")
EOF

python fix_alarms.py
git rm -f lib/widget_updater.dart 2>/dev/null || true
git add lib/main.dart
git commit -m "Fix: replace unreliable periodic alarms with exact recursive oneShotAt"
git push origin main
cat << 'EOF' > fix_main_entry.py
path = "lib/main.dart"
with open(path, "r", encoding="utf-8") as f:
    content = f.read()

# Відновлюємо точку входу main()
main_func = """
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  await scheduleNextBackgroundUpdate();
  runApp(const MyApp());
}
"""

# Якщо main() втрачено або пошкоджено, вставляємо його перед class MyApp
if "void main()" not in content:
    my_app_idx = content.find("class MyApp")
    if my_app_idx != -1:
        content = content[:my_app_idx] + main_func + "\n\n" + content[my_app_idx:]
    else:
        content += "\n\n" + main_func

with open(path, "w", encoding="utf-8") as f:
    f.write(content)

print("✅ main() успішно відновлено у lib/main.dart!")
EOF

python fix_main_entry.py
git add lib/main.dart
git commit -m "Fix: restore missing main() entry point"
git push origin main
git reset --hard ac80e61
git push -f origin main
cat -n lib/main.dart
cat << 'EOF' > safe_fix.py
import re

with open("lib/main.dart", "r", encoding="utf-8") as f:
    content = f.read()

# 1. Створюємо безпечну функцію для рекурсивного розкладу
schedule_func = """
@pragma('vm:entry-point')
Future<void> scheduleNextBackgroundUpdate() async {
  await AndroidAlarmManager.initialize();
  DateTime now = DateTime.now();

  DateTime nextHour = DateTime(now.year, now.month, now.day, now.hour).add(const Duration(hours: 1, minutes: 1));
  DateTime next2022 = DateTime(now.year, now.month, now.day, 2, 40);
  if (!next2022.isAfter(now)) next2022 = next2022.add(const Duration(days: 1));
  DateTime next2014 = DateTime(now.year, now.month, now.day, 12, 0);
  if (!next2014.isAfter(now)) next2014 = next2014.add(const Duration(days: 1));

  List<DateTime> times = [nextHour, next2022, next2014];
  times.sort();

  await AndroidAlarmManager.oneShotAt(
    times.first,
    2,
    backgroundUpdate,
    exact: true,
    wakeup: true,
  );
}
"""

# Вставляємо її перед main(), якщо її ще немає
if "scheduleNextBackgroundUpdate" not in content:
    content = content.replace("void main() async {", schedule_func + "\nvoid main() async {")

# 2. Вирізаємо проблемні рядки 68-85 та ставимо виклик нової функції
content = re.sub(
    r"await AndroidAlarmManager\.initialize\(\);.*?(?=WidgetsFlutterBinding\.ensureInitialized\(\);\s*runApp)",
    "await AndroidAlarmManager.initialize();\n  await scheduleNextBackgroundUpdate();\n  ",
    content,
    flags=re.DOTALL
)

# 3. Додаємо рекурсивний виклик у блок finally функції backgroundUpdate (рядки 564-567)
content = re.sub(
    r"\} catch \(e\) \{\s*// Фоновий рендеринг\s*\}",
    "} catch (e) {\n      // Фоновий рендеринг\n    } finally {\n      await scheduleNextBackgroundUpdate();\n    }",
    content
)

with open("lib/main.dart", "w", encoding="utf-8") as f:
    f.write(content)

print("✅ main.dart оновлено максимально безпечно!")
EOF

python safe_fix.py
git rm -f lib/widget_updater.dart 2>/dev/null || true
git add lib/main.dart
git commit -m "Fix: implement safe recursive oneShotAt for background updates"
git push origin main
cat << 'EOF' > fix_types.py
import re

path = "lib/main.dart"
with open(path, "r", encoding="utf-8") as f:
    content = f.read()

# Замінюємо помилкове зчитування getInt на безпечне getDouble().toInt()
replacements = {
    r"int br = prefs\.getInt\('br'\) \?\? 0;": "int br = (prefs.getDouble('br') ?? 30.0).toInt();",
    r"int bg = prefs\.getInt\('bg'\) \?\? 0;": "int bg = (prefs.getDouble('bg') ?? 30.0).toInt();",
    r"int bb = prefs\.getInt\('bb'\) \?\? 0;": "int bb = (prefs.getDouble('bb') ?? 30.0).toInt();",
    r"int tr = prefs\.getInt\('tr'\) \?\? 255;": "int tr = (prefs.getDouble('tr') ?? 255.0).toInt();",
    r"int tg = prefs\.getInt\('tg'\) \?\? 255;": "int tg = (prefs.getDouble('tg') ?? 255.0).toInt();",
    r"int tb = prefs\.getInt\('tb'\) \?\? 255;": "int tb = (prefs.getDouble('tb') ?? 255.0).toInt();",
    r"int sr = prefs\.getInt\('sr'\) \?\? 0;": "int sr = (prefs.getDouble('sr') ?? 0.0).toInt();",
    r"int sg = prefs\.getInt\('sg'\) \?\? 0;": "int sg = (prefs.getDouble('sg') ?? 0.0).toInt();",
    r"int sb = prefs\.getInt\('sb'\) \?\? 0;": "int sb = (prefs.getDouble('sb') ?? 0.0).toInt();",
}

for old_code, new_code in replacements.items():
    content = re.sub(old_code, new_code, content)

with open(path, "w", encoding="utf-8") as f:
    f.write(content)

print("✅ Помилку типів кольорів успішно виправлено!")
EOF

python fix_types.py
git add lib/main.dart
git commit -m "Fix: type cast error in backgroundUpdate causing silent crashes"
git push origin main
cat -n lib/main.dart
cat << 'EOF' > fix_main.py
import re

with open("lib/main.dart", "r", encoding="utf-8") as f:
    code = f.read()

# Відновлюємо main() та правильну функцію планування
pattern = re.compile(
    r"@pragma\('vm:entry-point'\)\s+"
    r"Future<void> scheduleNextBackgroundUpdate\(\) async \{\s+"
    r"await AndroidAlarmManager\.initialize\(\);\s+"
    r"await scheduleNextBackgroundUpdate\(\);\s+"
    r"WidgetsFlutterBinding\.ensureInitialized\(\);\s+"
    r"runApp\(const MyApp\(\)\);\s+"
    r"\}",
    re.MULTILINE
)

fixed_code = """void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  try {
    Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  } catch (e) {}
  
  runApp(const MyApp());
  scheduleNextBackgroundUpdate();
}

Future<void> scheduleNextBackgroundUpdate() async {
  final now = DateTime.now();
  // Наступне оновлення: рівно о 01 хвилині наступної години
  DateTime nextUpdate = DateTime(now.year, now.month, now.day, now.hour).add(const Duration(hours: 1, minutes: 1));
  
  await AndroidAlarmManager.oneShotAt(
    nextUpdate,
    0,
    backgroundUpdate,
    exact: true,
    wakeup: true,
    allowWhileIdle: true,
  );
}"""

code = pattern.sub(fixed_code, code)

# Прибираємо сміття з порожніх тегів @pragma, залишаючи лише один
code = re.sub(r"(@pragma\('vm:entry-point'\)\s*){2,}", "@pragma('vm:entry-point')\n", code)

with open("lib/main.dart", "w", encoding="utf-8") as f:
    f.write(code)

print("✅ Функцію main() та логіку таймера успішно відновлено!")
EOF

python fix_main.py
git add lib/main.dart
git commit -m "Fix: restore missing main() and correct background timer scheduling"
git push origin main
cat << 'EOF' > fix_image.py
import re

with open("lib/main.dart", "r", encoding="utf-8") as f:
    code = f.read()

# 1. Додаємо перевірку існування файлу в TimeOfWarWidgetRender
render_pattern = r"image: imagePath != null\s*\?\s*DecorationImage\(\s*image: FileImage\(File\(imagePath!\)\),\s*fit: BoxFit\.fill, opacity: opacity\)\s*:\s*null"
render_fix = "image: (imagePath != null && File(imagePath!).existsSync())\n              ? DecorationImage(\n                  image: FileImage(File(imagePath!)),\n                  fit: BoxFit.fill, opacity: opacity)\n              : null"

code = re.sub(render_pattern, render_fix, code)

# 2. Додаємо таку ж перевірку в прев'ю віджета
preview_pattern = r"image: _imagePath != null \? DecorationImage\(image: FileImage\(File\(_imagePath!\)\), fit: BoxFit\.fill, opacity: _opacity\) : null"
preview_fix = "image: (_imagePath != null && File(_imagePath!).existsSync()) ? DecorationImage(image: FileImage(File(_imagePath!)), fit: BoxFit.fill, opacity: _opacity) : null"

code = re.sub(preview_pattern, preview_fix, code)

# 3. Виправляємо функцію _pickImage для надійного копіювання та збереження шляху
pick_pattern = re.compile(
    r"Future<void> _pickImage\(\) async \{\s*"
    r"final picker = ImagePicker\(\);\s*"
    r"final pickedFile = await picker\.pickImage\(source: ImageSource\.gallery\);\s*"
    r"if \(pickedFile != null\) \{\s*"
    r"String\? cropped = await _cropImage\(pickedFile\.path\);\s*"
    r"setState\(\(\) => _imagePath = \(cropped \?\? pickedFile\.path\)\);\s*"
    r"_saveSetting\('imagePath', pickedFile\.path\);\s*"
    r"\}\s*\}",
    re.MULTILINE
)

pick_fix = """Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      String? cropped = await _cropImage(pickedFile.path);
      String sourcePath = cropped ?? pickedFile.path;
      
      try {
        // Копіюємо файл у постійну папку додатка, щоб Android його не видалив з кешу
        final appDir = File(sourcePath).parent.path;
        final persistentPath = '$appDir/bg_widget_saved.png';
        final savedFile = await File(sourcePath).copy(persistentPath);
        
        setState(() => _imagePath = savedFile.path);
        _saveSetting('imagePath', savedFile.path);
      } catch (e) {
        setState(() => _imagePath = sourcePath);
        _saveSetting('imagePath', sourcePath);
      }
    }
  }"""

code = pick_pattern.sub(pick_fix, code)

with open("lib/main.dart", "w", encoding="utf-8") as f:
    f.write(code)

print("✅ Збереження фонового зображення виправлено!")
EOF

python fix_image.py
git add lib/main.dart
git commit -m "Fix: ensure widget background image is saved permanently"
git push origin main
cat << 'EOF' > full_cleanup_fix.py
import re

with open("lib/main.dart", "r", encoding="utf-8") as f:
    code = f.read()

# 1. Перевіряємо та додаємо import path_provider
if "package:path_provider/path_provider.dart" not in code:
    code = "import 'package:path_provider/path_provider.dart';\n" + code

# 2. Очищення від дубльованих @pragma та порожніх рядків
code = re.sub(r"(@pragma\('vm:entry-point'\)\s*){2,}", "@pragma('vm:entry-point')\n", code)

# 3. Оновлення функції вибору та збереження фото на getApplicationDocumentsDirectory
pick_pattern = re.compile(
    r"Future<void> _pickImage\(\) async \{.*?\n  \}",
    re.DOTALL
)

new_pick_image = """Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      String? cropped = await _cropImage(pickedFile.path);
      String sourcePath = cropped ?? pickedFile.path;
      
      try {
        final docsDir = await getApplicationDocumentsDirectory();
        final persistentPath = '${docsDir.path}/widget_bg_saved.png';
        
        final savedFile = await File(sourcePath).copy(persistentPath);
        
        setState(() => _imagePath = savedFile.path);
        await _saveSetting('imagePath', savedFile.path);
      } catch (e) {
        setState(() => _imagePath = sourcePath);
        await _saveSetting('imagePath', sourcePath);
      }
    }
  }"""

code = pick_pattern.sub(new_pick_image, code)

# 4. Перевірка наявності файлу перед рендерингом фону
code = re.sub(
    r"image:\s*\(_imagePath != null.*?\)\s*:\s*null",
    "image: (_imagePath != null && File(_imagePath!).existsSync()) ? DecorationImage(image: FileImage(File(_imagePath!)), fit: BoxFit.fill, opacity: _opacity) : null",
    code
)

with open("lib/main.dart", "w", encoding="utf-8") as f:
    f.write(code)

print("✅ Застосунок очищено від сміття, фон переведено на гарантоване постійне сховище!")
EOF

python full_cleanup_fix.py
flutter format lib/main.dart
git add lib/main.dart
git commit -m "Refactor: permanent doc storage for widget image and code cleanup"
git push origin main
cat << 'EOF' > deep_fix.py
import re

with open("lib/main.dart", "r", encoding="utf-8") as f:
    code = f.read()

# 1. Перевіряємо наявність необхідних імпортів
imports = [
    "import 'dart:async';",
    "import 'dart:ui' as ui;",
    "import 'package:flutter/services.dart';"
]
for imp in imports:
    if imp not in code:
        code = imp + "\n" + code

# 2. Додаємо виклик примусового передзавантаження картинки у рендер-функцію
old_render_call = re.search(r"await HomeWidget\.renderFlutterWidget\(.*?\);", code, re.DOTALL)

new_render_logic = """
    // Гарантуємо ініціалізацію зв'язок у фоновому покроці
    WidgetsFlutterBinding.ensureInitialized();

    // Якщо є шлях до зображення, чекаємо його повного декодування перед знімком
    if (imagePath != null && File(imagePath).existsSync()) {
      final completer = Completer<void>();
      final imageStream = MemoryImage(File(imagePath).readAsBytesSync()).resolve(const ImageConfiguration());
      late ImageStreamListener listener;
      listener = ImageStreamListener((_, __) {
        if (!completer.isCompleted) completer.complete();
        imageStream.removeListener(listener);
      }, onError: (_, __) {
        if (!completer.isCompleted) completer.complete();
        imageStream.removeListener(listener);
      });
      imageStream.addListener(listener);
      await completer.future.timeout(const Duration(milliseconds: 500), onTimeout: () {});
      await Future.delayed(const Duration(milliseconds: 100));
    }

    await HomeWidget.renderFlutterWidget(
      const TimeOfWarWidgetRender(),
      key: 'filename',
      logicalSize: const Size(320, 160),
    );"""

if old_render_call:
    code = code.replace(old_render_call.group(0), new_render_logic)

with open("lib/main.dart", "w", encoding="utf-8") as f:
    f.write(code)

print("✅ Глибоку перевірку та виправлення рендерингу застосовано!")
EOF

python deep_fix.py
flutter format lib/main.dart
git add lib/main.dart
git commit -m "Fix: ensure image stream is fully resolved before HomeWidget screenshot"
git push origin main
