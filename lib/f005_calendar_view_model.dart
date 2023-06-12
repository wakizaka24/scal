import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import 'f004_calendar_page.dart';

class CalendarPageState {
  // UI
  bool dayPartActive = true;
  int dayPartIndex = 0;
  int? eventListIndex;
  PageController homePageController = PageController();

  // Data
  late DateTime now;
  late DateTime selectDay;
  String appBarTitle = '';
  List<WeekdayDisplay> weekdayList = [];
  List<List<DayDisplay>> dayLists = [];
  String eventListTitle = '';
  List<EventDisplay> eventLists = [];

  static CalendarPageState copy(CalendarPageState state) {
    var nState = CalendarPageState();

    // UI
    nState.dayPartActive = state.dayPartActive;
    nState.dayPartIndex = state.dayPartIndex;
    nState.eventListIndex = state.eventListIndex;
    nState.homePageController = state.homePageController;

    // Data
    nState.now = state.now;
    nState.selectDay = state.selectDay;
    nState.appBarTitle = state.appBarTitle;
    nState.weekdayList = state.weekdayList;
    nState.dayLists = state.dayLists;
    nState.eventListTitle = state.eventListTitle;
    nState.eventLists = state.eventLists;
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

  initState() async {
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
    state.selectDay = state.now;
    setCurrentDay(state.selectDay);

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

    state = CalendarPageState.copy(state);
  }

  setCurrentDay(DateTime date) {
    DateTime now = date;
    state.appBarTitle = DateFormat.yMMM('ja') // 2023年6月
        .format(now).toString();
    state.eventListTitle = DateFormat.MMMEd('ja') // 6月12日(月)
        .format(now).toString();
    state.eventLists = [
      EventDisplay(id: 'first', editing: true, head: '連日',
          title: 'コンテムポレリダンスした日'),
      for(int i=0; i<4; i++) ... {
        EventDisplay(id: i.toString(), editing: false, head: '09:00\n18:00',
            title: 'コンテムポレリダンスした日'),
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

  selectDayPart(int index) {
    state.dayPartActive = true;
    state.dayPartIndex = index;
    state.eventListIndex = null;
    state.selectDay = state.dayLists[1][index].id;
    setCurrentDay(state.selectDay);

    state = CalendarPageState.copy(state);
  }

  selectEventListPart(int index) {
    state.dayPartActive = false;
    state.eventListIndex = index;
    state = CalendarPageState.copy(state);
  }
}

final calendarPageNotifierProvider =
StateNotifierProvider.autoDispose<CalendarPageNotifier,
    CalendarPageState>((ref) {
  return CalendarPageNotifier(ref, CalendarPageState());
});