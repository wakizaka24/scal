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
    // if (str.contains('')) {
    //   var _ = 0;
    // }

    var asciiOtherReg = r'[^ -~]+';
    var asciiReg = r'[ -~]+';
    String charWrapStr;
    if (RegExp(asciiOtherReg).hasMatch(str)) {
      charWrapStr = '';
      for (int i = 0; i < str.length; i++) {
        var char = str[i];
        if (RegExp(asciiReg).hasMatch(char)) {
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
}