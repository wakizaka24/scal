// import 'package:flutter/foundation.dart';

import 'package:device_calendar/device_calendar.dart';

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
    // if (str.contains('')) {
    //   var _ = 0;
    // }

    var otherReg = '[^ -~\'’‘]+';
    var targetReg = '[ -~\'’‘]+';
    String charWrapStr;
    if (RegExp(otherReg).hasMatch(str)) {
      charWrapStr = '';
      for (int i = 0; i < str.length; i++) {
        var char = str[i];
        if (RegExp(targetReg).hasMatch(char)) {
          // 改行可能な0文字のスペース
          charWrapStr += '\u200b$char';
        } else {
          charWrapStr += char;
        }
      }
    } else {
      charWrapStr = str;
    }

    // 改行しないスペースに変換
    charWrapStr = charWrapStr.replaceAll(' ', '\u00a0')
    // -の前後に改行禁止文字を追加
        .replaceAll('-', '\ufeff-\ufeff');

    return charWrapStr;
  }

  DateTime copyDate(DateTime baseDate, DateTime day) {
    return DateTime(day.year, day.month, day.day, baseDate.hour,
        baseDate.minute);
  }

  DateTime trimDate(DateTime day, {maxTime=false}) {
    return DateTime(day.year, day.month, day.day, !maxTime ? 0 : 23,
      !maxTime ? 0 : 59);
  }

  DateTime copyTime(DateTime baseDate, DateTime time) {
    return DateTime(baseDate.year, baseDate.month, baseDate.day, time.hour,
        time.minute);
  }

  DateTime? convertDateTime(TZDateTime? dateTime) {
    if (dateTime == null) {
      return null;
    }
    return DateTime(dateTime.year, dateTime.month, dateTime.day,
      dateTime.hour, dateTime.minute);
  }

  bool someDate(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) {
      return false;
    }
    return date1.year == date2.year && date1.month == date2.month
        && date1.day == date2.day;
  }
}