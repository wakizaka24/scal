import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:scal/f005_calendar_view_model.dart';

import 'f002_home_view_model.dart';
import 'f003_calendar_page.dart';
import 'f008_calendar_repository.dart';
import 'f015_calendar_date_utils.dart';

class WeekCalendarPageState {
  // Control
  static const int basisIndex = 36001;
  PageController calendarController = PageController(
      initialPage: basisIndex);
  PageController hourTitlesController = PageController(
      initialPage: basisIndex);
  bool calendarReload = false;

  // UI
  bool hourPartActive = true;
  int hourPartIndex = 0;
  int? eventListIndex;

  // Data
  static const int timePartColNum = 6;
  static const int weekdayPartRowNum = 7;
  late DateTime basisDate;
  late int baseAddingHourPart;
  int addingHourPart = 0;
  late DateTime now;
  late bool selectionAllDay;
  late DateTime selectionDayAndHour;
  Map<DateTime, List<Event>> allDayEventsMap = {};
  Map<DateTime, List<Event>> hourEventsMap = {};
  late HourTitleDisplay alldayTitle;
  List<List<HourTitleDisplay>> hourTitleLists = [];
  List<List<DayAndWeekdayDisplay>> dayAndWeekdayLists = [];
  List<List<HourDisplay>> hourLists = [];
  String eventListTitle = '';
  List<EventDisplay> eventList = [];

  static WeekCalendarPageState copy(WeekCalendarPageState state) {
    var nState = WeekCalendarPageState();

    // Control
    nState.calendarController = state.calendarController;
    nState.hourTitlesController = state.hourTitlesController;
    nState.calendarReload = state.calendarReload;

    // UI
    nState.hourPartActive = state.hourPartActive;
    nState.hourPartIndex = state.hourPartIndex;
    nState.eventListIndex = state.eventListIndex;

    // Data
    nState.basisDate = state.basisDate;
    nState.baseAddingHourPart = state.baseAddingHourPart;
    nState.addingHourPart = state.addingHourPart;
    nState.now = state.now;
    nState.selectionDayAndHour = state.selectionDayAndHour;
    nState.allDayEventsMap = state.allDayEventsMap;
    nState.hourEventsMap = state.hourEventsMap;
    nState.alldayTitle = state.alldayTitle;
    nState.hourTitleLists = state.hourTitleLists;
    nState.hourLists = state.hourLists;
    nState.eventListTitle = state.eventListTitle;
    nState.eventList = state.eventList;
    return nState;
  }
}

class HourTitleDisplay {
  String title;
  Color titleColor;

  HourTitleDisplay({
    required this.title,
    required this.titleColor
  });
}

class DayAndWeekdayDisplay {
  String dayAndWeekTitle;
  Color dayAndWeekTitleColor;

  DayAndWeekdayDisplay({
    required this.dayAndWeekTitle,
    required this.dayAndWeekTitleColor
  });
}

class HourDisplay {
  bool allDay;
  DateTime id;
  List<HourEventDisplay> eventList;
  Color bgColor;

  HourDisplay({
    required this.allDay,
    required this.id,
    required this.eventList,
    required this.bgColor
  });
}

class HourEventDisplay {
  String title;
  Color titleColor;

  HourEventDisplay({
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

class WeekCalendarPageNotifier extends StateNotifier<WeekCalendarPageState> {
  final Ref ref;
  final int pageIndex;
  late DateTime selectionDay;

  WeekCalendarPageNotifier(this.ref, this.pageIndex,
      WeekCalendarPageState state) : super(state);

  initState(VoidCallback afterInit) async {
    final calendarState = ref.read(calendarPageNotifierProvider(pageIndex));
    selectionDay = calendarState.selectionDay;

    // Data
    state.alldayTitle = HourTitleDisplay(title: '終日',
        titleColor: Colors.black);

    var now = DateTime.now();
    state.basisDate = selectionDay;
    state.baseAddingHourPart = (now.hour / WeekCalendarPageState.timePartColNum
      ).floor();
    state.addingHourPart = state.baseAddingHourPart;
    await updateCalendarData(now: now);
    state.selectionAllDay = false;
    state.selectionDayAndHour = DateTime(selectionDay.year, selectionDay.month,
        selectionDay.day, state.now.hour);
    await setCurrentHour(state.selectionAllDay, state.selectionDayAndHour,
        state.allDayEventsMap, state.hourEventsMap);
    final homeNotifier = ref.read(homePageNotifierProvider.notifier);
    homeNotifier.setCurrentDay(state.selectionDayAndHour, false);

    // UI
    state.hourPartActive = true;
    state.hourPartIndex = 0;
    for (int i=0; i < state.hourLists[1].length; i++) {
      if (state.hourLists[1][i].id == DateTime(state.basisDate.year,
        state.basisDate.month, state.basisDate.day, now.hour)) {
        state.hourPartIndex = i;
        break;
      }
    }
    afterInit();
  }

  onCalendarPageChanged(int hourPart) async {
    const timeColNum = WeekCalendarPageState.timePartColNum;
    const weekdayRowNum = WeekCalendarPageState.weekdayPartRowNum;

    int addingHourPart = hourPart - WeekCalendarPageState.basisIndex
      + state.baseAddingHourPart;
    // debugPrint('addingHourPart=$addingHourPart ${state.baseAddingHourPart}');

    DateTime currentHour = DateTime(state.basisDate.year, state.basisDate.month,
        state.basisDate.day - selectionDay.weekday, state.basisDate.hour
            + addingHourPart * timeColNum);
    if (addingHourPart < state.addingHourPart) { // 過去の時間帯へ移動
      if (currentHour.hour == 24 - timeColNum) { // 日付が跨る
        var moveHour = - (weekdayRowNum - 1) * (24 / timeColNum).floor();
        addingHourPart += moveHour;
        state.baseAddingHourPart = -(hourPart - WeekCalendarPageState
            .basisIndex - addingHourPart);
      }
    } else if (addingHourPart > state.addingHourPart) { // 未来の時間帯へ移動
      if (currentHour.hour == 0) { // 日付が跨る
        var moveHour = (weekdayRowNum - 1) * (24 / timeColNum).floor();
        addingHourPart += moveHour;
        state.baseAddingHourPart = -(hourPart - WeekCalendarPageState
            .basisIndex - addingHourPart);
      }
    } else {
      return;
    }
    debugPrint('onCalendarPageChanged addingHourPart=$addingHourPart');

    state.addingHourPart = addingHourPart;
    await updateCalendarData();
    state.calendarReload = true;

    await selectHour();
  }

  updateCalendarData({DateTime? now}) async {
    state.now = now ?? DateTime.now();
    state.dayAndWeekdayLists = createDayAndWeekdayLists(state.basisDate,
        state.addingHourPart, selectionDay);
    state.hourTitleLists = createHourTitleLists(state.basisDate,
        state.addingHourPart);
    state.hourLists = createHourLists(state.basisDate, state.addingHourPart,
        selectionDay);
    var calendars  = await getCalendars();
    var calendarMap = convertCalendarMap(calendars);
    var startDate = state.hourLists.first.first.id;
    var endDate = state.hourLists.last.last.id;
    var events = await getEvents(calendars, startDate, endDate);
    state.allDayEventsMap = createAllDayEventsMap(events);
    state.hourEventsMap = createHourEventsMap(events);
    state.hourLists = addEvents(state.hourLists, state.allDayEventsMap,
        state.hourEventsMap, calendarMap);
  }

  setCurrentHour(bool allDay, DateTime date,
      Map<DateTime, List<Event>> allDayEventsMap,
      Map<DateTime, List<Event>> hourEventsMap) async {
    state.eventListTitle = '${DateFormat.MMMEd('ja') // 6月12日(月)
        .format(date)} ${allDay ? '終日' : DateFormat.Hm('ja') // 0:00
        .format(date)}';

    var eventList = (allDay ? allDayEventsMap[date] : hourEventsMap[date]) ?? [];
    await setEventList(eventList);
  }

  // TODO 抽象化クラスへ移動する
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

  List<List<DayAndWeekdayDisplay>> createDayAndWeekdayLists(DateTime basisDate,
      int addingHourPart, DateTime selectionDay) {
    const timeColNum = WeekCalendarPageState.timePartColNum;
    const weekdayRowNum = WeekCalendarPageState.weekdayPartRowNum;

    DateTime currentDay = DateTime(basisDate.year, basisDate.month,
        basisDate.day - selectionDay.weekday - weekdayRowNum, basisDate.hour
            + addingHourPart * timeColNum);

    List<List<DayAndWeekdayDisplay>> dayAndWeekdayLists = [];
    for (int pageIndex = 0; pageIndex < 3; pageIndex++) {
      List<DayAndWeekdayDisplay> dayAndWeekdayList = [];
      for (int rowIndex = 0; rowIndex < weekdayRowNum; rowIndex++) {
        DateTime day = DateTime(
            currentDay.year, currentDay.month, currentDay.day
            + pageIndex * weekdayRowNum + rowIndex);
        dayAndWeekdayList.add(DayAndWeekdayDisplay(
            dayAndWeekTitle: DateFormat('MMMd\n(E)').format(day),
            dayAndWeekTitleColor: rowIndex % weekdayRowNum == 0 ? Colors.pink
                : rowIndex % weekdayRowNum == weekdayRowNum - 1
                ? Colors.green : Colors.black
        ));
      }
      dayAndWeekdayLists.add(dayAndWeekdayList);
    }

    return dayAndWeekdayLists;
  }

  List<List<HourTitleDisplay>> createHourTitleLists(DateTime basisDate,
      int addingHourPart) {
    const timeColNum = WeekCalendarPageState.timePartColNum;
    int hour = -timeColNum + addingHourPart * timeColNum;
    return [
      for (int hourPart = 0; hourPart < 3; hourPart++) ... {
        [
          for (int i = 0; i < timeColNum; i++, hour++) ... {
            HourTitleDisplay(title: '${hour % 24}:00',
                titleColor: Colors.black),
          }
        ],
      }
    ];
  }

  List<List<HourDisplay>> createHourLists(DateTime basisDate,
      int addingHourPart, DateTime selectionDay) {
    const timeColNum = WeekCalendarPageState.timePartColNum;
    const weekdayRowNum = WeekCalendarPageState.weekdayPartRowNum;

    DateTime currentHour = DateTime(basisDate.year, basisDate.month,
        basisDate.day - selectionDay.weekday, addingHourPart * timeColNum);

    int prevHourAdding = currentHour.hour == 0
        ? -((weekdayRowNum - 1) * 24 + timeColNum) : -timeColNum;
    int nextHourAdding = currentHour.hour + timeColNum == 24
        ? (weekdayRowNum - 1) * 24 + timeColNum : timeColNum;

    DateTime prevHour = DateTime(currentHour.year, currentHour.month,
        currentHour.day, currentHour.hour + prevHourAdding);
    DateTime nextHour = DateTime(currentHour.year, currentHour.month,
        currentHour.day, currentHour.hour + nextHourAdding);

    // 基準時間
    List<DateTime> hours = [prevHour, currentHour, nextHour];

    List<List<HourDisplay>> calendarList = [];
    for (int pageIndex = 0; pageIndex < 3; pageIndex++) {
      List<HourDisplay> timeList = [];
      var hour = hours[pageIndex];
      for (int rowIndex = 0; rowIndex < weekdayRowNum; rowIndex++) {
        for (int colIndex = 0; colIndex < timeColNum + 1; colIndex++) {
          bool allDay = colIndex == 0;
          DateTime id = DateTime(hour.year, hour.month, hour.day
              + rowIndex, allDay ? 0 : hour.hour + colIndex - 1);
          DateTime now = DateTime(state.now.year, state.now.month,
              state.now.day);
          DateTime currentDay = DateTime(id.year, id.month, id.day);
          Color bgColor = now == currentDay ? todayBgColor
              : Colors.transparent;
          timeList.add(HourDisplay(id: id, allDay: allDay, eventList: [],
              bgColor: bgColor));
        }
      }
      calendarList.add(timeList);
    }

    return calendarList;
  }

  // TODO 抽象化クラスへ移動する
  Future<List<Calendar>> getCalendars() async {
    List<Calendar> calendars = [];
    if (await CalendarRepository().hasPermissions()) {
      calendars = await CalendarRepository().getCalendars();
      // debugPrint('カレンダー数 ${calendars.length}');
    }
    return calendars;
  }

  // TODO 抽象化クラスへ移動する
  Map<String, Calendar> convertCalendarMap(List<Calendar> calendars) {
    Map<String, Calendar> calendarMap = {};
    for (int i = 0; i < calendars.length; i++) {
      var calendar = calendars[i];
      calendarMap[calendar.id!] = calendar;
    }
    return calendarMap;
  }

  // TODO 抽象化クラスへ移動する
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

  Map<DateTime, List<Event>> createAllDayEventsMap(List<Event> events) {
    Map<DateTime, List<Event>> eventsMap = {};
    if (events.isNotEmpty) {
      for (int i = 0; i < events.length; i++) {
        var event = events[i];
        if (!event.allDay!) {
          continue;
        }
        var id = event.start!;
        eventsMap[id] = eventsMap[id] ?? [];
      }
      // debugPrint('終日ごとのイベント数 ${eventsMap.length}');
    }
    return eventsMap;
  }

  Map<DateTime, List<Event>> createHourEventsMap(List<Event> events) {
    Map<DateTime, List<Event>> eventsMap = {};
    if (events.isNotEmpty) {
      for (int i = 0; i < events.length; i++) {
        var event = events[i];
        if (event.allDay!) {
          continue;
        }
        var allHours = CalendarDateUtils().getAllHours(event.start, event.end);
        allHours.fold(eventsMap, (events, day) {
          events[day] = events[day] ?? [];
          events[day]!.add(event);
          return events;
        });
      }
      // debugPrint('時間ごとのイベント数 ${eventsMap.length}');
    }
    return eventsMap;
  }

  List<List<HourDisplay>> addEvents(List<List<HourDisplay>> hourLists,
      Map<DateTime, List<Event>> allDayEventsMap,
      Map<DateTime, List<Event>> hourEventsMap,
      Map<String, Calendar> calendarMap) {
    for (int hourPart = 0; hourPart < hourLists.length; hourPart++) {
      for (int hourIdx = 0; hourIdx < hourLists[hourPart].length; hourIdx++) {
        var hourInfo = hourLists[hourPart][hourIdx];
        hourInfo.eventList.clear();

        var events = (hourInfo.allDay ? allDayEventsMap[hourInfo.id]
            : hourEventsMap[hourInfo.id]) ?? [];

        var dhmStr = DateFormat('dd HH').format(hourInfo.id);
        hourInfo.eventList.add(HourEventDisplay(
            title: dhmStr, titleColor: Colors.black));

        for (int i = 0; i < events.length; i++) {
          var event = events[i];
          var calendar = calendarMap[event.calendarId]!;
          hourInfo.eventList.add(HourEventDisplay(
              title: events[i].title!,
              titleColor: calendar.isDefault! ? Colors.black
                  : const Color(0xffaaaaaa)));
        }
      }
    }
    return hourLists;
  }

  selectHour({int? index}) async {
    state.now = DateTime.now();

    if (index != null) {
      state.hourPartActive = true;
      state.hourPartIndex = index;
      state.eventListIndex = null;
    }

    state.selectionAllDay = state.hourLists[1][state.hourPartIndex].allDay;
    state.selectionDayAndHour = state.hourLists[1][state.hourPartIndex].id;

    await setCurrentHour(state.selectionAllDay, state.selectionDayAndHour,
        state.allDayEventsMap, state.hourEventsMap);

    final homeNotifier = ref.read(homePageNotifierProvider.notifier);
    homeNotifier.setCurrentDay(state.selectionDayAndHour, true);
    updateState();
  }

  selectEventListPart(int index) {
    state.hourPartActive = false;
    state.eventListIndex = index;
    updateState();
  }

  updateState() async {
    state = WeekCalendarPageState.copy(state);
  }
}

final weekCalendarPageNotifierProvider = StateNotifierProvider.family
    .autoDispose<WeekCalendarPageNotifier, WeekCalendarPageState, int>((ref,
    index) {
  var list = List.filled(2, WeekCalendarPageState());
  return WeekCalendarPageNotifier(ref, index, list[index]);
});