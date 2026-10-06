import re

with open("lib/main.dart", "r", encoding="utf-8") as f:
    code = f.read()

# 1. Гарантуємо наявність імпорту path_provider
if "import 'package:path_provider/path_provider.dart';" not in code:
    code = "import 'package:path_provider/path_provider.dart';\n" + code

# 2. Додаємо перевірку і копіювання файлу у постійне сховище при виборі
if "persistent_widget_bg.jpg" not in code:
    # Шукаємо блок перевірки після pickImage
    code = re.sub(
        r"(if\s*\(([\w_]+)\s*!=\s*null\)\s*\{)",
        r"""\1
        final appDir = await getApplicationDocumentsDirectory();
        final permanentFile = await File(\2.path).copy('${appDir.path}/persistent_widget_bg.jpg');""",
        code,
        count=1
    )
    # Замінюємо використання тимчасового шляху на постійний
    code = re.sub(
        r"(\b[\w_]+\.path\b)",
        r"permanentFile.path",
        code,
        count=2
    )

with open("lib/main.dart", "w", encoding="utf-8") as f:
    f.write(code)

print("✅ Збереження фону переведено у постійну пам'ять документів!")
