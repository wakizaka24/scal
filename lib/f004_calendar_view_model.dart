import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import 'f002_home_view_model.dart';
import 'f003_calendar_page.dart';

class CalendarPageState {
  // Control
  static const int basisIndex = 36001;
  PageController calendarController = PageController(
      initialPage: basisIndex);
  bool calendarReload = false;

  // UI
  bool dayPartActive = true;
  int dayPartIndex = 0;
  int? eventListIndex;

  // Data
  static const int weekdayPartColumnNum = 7;
  DateTime basisDate = DateTime.now();
  int addMonth = 0;
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
    nState.calendarReload = state.calendarReload;

    // UI
    nState.dayPartActive = state.dayPartActive;
    nState.dayPartIndex = state.dayPartIndex;
    nState.eventListIndex = state.eventListIndex;

    // Data
    nState.basisDate = state.basisDate;
    nState.addMonth = state.addMonth;
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
    state.dayLists = createDayLists(state.basisDate, state.addMonth);
    state.dayLists = addEvents(state.dayLists);
    state.selectDay = state.now;
    setCurrentDay(state.selectDay);
    final homeNotifier = ref.read(homePageNotifierProvider.notifier);
    homeNotifier.setCurrentDay(state.selectDay, false);

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
  }

  onCalendarPageChanged(int monthIndex) async {
    int addMonth = monthIndex - CalendarPageState.basisIndex;
    if (state.addMonth == addMonth) {
      return;
    }
    debugPrint('onCalendarPageChanged addMonth=$addMonth');
    state.addMonth = addMonth;
    state.now = DateTime.now();
    state.dayLists = createDayLists(state.basisDate, state.addMonth);
    state.dayLists = addEvents(state.dayLists);
    state.calendarReload = true;

    selectDayPart();
  }

  setCurrentDay(DateTime date) {
    state.eventListTitle = DateFormat.MMMEd('ja') // 6月12日(月)
        .format(date).toString();
    state.eventList = [
      // EventDisplay(id: 'first', editing: true, head: '連日',
      //     title: 'コンテムポレリダンスした日'),
      // for(int i=0; i<6; i++) ... {
      //   EventDisplay(id: i.toString(), editing: false, head: '09:00\n18:00',
      //       title: 'コンテムポレリダンスした日ああああああああああああああああ'),
      // }
    ];
  }

  List<List<DayDisplay>> createDayLists(DateTime now, int addMonth) {
    DateTime prevMonth = DateTime(now.year, now.month - 1 + addMonth, 1);

    // 月部分の先頭の日付
    int subDay = 0;
    const columnNum = CalendarPageState.weekdayPartColumnNum;
    for (int weekday = prevMonth.weekday; weekday
        % columnNum != 0; weekday--) {
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
    for (int i=0; i < 3; i++) {
      if (i > 0) {
        // 月区切りの直前が翌月
        if (list.last.last.id.month == months[i].month) {
          // 月区切りで1週差し戻す
          currentDay = DateTime(currentDay.year, currentDay.month,
              currentDay.day - columnNum);
        }
      }

      DateTime now = DateTime(state.now.year, state.now.month, state.now.day);

      list.add([
        // 翌月かつ土曜日まで
        for (int j=0; currentDay.month != months[i].month && j < columnNum
            || currentDay.month == months[i].month
            || currentDay.month != months[i].month && j % columnNum != 0; j++,
            currentDay = DateTime(currentDay.year,
            currentDay.month, currentDay.day + 1)) ... {
              DayDisplay(id: currentDay, title: currentDay.day.toString(),
                titleColor: j % columnNum == 0 ? Colors.pink
                    : j % columnNum == columnNum - 1
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
          // for (int i = 0; i < 11; i++) ... {
          //   'コンテムポレリダンスした日'
          // }
        ];
      }
    }
    return dayLists;
  }

  selectDayPart({int? index}) {
    state.now = DateTime.now();

    if (index != null) {
      state.dayPartActive = true;
      state.dayPartIndex = index;
      state.eventListIndex = null;
    } else if (state.dayPartIndex >= state.dayLists[1].length) {
      state.dayPartIndex -= CalendarPageState.weekdayPartColumnNum;
    }

    state.selectDay = state.dayLists[1][state.dayPartIndex].id;
    setCurrentDay(state.selectDay);

    final homeNotifier = ref.read(homePageNotifierProvider.notifier);
    homeNotifier.setCurrentDay(state.selectDay, true);
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