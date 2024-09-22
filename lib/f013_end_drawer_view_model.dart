import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'f008_calendar_config.dart';
import 'f017_design_config.dart';

class WeekdayDisplay {
  String title;
  Color titleColor;

  WeekdayDisplay({
    required this.title,
    required this.titleColor
  });
}

class CalendarDisplayDisplay {
  String accountName;
  String calendarName;
  String displayModeTitle;
  String editingModeTitle;
  String useTitle;
  Calendar calendar;
  CalendarDisplayMode displayMode;
  CalendarEditingMode editingMode;
  CalendarHolidayDisplayMode holidayDisplayMode;

  CalendarDisplayDisplay({
    required this.accountName,
    required this.calendarName,
    required this.displayModeTitle,
    required this.editingModeTitle,
    required this.useTitle,
    required this.calendar,
    required this.displayMode,
    required this.editingMode,
    required this.holidayDisplayMode
  });
}



class EndDrawerPageState {
  List<WeekdayDisplay> weekdayList = [];

  static EndDrawerPageState copy(EndDrawerPageState state) {
    var nState = EndDrawerPageState();
    nState.weekdayList = state.weekdayList;
    return nState;
  }
}

class EndDrawerPageNotifier extends StateNotifier<EndDrawerPageState> {
  final Ref ref;

  EndDrawerPageNotifier(this.ref, EndDrawerPageState state)
      : super(state);

  initState() async {
    state.weekdayList = createWeekdayList();
  }

  updateWeekdayList() async {
    state.weekdayList = createWeekdayList();
  }

  List<WeekdayDisplay> createWeekdayList() {
    const titleList = ['日', '月', '火', '水', '木', '金', '土'];
    var normalTextColor = ref.read(designConfigNotifierProvider).colorConfig!
        .normalTextColor;
    final calendarConfig = ref.read(calendarConfigNotifierProvider);
    var holidayList = calendarConfig.calendarHolidayList;

    var titleColors = holidayList.map((holiday) {
      switch(holiday) {
        case CalendarHoliday.none:
          return normalTextColor;
        case CalendarHoliday.red:
          return Colors.pink;
        case CalendarHoliday.blue:
          return Colors.blueAccent;
        case CalendarHoliday.brown:
          return Colors.brown;
      }
    }).toList();

    List<WeekdayDisplay> weekdayDisplayList = [];
    for (int i=0; i<titleList.length; i++) {
      var title = titleList[i];
      var titleColor = titleColors[i];
      weekdayDisplayList.add(WeekdayDisplay(title: title,
          titleColor: titleColor));
    }

    return weekdayDisplayList;
  }

  // Future<List<CalendarDisplayDisplay>> createCalendarDisplayList() async {
  //
  //
  // }



  updateState() async {
    state = EndDrawerPageState.copy(state);
    debugPrint('updateState(end_drawer)');
  }
}

final endDrawerPageNotifierProvider = StateNotifierProvider
    .autoDispose<EndDrawerPageNotifier, EndDrawerPageState>((ref) {
  return EndDrawerPageNotifier(ref, EndDrawerPageState());
});