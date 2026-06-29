// ... (імпорти та базові класи залишаються без змін, оновлюємо тільки _calculateTimeDifference)

  String _calculateTimeDifference(DateTime startDate) {
    final now = DateTime.now();
    final difference = now.difference(startDate);
    
    // Розраховуємо загальну кількість днів, що пройшли, і додаємо 1 для "поточного дня"
    int totalDays = difference.inDays + 1;
    int hours = now.hour - startDate.hour;
    if (hours < 0) { hours += 24; }

    if (_showDaysOnly) {
      String output = "${totalDays}д.";
      if (_showHour) output += " ${hours}г.";
      return output;
    } else {
      // Конвертуємо загальну кількість днів у роки та місяці
      int years = (totalDays / 365.25).floor();
      int remainingDays = (totalDays - (years * 365.25)).round();
      int months = (remainingDays / 30.44).floor();
      int days = (remainingDays - (months * 30.44)).round();

      // Корекція для виключення "0" при переході
      if (days <= 0) days = 1;

      String output = "${years}р. ${months}міс. ${days}д.";
      if (_showHour) output += " ${hours}г.";
      return output;
    }
  }

// ... (решта коду без змін)
