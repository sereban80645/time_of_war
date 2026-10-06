import re

with open("lib/main.dart", "r", encoding="utf-8") as f:
    code = f.read()

# Додаємо імпорт, якщо його немає
if "package:path_provider/path_provider.dart" not in code:
    code = "import 'package:path_provider/path_provider.dart';\n" + code

# Шукаємо місце, де вибирається фотографія
pattern = r"(final\s+([a-zA-Z0-9_]+)\s*=\s*await\s+picker\.pickImage[^\n]+\n\s*if\s*\(\2\s*!=\s*null\)\s*\{)"
match = re.search(pattern, code)

if match and "persistent_widget_bg.jpg" not in code:
    var_name = match.group(2)
    
    # Код для збереження у постійну пам'ять
    injection = f"""
      final appDir = await getApplicationDocumentsDirectory();
      final permanentFile = await File({var_name}.path).copy('${{appDir.path}}/persistent_widget_bg.jpg');
      final String safePath = permanentFile.path;
"""
    code = code[:match.end()] + injection + code[match.end():]
    
    # Замінюємо використання тимчасового шляху на безпечний постійний
    start_idx = code.find(injection) + len(injection)
    end_idx = code.find('}', start_idx)
    if end_idx != -1:
        block = code[start_idx:end_idx]
        block = block.replace(f"{var_name}.path", "safePath")
        code = code[:start_idx] + block + code[end_idx:]

with open("lib/main.dart", "w", encoding="utf-8") as f:
    f.write(code)

print("✅ Скрипт успішно налаштував збереження картинки у постійну пам'ять!")
