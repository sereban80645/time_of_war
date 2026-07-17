version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.5.5
  home_widget: ^0.9.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_launcher_icons: ^0.14.1

flutter:
  uses-material-design: true
  assets:
    - assets/icon.png

flutter_launcher_icons:
  android: "launcher_icon"
  image_path: "assets/icon.png"
  min_sdk_android: 21
EOF

# 2. Відновлюємо логіку налаштувань у lib/settings_page.dart
cat << 'EOF' > lib/settings_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_widget/home_widget.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ValueNotifier<bool> _showOrdinalDay = ValueNotifier<bool>(true);
  final ValueNotifier<String> _startDate = ValueNotifier<String>('24 лютого 2022 05:00');
  final ValueNotifier<String> _theme = ValueNotifier<String>('Військова');

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _showOrdinalDay.value = prefs.getBool('show_ordinal_day') ?? true;
    _startDate.value = prefs.getString('start_date') ?? '24 лютого 2022 05:00';
    _theme.value = prefs.getString('theme') ?? 'Військова';
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
      await HomeWidget.saveWidgetData<bool>(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
      await HomeWidget.saveWidgetData<String>(key, value);
    }
    await HomeWidget.updateWidget(name: 'AppWidgetProvider', androidName: 'AppWidgetProvider');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Налаштування Time_of_waR', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A1A1A),
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFF121212),
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: _showOrdinalDay,
              builder: (context, isOrdinal, child) {
                return SwitchListTile(
                  title: const Text('Формат відліку', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                  subtitle: Text(
                    isOrdinal ? 'Поточний день події (напр. День 1587)' : 'Загальний пройдений час',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  value: isOrdinal,
                  activeColor: const Color(0xFF2196F3),
                  onChanged: (value) {
                    _showOrdinalDay.value = value;
                    _updateSetting('show_ordinal_day', value);
                  },
                );
              },
            ),
            const Divider(color: Color(0xFF2A2A2A), height: 32),
            ValueListenableBuilder<String>(
              valueListenable: _startDate,
              builder: (context, date, child) {
                return ListTile(
                  title: const Text('Точка відліку', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                  trailing: DropdownButton<String>(
                    value: date,
                    dropdownColor: const Color(0xFF1A1A1A),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    underline: Container(height: 1, color: const Color(0xFF2196F3)),
                    items: ['20 лютого 2014', '24 лютого 2022 05:00'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        _startDate.value = newValue;
                        _updateSetting('start_date', newValue);
                      }
                    },
                  ),
                );
              },
            ),
            const Divider(color: Color(0xFF2A2A2A), height: 32),
            ValueListenableBuilder<String>(
              valueListenable: _theme,
              builder: (context, currentTheme, child) {
                return ListTile(
                  title: const Text('Стиль відображення', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                  trailing: DropdownButton<String>(
                    value: currentTheme,
                    dropdownColor: const Color(0xFF1A1A1A),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    underline: Container(height: 1, color: const Color(0xFF2196F3)),
                    items: ['Світла', 'Темна', 'Військова'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        _theme.value = newValue;
                        _updateSetting('theme', newValue);
                      }
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
EOF

# 3. Підтягуємо залежності та генеруємо іконку
flutter pub get
dart run flutter_launcher_icons
# 4. Очищаємо кеш від попередніх невдалих спроб і запускаємо збірку
flutter clean
flutter build apk --release
# 1. Переходимо в проєкт і видаляємо пошкоджені файли
cd ~/time_of_war
rm -f pubspec.yaml lib/settings_page.dart
mkdir -p lib assets
# 2. Створюємо генератор, який ідеально запише код в обхід термінала
cat << 'EOF' > fix.dart
import 'dart:io';
void main() {
  String yaml = '''
name: time_of_war
description: "Time_of_waR Application"
version: 1.0.0+1
environment:
@@sdk: ">=3.0.0 <4.0.0"
dependencies:
@@flutter:
@@@@sdk: flutter
@@shared_preferences: ^2.5.5
@@home_widget: ^0.9.3
dev_dependencies:
@@flutter_launcher_icons: ^0.14.1
flutter:
@@uses-material-design: true
@@assets:
@@@@- assets/icon.png
flutter_launcher_icons:
@@android: "launcher_icon"
@@image_path: "assets/icon.png"
@@min_sdk_android: 21
'''.replaceAll('@@', '  ');
  File('pubspec.yaml').writeAsStringSync(yaml);

  String dartCode = '''
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_widget/home_widget.dart';
class SettingsPage extends StatefulWidget {
const SettingsPage({Key? key}) : super(key: key);
@override
State<SettingsPage> createState() => _SettingsPageState();
}
class _SettingsPageState extends State<SettingsPage> {
final ValueNotifier<bool> _showOrdinalDay = ValueNotifier<bool>(true);
final ValueNotifier<String> _startDate = ValueNotifier<String>('24 лютого 2022 05:00');
final ValueNotifier<String> _theme = ValueNotifier<String>('Військова');
@override
void initState() {
super.initState();
_loadSettings();
}
Future<void> _loadSettings() async {
final prefs = await SharedPreferences.getInstance();
_showOrdinalDay.value = prefs.getBool('show_ordinal_day') ?? true;
_startDate.value = prefs.getString('start_date') ?? '24 лютого 2022 05:00';
_theme.value = prefs.getString('theme') ?? 'Військова';
}
Future<void> _updateSetting(String key, dynamic value) async {
final prefs = await SharedPreferences.getInstance();
if (value is bool) {
await prefs.setBool(key, value);
await HomeWidget.saveWidgetData<bool>(key, value);
} else if (value is String) {
await prefs.setString(key, value);
await HomeWidget.saveWidgetData<String>(key, value);
}
await HomeWidget.updateWidget(name: 'AppWidgetProvider', androidName: 'AppWidgetProvider');
}
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('Налаштування Time_of_waR'), backgroundColor: const Color(0xFF1A1A1A)),
body: Container(
color: const Color(0xFF121212),
padding: const EdgeInsets.all(16.0),
child: ListView(
children: [
ValueListenableBuilder<bool>(
valueListenable: _showOrdinalDay,
builder: (context, isOrdinal, child) {
return SwitchListTile(
title: const Text('Формат відліку', style: TextStyle(color: Colors.white)),
subtitle: Text(isOrdinal ? 'Поточний день події' : 'Загальний минулий час', style: const TextStyle(color: Colors.grey)),
value: isOrdinal,
activeColor: const Color(0xFF2196F3),
onChanged: (value) { _showOrdinalDay.value = value; _updateSetting('show_ordinal_day', value); },
);
},
),
const Divider(color: Colors.grey),
ValueListenableBuilder<String>(
valueListenable: _startDate,
builder: (context, date, child) {
return ListTile(
title: const Text('Точка відліку', style: TextStyle(color: Colors.white)),
trailing: DropdownButton<String>(
value: date,
dropdownColor: const Color(0xFF1A1A1A),
style: const TextStyle(color: Colors.white),
items: ['20 лютого 2014', '24 лютого 2022 05:00'].map((d) { return DropdownMenuItem(value: d, child: Text(d)); }).toList(),
onChanged: (val) { if (val != null) { _startDate.value = val; _updateSetting('start_date', val); } },
),
);
},
),
const Divider(color: Colors.grey),
ValueListenableBuilder<String>(
valueListenable: _theme,
builder: (context, theme, child) {
return ListTile(
title: const Text('Стиль відображення', style: TextStyle(color: Colors.white)),
trailing: DropdownButton<String>(
value: theme,
dropdownColor: const Color(0xFF1A1A1A),
style: const TextStyle(color: Colors.white),
items: ['Світла', 'Темна', 'Військова'].map((t) { return DropdownMenuItem(value: t, child: Text(t)); }).toList(),
onChanged: (val) { if (val != null) { _theme.value = val; _updateSetting('theme', val); } },
),
);
},
),
],
),
),
);
}
}
''';
  File('lib/settings_page.dart').writeAsStringSync(dartCode);
}
EOF

# 3. Запускаємо генератор і видаляємо його
dart fix.dart
rm fix.dart
# 4. Копіюємо іконку-щит
cp /sdcard/1000219542.png assets/icon.png 2>/dev/null || cp /storage/emulated/0/1000219542.png assets/icon.png 2>/dev/null
# 5. Оновлюємо проєкт та генеруємо іконку додатка
flutter clean
flutter pub get
dart run flutter_launcher_icons
# 1. Очищення від попередніх невдач
flutter clean
# 2. Підготовка іконки (з вашого файлу 1000219542.png)
mkdir -p assets
cp /sdcard/1000219542.png assets/icon.png
# 3. Автоматична корекція pubspec.yaml (уникаємо помилок відступів)
python3 -c "
import yaml
with open('pubspec.yaml', 'r') as f:
    data = yaml.safe_load(f)
if not data: data = {}
data['flutter_icons'] = {
    'android': 'launcher_icon',
    'image_path': 'assets/icon.png',
    'min_sdk_android': 21
}
with open('pubspec.yaml', 'w') as f:
    yaml.dump(data, f, default_flow_style=False)
"
# 4. Фінальна збірка
flutter pub get
dart run flutter_launcher_icons:main
flutter build apk --release
pwd
ls
pwd
ls -F
# Перехід у папку вашого проєкту (замініть 'my_flutter_app' на справжню назву вашої папки)
cd /home/user/my_flutter_app
pwd
ls -F
nano pubspec.yaml
pwd && ls -F && if [ -f "pubspec.yaml" ]; then echo "--- ФАЙЛ ЗНАЙДЕНО ---"; else echo "--- ПОМИЛКА: ФАЙЛУ НЕМАЄ В ЦІЙ ПАПЦІ ---"; fi
echo "--- ПЕРЕВІРКА ДИРЕКТОРІЇ ---"
pwd
ls -F
echo "--- ПЕРЕВІРКА ФАЙЛУ ПРОЄКТУ ---"
if [ -f "pubspec.yaml" ]; then     echo "Файл pubspec.yaml ЗНАЙДЕНО тут."; else     echo "ПОМИЛКА: Файл pubspec.yaml НЕ ЗНАЙДЕНО в цій папці."; fi
echo "--- ВЕРСІЯ FLUTTER ---"
flutter --version | head -n 1
# 1. Переходимо безпосередньо всередину вашого проєкту
cd /root/Time_of_waR
# 2. Очищаємо кеш від попередніх невдалих спроб
flutter clean
# 3. Створюємо папку assets та копіюємо туди вашу нову іконку
mkdir -p assets
cp /sdcard/1000219542.png assets/icon.png 2>/dev/null || echo "Попередження: перевірте назву файлу іконки в /sdcard/"
# 4. Автоматично додаємо пакет через сам Flutter (це виключить помилки синтаксису)
flutter pub add --dev flutter_launcher_icons
# 5. Прописуємо конфігурацію іконки через Python, щоб гарантувати ідеальні відступи
python3 -c "
import yaml
with open('pubspec.yaml', 'r') as f:
    data = yaml.safe_load(f) or {}

data['flutter_icons'] = {
    'android': 'launcher_icon',
    'image_path': 'assets/icon.png',
    'min_sdk_android': 21
}

if 'flutter' not in data or data['flutter'] is None:
    data['flutter'] = {}
if 'assets' not in data['flutter'] or data['flutter']['assets'] is None:
    data['flutter']['assets'] = []
if 'assets/icon.png' not in data['flutter']['assets']:
    data['flutter']['assets'].append('assets/icon.png')

with open('pubspec.yaml', 'w') as f:
    yaml.dump(data, f, default_flow_style=False)
print('--- Конфігурацію pubspec.yaml успішно виправлено! ---')
"
# 6. Генеруємо нові іконки додатка та запускаємо фінальну збірку APK
flutter pub get
dart run flutter_launcher_icons:main
flutter build apk --release
# 1. Заходимо в правильну папку (яку ми нарешті побачили)
cd /root/Time_of_waR
# 2. Додаємо залежність офіційним інструментом Flutter (без пайтона)
flutter pub add --dev flutter_launcher_icons
# 3. Копіюємо іконку
mkdir -p assets
cp /sdcard/1000219542.png assets/icon.png
# 4. Просто влиStep конфігурацію в кінець файлу за допомогою cat
cat << 'EOF' >> pubspec.yaml

flutter_launcher_icons:
  android: "launcher_icon"
  image_path: "assets/icon.png"
  min_sdk_android: 21
EOF

# 5. Оновлюємо та запускаємо генерацію
flutter pub get
dart run flutter_launcher_icons:main
flutter build apk --release
# 1. Переходимо в потрібну папку (там, де лежить проєкт)
cd /root/Time_of_waR
# 2. Чистимо термінал і проєкт від попередніх невдалих збірок
flutter clean
# 3. ПОВНІСТЮ ПЕРЕЗАПИСУЄМО pubspec.yaml на 100% чистий (без зайвих символів)
cat > pubspec.yaml << 'EOF'
name: time_of_war
description: "Time_of_waR Application"
version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.5.5
  home_widget: ^0.9.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_launcher_icons: ^0.14.1

flutter_launcher_icons:
  android: "launcher_icon"
  image_path: "assets/icon.png"
  min_sdk_android: 21

flutter:
  uses-material-design: true
  assets:
    - assets/icon.png
EOF

# 4. Створюємо папку для іконки і копіюємо її туди
mkdir -p assets
cp /sdcard/1000219542.png assets/icon.png
# 5. Оновлюємо залежності, ставимо іконку і збираємо APK
flutter pub get
dart run flutter_launcher_icons:main
flutter build apk --release
cd /root/Time_of_waR
flutter clean
rm -f pubspec.yaml.bak
cd /root/Time_of_waR
flutter clean
rm -f pubspec.yaml.bak pubspec.yaml
cd /root/Time_of_waR
cat << 'EOF' > pubspec.yaml
name: time_of_war
description: "Time_of_waR application"
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.5.5
  home_widget: ^0.9.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_launcher_icons: ^0.14.1

flutter_launcher_icons:
  android: "launcher_icon"
  image_path: "assets/icon.png"
  min_sdk_android: 21

flutter:
  uses-material-design: true
  assets:
    - assets/icon.png
EOF

mkdir -p assets
cp /sdcard/1000219542.png assets/icon.png
flutter pub get
dart run flutter_launcher_icons:main
flutter build apk --release
rm -f ~/pubspec.yaml ~/pubspec.yaml.bak
rm -rf ~/assets
proot-distro login ubuntu
mkdir -p ~/.proot-distro/installed-rootfs/ubuntu/root/time_of_war/assets
cp ~/storage/downloads/Ikkon1.png ~/.proot-distro/installed-rootfs/ubuntu/root/time_of_war/assets/icon.png
proot-distro login ubuntu
exit
git push
# Вхід у середовище Ubuntu (якщо використовуєш стандартний proot-distro)
proot-distro login ubuntu
