import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import 'f002_home_view_model.dart';
import 'f003_calendar_page.dart';
import 'f005_calendar_repository.dart';
import 'f006_calendar_date_utils.dart';

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
  Map<DateTime, List<Event>> events = {};
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
    nState.events = state.events;
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

    await updateCalendarData();
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
    await updateCalendarData();
    state.calendarReload = true;

    selectDayPart();
  }

  updateCalendarData() async {
    state.now = DateTime.now();
    state.dayLists = createDayLists(state.basisDate, state.addMonth);
    var startDate = state.dayLists.first.first.id;
    var endDate = state.dayLists.last.last.id;
    state.events = await getEvents(startDate, endDate);
    state.dayLists = await addEvents(state.dayLists, state.events);
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
            currentDay = currentDay.add(const Duration(days: 1))) ... {
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

  Future<Map<DateTime, List<Event>>> getEvents(DateTime startDate,
      DateTime endDate) async {
    Map<DateTime, List<Event>> events = {};
    if (await CalendarRepository().hasPermissions()) {
      var calendars = await CalendarRepository().getCalendars();
      debugPrint('カレンダー数 ${calendars.length}');

      for (int i = 0; i < calendars.length; i++) {
        var calendar = calendars[i];

        // if (!calendar.isDefault!) {
        //   break;
        // }

        var calendarEvents = await CalendarRepository()
            .getEvents(calendar.id!, startDate, endDate);

        for (int i = 0; i < calendarEvents.length; i++) {
          var event = calendarEvents[i];
          var allDays = CalendarDateUtils().getAllDays(event.start, event.end);
          allDays.fold(events, (events, day) {
            events[day] = events[day] ?? [];
            events[day]!.add(event);
            return events;
          });
        }
      }
      debugPrint('日付ごとのイベント数 ${events.length}');
    }
    return events;
  }

  Future<List<List<DayDisplay>>> addEvents(List<List<DayDisplay>> dayLists,
    Map<DateTime, List<Event>> events) async {
    for (int month = 0; month < dayLists.length; month++) {
      for (int day = 0; day < dayLists[month].length; day++) {
        var dayInfo = dayLists[month][day];
        dayInfo.eventList = [
          for (int i = 0; i < (events[dayInfo.id] ?? []).length; i++) ... {
            events[dayInfo.id]![i].title!
          }
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