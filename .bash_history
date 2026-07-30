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
cd ~/projects/time_of_war
cat << 'EOF' > lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const TimeOfWarApp());
}

class TimeOfWarApp extends StatelessWidget {
  const TimeOfWarApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const TimerScreen(),
    );
  }
}

class TimerScreen extends StatefulWidget {
  const TimerScreen({Key? key}) : super(key: key);

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late Timer _timer;
  final DateTime startDate2022 = DateTime(2022, 2, 24, 0, 0, 0);
  final DateTime startDate2014 = DateTime(2014, 4, 14, 0, 0, 0);
  
  Duration _duration2022 = Duration.zero;
  Duration _duration2014 = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _duration2022 = now.difference(startDate2022);
      _duration2014 = now.difference(startDate2014);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int days2022 = _duration2022.inDays;
    final int hours2022 = _duration2022.inHours % 24;

    final int days2014 = _duration2014.inDays;
    final int hours2014 = _duration2014.inHours % 24;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[800]!, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Повномасштабна війна:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$days2022',
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    ' д. ',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$hours2022',
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    ' г.',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Війна з 2014 року:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$days2014',
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    ' д. ',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$hours2014',
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    ' г.',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
EOF

git add lib/main.dart
git commit -m "Center widget content vertically"
git push -f origin main
cd ~/projects/time_of_war
git reset --hard 8b4743d
git push -f origin main
cd ~/projects/time_of_war
python3 -c '
import re

with open("lib/main.dart", "r", encoding="utf-8") as f:
    code = f.read()

# 1. Однакове закруглення для всіх кутів віджета
code = re.sub(r"BorderRadius\.only\([\s\S]*?\)", "BorderRadius.circular(18)", code)

# 2. Вертикальне центрування у Column
if "mainAxisAlignment:" in code:
    code = re.sub(r"mainAxisAlignment:\s*MainAxisAlignment\.\w+", "mainAxisAlignment: MainAxisAlignment.center", code)
else:
    code = code.replace("Column(", "Column(\n          mainAxisAlignment: MainAxisAlignment.center,")

# 3. Зменшення великих відступів, щоб нижній таймер не влазив у край
code = re.sub(r"SizedBox\(\s*height:\s*(?:1[0-9]|[2-9][0-9])\.?0?\s*\)", "SizedBox(height: 4)", code)

with open("lib/main.dart", "w", encoding="utf-8") as f:
    f.write(code)
'
git add lib/main.dart
git commit -m "Fix widget vertical centering and corner radius"
git push -f origin main
cd ~/projects/time_of_war
# 1. Скасовуємо коміт із пошкодженим синтаксисом
git reset --hard HEAD~1
# 2. Виправляємо закруглення та центрування без пошкодження дужок Dart
python3 -c '
with open("lib/main.dart", "r", encoding="utf-8") as f:
    code = f.read()

# Безпечна заміна BorderRadius.only з урахуванням вкладених дужок
target = "BorderRadius.only("
while target in code:
    start = code.find(target)
    depth = 0
    end = start + len(target) - 1
    for i in range(start + len(target) - 1, len(code)):
        if code[i] == "(":
            depth += 1
        elif code[i] == ")":
            depth -= 1
            if depth == 0:
                end = i
                break
    code = code[:start] + "BorderRadius.circular(18)" + code[end + 1:]

# Вертикальне центрування
import re
code = re.sub(r"MainAxisAlignment\.(start|end|spaceBetween|spaceAround|spaceEvenly)", "MainAxisAlignment.center", code)

with open("lib/main.dart", "w", encoding="utf-8") as f:
    f.write(code)
'
# 3. Фіксуємо та відправляємо на GitHub
git add lib/main.dart
git commit -m "Fix widget centering and border radius safely"
git push -f origin main
cd ~/projects/time_of_war
# 1. Відкочуємо останній зламаний коміт
git reset --hard HEAD~1
# 2. Безпечно прибираємо const та налаштовуємо закруглення й центрування
python3 -c '
with open("lib/main.dart", "r", encoding="utf-8") as f:
    code = f.read()

# Прибираємо const перед BoxDecoration, щоб не виникало помилок компіляції
code = code.replace("const BoxDecoration(", "BoxDecoration(")

# Замінюємо BorderRadius.only на однакове закруглення кутів
target = "BorderRadius.only("
while target in code:
    start = code.find(target)
    depth = 0
    end = start + len(target) - 1
    for i in range(start + len(target) - 1, len(code)):
        if code[i] == "(":
            depth += 1
        elif code[i] == ")":
            depth -= 1
            if depth == 0:
                end = i
                break
    code = code[:start] + "BorderRadius.circular(18.0)" + code[end + 1:]

# Вирівнюємо вміст вертикально по центру
import re
code = re.sub(r"MainAxisAlignment\.(start|end|spaceBetween|spaceAround|spaceEvenly)", "MainAxisAlignment.center", code)

with open("lib/main.dart", "w", encoding="utf-8") as f:
    f.write(code)
'
# 3. Зберігаємо та відправляємо на GitHub
git add lib/main.dart
git commit -m "Fix const decoration error and align widget vertically"
git push -f origin main
cd ~/projects/time_of_war
python3 -c '
import re

def replace_balanced(text, prefix, replacement):
    while prefix in text:
        start = text.find(prefix)
        depth = 0
        end = start
        for i in range(start + len(prefix) - 1, len(text)):
            if text[i] == "(":
                depth += 1
            elif text[i] == ")":
                depth -= 1
                if depth == 0:
                    end = i
                    break
        if end > start:
            text = text[:start] + replacement + text[end + 1:]
        else:
            break
    return text

with open("lib/main.dart", "r", encoding="utf-8") as f:
    code = f.read()

parts = code.split("class ")
new_parts = [parts[0]]

for cls in parts[1:]:
    if "Повномасштабна" in cls:
        # Універсальне закруглення для всіх кутів
        cls = replace_balanced(cls, "BorderRadius.only(", "BorderRadius.circular(18.0)")
        cls = replace_balanced(cls, "BorderRadius.vertical(", "BorderRadius.circular(18.0)")
        
        # Зменшуємо проміжки між текстом, щоб віджет став нижчим і не обрізався
        cls = re.sub(r"SizedBox\(\s*height:\s*\d+\.?\d*\s*\)", "SizedBox(height: 2.0)", cls)
        
        # Вирівнюємо строго по центру
        cls = re.sub(r"MainAxisAlignment\.\w+", "MainAxisAlignment.center", cls)
        
        # Робимо колонку компактною по висоті
        cls = re.sub(r"mainAxisSize:\s*MainAxisSize\.[^,]+,", "", cls)
        cls = cls.replace("Column(", "Column(mainAxisSize: MainAxisSize.min, ")
        
        # Гарантуємо, що фонова картинка не вилізе за закруглені кути
        cls = re.sub(r"clipBehavior:\s*Clip\.[^,]+,", "", cls)
        cls = cls.replace("decoration: BoxDecoration", "clipBehavior: Clip.antiAlias, decoration: BoxDecoration")
            
    new_parts.append(cls)

code = "class ".join(new_parts)

with open("lib/main.dart", "w", encoding="utf-8") as f:
    f.write(code)
'
git add lib/main.dart
git commit -m "Fix widget clipping by Android and align content center"
git push -f origin main
cd ~/projects/time_of_war
git reset --hard HEAD~1
git push -f origin main
cd ~/projects/time_of_war
git log --oneline -n 7
git reset --hard 3d0726e
git push -f origin main
cd ~/projects/time_of_war
curl -F "file=@lib/main.dart" https://0x0.st
curl --data-binary @lib/main.dart https://paste.rs/
cd ~/projects/time_of_war
cat << 'EOF' > update_widget.py
with open("lib/main.dart", "r", encoding="utf-8") as f:
    code = f.read()

# Зменшуємо прев'ю до квадрата 1х1 у меню налаштувань
code = code.replace("height: 200", "height: 140")
code = code.replace("height: 220", "height: 140")
code = code.replace("width: double.infinity", "width: 140")

with open("lib/main.dart", "w", encoding="utf-8") as f:
    f.write(code)
print("Updated successfully")
EOF

python3 update_widget.py
git add lib/main.dart
git commit -m "Fix widget preview size and proportions 1x1"
git push -f origin main
cd ~/projects/time_of_war
python3 -c '
with open("lib/main.dart", "r", encoding="utf-8") as f:
    code = f.read()

# Робимо контейнер прев\'ю квадратним (1:1), щоб він повністю відповідав віджету на робочому столі
# Шукаємо контейнер превю та примусово задаємо йому рівні сторони або AspectRatio
if "Прев" in code and "Container(" in code:
    code = code.replace("Container(\n          width: double.infinity", "AspectRatio(\n        aspectRatio: 1.0,\n        child: Container(\n          width: double.infinity")
code = code.replace("height: 180", "height: 150").replace("width: double.infinity", "width: 150")
with open("lib/main.dart", "w", encoding="utf-8") as f:
'

git add lib/main.dart
git commit -m "Make widget preview square 1x1 to match home screen"
git push -f origin main
cd ~/projects/time_of_war

cat << 'EOF' > fix.py
with open("lib/main.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Робимо однакові закруглені кути для віджета
content = content.replace("BorderRadius.only(", "BorderRadius.circular(18.0) /* ")
content = content.replace("BorderRadius.vertical(", "BorderRadius.circular(18.0) /* ")

with open("lib/main.dart", "w", encoding="utf-8") as f:
    f.write(content)

print("Script executed successfully")
EOF

python3 fix.py
rm fix.py

git add lib/main.dart
git commit -m "Fix widget border radius uniformly"
git push -f origin main
cd ~/projects/time_of_war
echo "" >> lib/main.dart
git add lib/main.dart
git commit -m "Force trigger build"
git push -f origin main
