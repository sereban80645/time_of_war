with open("lib/main.dart", "r", encoding="utf-8") as f:
    code = f.read()

# Зменшуємо прев'ю до квадрата 1х1 у меню налаштувань
code = code.replace("height: 200", "height: 140")
code = code.replace("height: 220", "height: 140")
code = code.replace("width: double.infinity", "width: 140")

with open("lib/main.dart", "w", encoding="utf-8") as f:
    f.write(code)
print("Updated successfully")
