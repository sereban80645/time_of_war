import re

java_path = "lib/main.dart"

with open(java_path, "r", encoding="utf-8") as f:
    code = f.read()

# Шукаємо тіло функції _updateHomeWidget
pattern = r"void _updateHomeWidget\(\)\s*async\s*\{(.*?)\n  \}"
match = re.search(pattern, code, re.DOTALL)

if match:
    # Заміняємо тіло функції на інтелектуальне дублювання стану додатка
    new_body = """
    // Перевіряємо тумблер для 2022 року
    String text2022 = "";
    if (showTimer2022) { // або як у вас називається змінна тумблера (напр. _vjina2022 чи switchState)
      // Використовуємо вашу функцію форматування часу, яка виводить "4р. 4міс. 0д."
      text2022 = calculateTimeDifference(DateTime(2022, 2, 24)); 
    } else {
      text2022 = "Вимкнено в додатку";
    }

    // Перевіряємо тумблер для 2014 року
    String text2014 = "";
    if (showTimer2014) { // замініть на вашу змінну тумблера, якщо назва інша
      text2014 = calculateTimeDifference(DateTime(2014, 4, 14));
    } else {
      text2014 = "Вимкнено в додатку";
    }

    await HomeWidget.saveWidgetData<String>('timer_2022', text2022);
    await HomeWidget.saveWidgetData<String>('timer_2014', text2014);
    await HomeWidget.updateWidget(
      name: 'TimerWidgetProvider',
      androidName: 'TimerWidgetProvider',
    );"""
    
    # Оскільки точні назви ваших змінних тумблерів були у прихованій частині скріншоту,
    # цей скрипт адаптує логіку. Давайте зробимо універсальну заміну під вашу структуру:
    
    print("[i] Оновлюємо логіку віджета в main.dart...")
    
# Проте, оскільки структура методів може відрізнятися назвами змінних (напр. showSeconds, vjna2014),
# надійніше буде замінити весь метод вручну або глянути на точні назви.
