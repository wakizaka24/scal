import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import 'f002_home_view_model.dart';
import 'f003_calendar_page.dart';

class CalendarPageState {
  // Control
  PageController calendarController = PageController(initialPage: 36001);

  // UI
  bool dayPartActive = true;
  int dayPartIndex = 0;
  int? eventListIndex;

  // Data
  late DateTime now;
  late DateTime selectDay;
  List<WeekdayDisplay> weekdayList = [];
  List<List<DayDisplay>> dayLists = [];
  String eventListTitle = '';
  List<EventDisplay> eventList = [];

  static CalendarPageState copy(CalendarPageState state) {
    var nState = CalendarPageState();

    // Control
    nState.calendarController = state.calendarController;

    // UI
    nState.dayPartActive = state.dayPartActive;
    nState.dayPartIndex = state.dayPartIndex;
    nState.eventListIndex = state.eventListIndex;

    // Data
    nState.now = state.now;
    nState.selectDay = state.selectDay;
    nState.weekdayList = state.weekdayList;
    nState.dayLists = state.dayLists;
    nState.eventListTitle = state.eventListTitle;
    nState.eventList = state.eventList;
    return nState;
  }
}

class WeekdayDisplay {
  String title;
  Color titleColor;

  WeekdayDisplay({
    required this.title,
    required this.titleColor
  });
}

class DayDisplay {
  DateTime id;
  String title;
  Color titleColor;
  List<String> eventList;
  Color bgColor;

  DayDisplay({
    required this.id,
    required this.title,
    required this.titleColor,
    required this.eventList,
    required this.bgColor
  });
}

class EventDisplay {
  String id;
  bool editing;
  String head;
  String title;

  EventDisplay({
    required this.id,
    required this.editing,
    required this.head,
    required this.title,
  });
}

class CalendarPageNotifier extends StateNotifier<CalendarPageState> {
  final Ref ref;

  CalendarPageNotifier(this.ref, CalendarPageState state)
      : super(state);

  initState(bool update) async {
    // Data
    state.weekdayList = [
      WeekdayDisplay(title: '日',
          titleColor: Colors.pink),
      WeekdayDisplay(title: '月',
          titleColor: Colors.black),
      WeekdayDisplay(title: '火',
          titleColor: Colors.black),
      WeekdayDisplay(title: '水',
          titleColor: Colors.black),
      WeekdayDisplay(title: '木',
          titleColor: Colors.black),
      WeekdayDisplay(title: '金',
          titleColor: Colors.black),
      WeekdayDisplay(title: '土',
          titleColor: Colors.green),
    ];
    state.now = DateTime.now();
    state.dayLists = createDayLists(state.now);
    state.dayLists = addEvents(state.dayLists);
    state.selectDay = state.now;
    setCurrentDay(state.selectDay, update);

    // UI
    state.dayPartActive = true;
    DateTime now = state.now;
    state.dayPartIndex = 0;
    for (int i=0; i < state.dayLists[1].length; i++) {
      if (state.dayLists[1][i].id == DateTime(now.year, now.month, now.day)) {
        state.dayPartIndex = i;
        break;
      }
    }

    if (update) {
      updateState();
    }
  }

  onCalendarPageChanged(int month) async {
    debugPrint('onCalendarPageChanged month=$month');
  }

  setCurrentDay(DateTime date, bool update) {
    final homeNotifier = ref.read(homePageNotifierProvider.notifier);
    homeNotifier.setCurrentDay(date, update);

    state.eventListTitle = DateFormat.MMMEd('ja') // 6月12日(月)
        .format(date).toString();
    state.eventList = [
      EventDisplay(id: 'first', editing: true, head: '連日',
          title: 'コンテムポレリダンスした日'),
      for(int i=0; i<4; i++) ... {
        EventDisplay(id: i.toString(), editing: false, head: '09:00\n18:00',
            title: 'コンテムポレリダンスした日ああああああああああああああああ'),
      }
    ];
  }

  List<List<DayDisplay>> createDayLists(DateTime now) {
    DateTime prevMonth = DateTime(now.year, now.month - 1, 1);

    // 月部分の先頭の日付
    int subDay = 0;
    for (int weekday = prevMonth.weekday; weekday % 7 != 0; weekday--) {
      subDay--;
    }
    DateTime currentDay = DateTime(prevMonth.year, prevMonth.month,
        prevMonth.day + subDay);

    // 基準月
    List<DateTime> months = [
      // 3ヶ月分
      for (int i=0; i<3; i++) ... {
        DateTime(prevMonth.year, prevMonth.month + i, 1)
      }
    ];

    List<List<DayDisplay>> list = [];
    for (int i=0; i<3; i++) {
      if (i > 0) {
        // 月区切りの直前が翌月
        if (list.last.last.id.month == months[i].month) {
          // 月区切りで1週差し戻す
          currentDay = DateTime(currentDay.year, currentDay.month,
              currentDay.day - 7);
        }
      }

      DateTime now = DateTime(state.now.year, state.now.month, state.now.day);

      list.add([
        // 翌月かつ土曜日まで
        for (int j=0; currentDay.month != months[i].month && j < 7
            || currentDay.month == months[i].month
            || currentDay.month != months[i].month && j % 7 != 0; j++,
            currentDay = DateTime(currentDay.year,
            currentDay.month, currentDay.day + 1)) ... {
              DayDisplay(id: currentDay, title: currentDay.day.toString(),
                titleColor: j % 7 == 0 ? Colors.pink : j % 7 == 6
                    ? Colors.green : Colors.black, eventList: [],
                  bgColor: currentDay == now ? todayBgColor
                    : Colors.transparent)
        }
      ]);
    }

    return list;
  }

  List<List<DayDisplay>> addEvents(List<List<DayDisplay>> dayLists) {
    for (int month = 0; month < dayLists.length; month++) {
      for (int day = 0; day < dayLists[month].length; day++) {
        dayLists[month][day].eventList = [
          for (int i = 0; i < 16; i++) ... {
            'コンテムポレリダンスした日'
          }
        ];
      }
    }
    return dayLists;
  }

  selectDayPart(int index) {
    state.now = DateTime.now();
    state.dayPartActive = true;
    state.dayPartIndex = index;
    state.eventListIndex = null;
    state.selectDay = state.dayLists[1][index].id;
    setCurrentDay(state.selectDay, true);
    updateState();
  }

  selectEventListPart(int index) {
    state.dayPartActive = false;
    state.eventListIndex = index;
    updateState();
  }

  updateState() async {
    state = CalendarPageState.copy(state);
  }
}

final calendarPageNotifierProvider = StateNotifierProvider.family
    .autoDispose<CalendarPageNotifier, CalendarPageState, int>((ref, index) {
      var list = List.filled(2, CalendarPageState());
      return CalendarPageNotifier(ref, list[index]);
});