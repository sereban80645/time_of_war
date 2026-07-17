import re

with open('lib/main.dart', 'r', encoding='utf-8') as f:
    code = f.read()

# Шукаємо "void main() {" і замінюємо на "void main() async {"
code = re.sub(r'void\s+main\s*\(\s*\)\s*\{', 'void main() async {', code)

with open('lib/main.dart', 'w', encoding='utf-8') as f:
    f.write(code)
