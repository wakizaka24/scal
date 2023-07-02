class CalendarDateUtils {
  static final CalendarDateUtils _instance = CalendarDateUtils._internal();
  CalendarDateUtils._internal();

  factory CalendarDateUtils() {
    return _instance;
  }

  List<DateTime> getAllDays(startDate, endDate) {
    var date = DateTime(startDate.year, startDate.month, startDate.day);
    List<DateTime> allDays = [];
    while (!endDate.isBefore(date)) {
      allDays.add(date);
      date = date.add(const Duration(days: 1));
    }
    return allDays;
  }
}