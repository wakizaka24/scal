class CalendarDateUtils {
  static final CalendarDateUtils _instance = CalendarDateUtils._internal();
  CalendarDateUtils._internal();

  factory CalendarDateUtils() {
    return _instance;
  }

  List<DateTime> getAllDays(DateTime startDate, DateTime endDate) {
    var date = DateTime(startDate.year, startDate.month, startDate.day);
    List<DateTime> allDays = [];
    while (!endDate.isBefore(date)) {
      allDays.add(date);
      date = date.add(const Duration(days: 1));
    }
    return allDays;
  }

  List<DateTime> getAllHours(DateTime startDate, DateTime endDate,
      int timeInterval) {
    var startHour = (startDate.hour ~/ timeInterval) * timeInterval;
    var date = DateTime(startDate.year, startDate.month, startDate.day,
        startHour);

    List<DateTime> allHours = [];
    while (!endDate.isBefore(date)) {
      allHours.add(date);
      date = date.add(Duration(hours: timeInterval));
    }
    return allHours;
  }
}