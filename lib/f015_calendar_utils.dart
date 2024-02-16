// import 'package:flutter/foundation.dart';

class CalendarUtils {
  static final CalendarUtils _instance = CalendarUtils._internal();
  CalendarUtils._internal();

  factory CalendarUtils() {
    return _instance;
  }

  List<DateTime> getAllDays(DateTime startDate, DateTime endDate) {
    var date = DateTime(startDate.year, startDate.month, startDate.day);
    List<DateTime> allDays = [];
    while (!endDate.isBefore(date) && !endDate.isAtSameMomentAs(date)) {
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
    while (!endDate.isBefore(date) && !endDate.isAtSameMomentAs(date)) {
      allHours.add(date);
      date = date.add(Duration(hours: timeInterval));
    }
    return allHours;
  }

  String convertCharWrapString(String str) {
    var replaceStr = str
        .replaceAll(' ', '\u00a0') // 改行しないスペースに変換
        // 改行できなくなる文字の前にゼロ幅スペースを追加する
        .replaceAll('\'', '\u200b\'') // '
        .replaceAll('’', '\u200b’') // ’
        .replaceAll('‘', '\u200b‘') // ‘
        ;

    // if (replaceStr.contains('')) {
    //   debugPrint(replaceStr);
    // }

    return replaceStr;
  }
}