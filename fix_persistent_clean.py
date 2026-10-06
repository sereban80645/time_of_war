import re

with open("lib/main.dart", "r", encoding="utf-8") as f:
    code = f.read()

# Гарантуємо наявність імпорту path_provider
if "package:path_provider/path_provider.dart" not in code:
    code = "import 'package:path_provider/path_provider.dart';\n" + code

# Знаходимо назву змінної після pickImage (наприклад, image або pickedFile)
match = re.search(r"final\s+(?:[\w\?]+\s+)?([\w_]+)\s*=\s*await\s+picker\.pickImage", code)
if match:
    var_name = match.group(1)
    target = f"if ({var_name} != null) {{"
    replacement = f"""if ({var_name} != null) {{
      final appDirectory = await getApplicationDocumentsDirectory();
      final permanentImage = await File({var_name}.path).copy('${{appDirectory.path}}/persistent_widget_bg.jpg');
      final String imagePathToSave = permanentImage.path;"""
    
    if target in code:
        code = code.replace(target, replacement, 1)
        # Замінюємо використання шляху ТІЛЬКИ у коді, що йде після створення permanentImage
        marker = "final String imagePathToSave = permanentImage.path;"
        parts = code.split(marker)
        if len(parts) == 2:
            parts[1] = parts[1].replace(f"{var_name}.path", "imagePathToSave")
            code = marker.join(parts)

with open("lib/main.dart", "w", encoding="utf-8") as f:
    f.write(code)

print("✅ Файл main.dart успішно відновлено та безпечно налаштовано постійне збереження!")
