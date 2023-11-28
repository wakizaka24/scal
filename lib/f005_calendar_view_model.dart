import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import 'f002_home_view_model.dart';
import 'f003_calendar_page.dart';
import 'f008_calendar_repository.dart';
import 'f015_calendar_date_utils.dart';

class CalendarPageState {
  // Control
  bool calendarReload = false;
  static const int basisIndex = 36001;
  PageController calendarController = PageController(
      initialPage: basisIndex);

  // UI
  bool dayPartActive = true;
  int dayPartIndex = 0;
  int? eventListIndex;

  // Data
  static const int weekdayPartColumnNum = 7;
  DateTime basisDate = DateTime.now();
  int addingMonth = 0;
  late DateTime now;
  late DateTime selectionDay;
  Map<DateTime, List<Event>> eventsMap = {};
  List<WeekdayDisplay> weekdayList = [];
  List<List<DayDisplay>> dayLists = [];
  String eventListTitle = '';
  List<EventDisplay> eventList = [];

  static CalendarPageState copy(CalendarPageState state) {
    var nState = CalendarPageState();

    // Control
    nState.calendarReload = state.calendarReload;
    nState.calendarController = state.calendarController;

    // UI
    nState.dayPartActive = state.dayPartActive;
    nState.dayPartIndex = state.dayPartIndex;
    nState.eventListIndex = state.eventListIndex;

    // Data
    nState.basisDate = state.basisDate;
    nState.addingMonth = state.addingMonth;
    nState.now = state.now;
    nState.selectionDay = state.selectionDay;
    nState.eventsMap = state.eventsMap;
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
  List<DayEventDisplay> eventList;
  Color bgColor;

  DayDisplay({
    required this.id,
    required this.title,
    required this.titleColor,
    required this.eventList,
    required this.bgColor
  });
}

class DayEventDisplay {
  String title;
  Color titleColor;

  DayEventDisplay({
    required this.title,
    required this.titleColor
  });
}

class EventDisplay {
  String id;
  bool editing;
  String head;
  Color lineColor;
  String title;
  Color fontColor;

  EventDisplay({
    required this.id,
    required this.editing,
    required this.head,
    required this.lineColor,
    required this.title,
    required this.fontColor
  });
}

class CalendarPageNotifier extends StateNotifier<CalendarPageState> {
  final Ref ref;

  CalendarPageNotifier(this.ref, CalendarPageState state)
      : super(state);

  initState(VoidCallback afterInit) async {
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
    state.selectionDay = DateTime(state.now.year, state.now.month, state.now.day);
    await setCurrentDay(state.selectionDay, state.eventsMap);
    final homeNotifier = ref.read(homePageNotifierProvider.notifier);
    homeNotifier.setCurrentDay(state.selectionDay, false);

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
    afterInit();
  }

  onCalendarPageChanged(int monthIndex) async {
    int addingMonth = monthIndex - CalendarPageState.basisIndex;
    if (state.addingMonth == addingMonth) {
      return;
    }
    // debugPrint('onCalendarPageChanged addingMonth=$addingMonth');
    state.addingMonth = addingMonth;
    await updateCalendarData();
    state.calendarReload = true;

    await selectDay();
  }

  updateCalendarData() async {
    state.now = DateTime.now();
    state.dayLists = createDayLists(state.basisDate, state.addingMonth);
    var calendars  = await getCalendars();
    var calendarMap = convertCalendarMap(calendars);
    var startDate = state.dayLists.first.first.id;
    var endDate = state.dayLists.last.last.id;
    var events = await getEvents(calendars, startDate, endDate);
    state.eventsMap = createEventsMap(events);
    state.dayLists = addEvents(state.dayLists, state.eventsMap, calendarMap);
  }

  setCurrentDay(DateTime date, Map<DateTime, List<Event>> eventsMap) async {
    state.eventListTitle = DateFormat.MMMEd('ja') // 6月12日(月)
        .format(date).toString();
    var eventList = eventsMap[date] ?? [];
    await setEventList(eventList);
  }

  setEventList(List<Event> eventList) async {
    state.eventList = [];
    for (int i = 0; i < eventList.length; i++) {
      var event = eventList[i];
      var calendars = await CalendarRepository().getCalendars();
      var calendar = calendars.firstWhere((calendar) =>
      calendar.id == event.calendarId);
      var id = event.eventId!;
      var editing = calendar.isReadOnly!;
      var head = '${DateFormat.jm('ja').format(event.start!)}\n'
          '${DateFormat.jm('ja').format(event.end!)}';
      if (event.start!.year != event.end!.year
          || event.start!.month != event.end!.month
          || event.start!.day != event.end!.day) {
        head = '連日';
      } else if (event.allDay!) {
        head = '終日';
      }
      var lineColor = Color(calendar.color!);
      var title = event.title!;
      var fontColor = calendar.isDefault! ? Colors.black
          : const Color(0xffaaaaaa);

      state.eventList.add(EventDisplay(id: id, editing: editing,
          head: head, lineColor: lineColor, title: title, fontColor: fontColor
      ));
    }
  }

  List<List<DayDisplay>> createDayLists(DateTime basisDate, int addingMonth) {
    const columnNum = CalendarPageState.weekdayPartColumnNum;

    DateTime prevMonth = DateTime(basisDate.year, basisDate.month
        - 1 + addingMonth, 1);

    // 月部分の先頭の日付
    DateTime currentDay = DateTime(prevMonth.year, prevMonth.month,
        prevMonth.day - prevMonth.weekday % columnNum);

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

  Future<List<Calendar>> getCalendars() async {
    List<Calendar> calendars = [];
    if (await CalendarRepository().hasPermissions()) {
      calendars = await CalendarRepository().getCalendars();
      // debugPrint('カレンダー数 ${calendars.length}');
    }
    return calendars;
  }

  Map<String, Calendar> convertCalendarMap(List<Calendar> calendars) {
    Map<String, Calendar> calendarMap = {};
    for (int i = 0; i < calendars.length; i++) {
      var calendar = calendars[i];
      calendarMap[calendar.id!] = calendar;
    }
    return calendarMap;
  }

  Future<List<Event>> getEvents(List<Calendar> calendars,
      DateTime startDate, DateTime endDate) async {
    List<Event> events = [];
    if (calendars.isNotEmpty) {
      for (int i = 0; i < calendars.length; i++) {
        var calendar = calendars[i];
        events.addAll(await CalendarRepository()
            .getEvents(calendar.id!, startDate, endDate));
      }
    }
    return events;
  }

  Map<DateTime, List<Event>> createEventsMap(List<Event> events) {
    Map<DateTime, List<Event>> eventsMap = {};
    if (events.isNotEmpty) {
      for (int i = 0; i < events.length; i++) {
        var event = events[i];
        var allDays = CalendarDateUtils().getAllDays(event.start, event.end);
        allDays.fold(eventsMap, (events, day) {
          events[day] = events[day] ?? [];
          events[day]!.add(event);
          return events;
        });
      }
      // debugPrint('日付ごとのイベント数 ${eventsMap.length}');
    }
    return eventsMap;
  }

  List<List<DayDisplay>> addEvents(List<List<DayDisplay>> dayLists,
      Map<DateTime, List<Event>> eventsMap, Map<String, Calendar> calendarMap) {
    for (int month = 0; month < dayLists.length; month++) {
      for (int day = 0; day < dayLists[month].length; day++) {
        var dayInfo = dayLists[month][day];
        dayInfo.eventList.clear();
        var events = eventsMap[dayInfo.id] ?? [];
        for (int i = 0; i < events.length; i++) {
          var event = events[i];
          var calendar = calendarMap[event.calendarId]!;
          dayInfo.eventList.add(DayEventDisplay(
              title: events[i].title!,
              titleColor: calendar.isDefault! ? Colors.black
                  : const Color(0xffaaaaaa)));
        }
      }
    }
    return dayLists;
  }

  selectDay({int? index}) async {
    state.now = DateTime.now();

    if (index != null) {
      state.dayPartActive = true;
      state.dayPartIndex = index;
      state.eventListIndex = null;
    } else if (state.dayPartIndex >= state.dayLists[1].length) {
      state.dayPartIndex -= CalendarPageState.weekdayPartColumnNum;
    }

    state.selectionDay = state.dayLists[1][state.dayPartIndex].id;
    await setCurrentDay(state.selectionDay, state.eventsMap);

    await updateSelectionDayOfHome();
    updateState();
  }

  updateSelectionDayOfHome() async {
    final homeNotifier = ref.read(homePageNotifierProvider.notifier);
    homeNotifier.setCurrentDay(state.selectionDay, true);
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