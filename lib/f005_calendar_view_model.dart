import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import 'f002_home_view_model.dart';
import 'f003_calendar_page.dart';
import 'f008_calendar_repository.dart';
import 'f015_calendar_date_utils.dart';

class CalendarPageState {
  // Control-Common
  // 擬似無制限中央インデックス
  static const int pseudoUnlimitedCenterIndex = 36001;

  // Control-Month Calendar/Week Calendar
  PageController calendarSwitchingController = PageController(
    initialPage: 0);
  bool monthCalendarVisible = true;

  // Control-Month Calendar
  bool monthCalendarReload = false;
  PageController monthCalendarController = PageController(
      initialPage: pseudoUnlimitedCenterIndex);

  // Control-Week Calendar
  bool weekCalendarReload = false;
  PageController weekCalendarController = PageController(
      initialPage: pseudoUnlimitedCenterIndex);
  PageController daysAndWeekdaysController = PageController(
      initialPage: pseudoUnlimitedCenterIndex);

  // Data-Month Calendar/Week Calendar
  late DateTime now;

  // Data-Month Calendar
  static const int weekdayPartColNum = 7;
  DateTime basisMonthDate = DateTime.now();
  int addingMonth = 0;
  late DateTime selectionDay;
  Map<DateTime, List<Event>> eventsMap = {};
  List<WeekdayDisplay> weekdayList = [];
  List<List<DayDisplay>> dayLists = [];

  // Data-Week Calendar
  static const int weekdayPartRowNum = 7;
  late DateTime basisWeekDate;
  int addingWeek = 0;
  int preAddingWeek = 0;
  int indexAddingWeek = 0;
  late bool selectionAllDay;
  late DateTime selectionDayAndHour;
  Map<DateTime, List<Event>> allDayEventsMap = {};
  Map<DateTime, List<Event>> hourEventsMap = {};
  List<List<DayAndWeekdayDisplay>> daysAndWeekdaysList = [];
  List<List<HourDisplay>> hoursList = [];

  // Data-Event List
  String eventListTitle = '';
  List<EventDisplay> eventList = [];

  // UI-Month Calendar/Week Calendar
  bool cellActive = true;

  // UI-Month Calendar
  int dayPartIndex = 0;

  // UI-Week Calendar
  int hourPartIndex = 0;

  // UI-Event List
  int? eventListIndex;

  static CalendarPageState copy(CalendarPageState state) {
    var nState = CalendarPageState();

    // Control-Month Calendar/Week Calendar
    nState.calendarSwitchingController = state.calendarSwitchingController;
    nState.monthCalendarVisible = state.monthCalendarVisible;

    // Control-Month Calendar
    nState.monthCalendarReload = state.monthCalendarReload;
    nState.monthCalendarController = state.monthCalendarController;

    // Control-Week Calendar
    nState.weekCalendarReload = state.weekCalendarReload;
    nState.weekCalendarController = state.weekCalendarController;
    nState.daysAndWeekdaysController = state.daysAndWeekdaysController;

    // Data-Month Calendar/Week Calendar
    nState.now = state.now;

    // Data-Month Calendar
    nState.basisMonthDate = state.basisMonthDate;
    nState.addingMonth = state.addingMonth;
    nState.selectionDay = state.selectionDay;
    nState.eventsMap = state.eventsMap;
    nState.weekdayList = state.weekdayList;
    nState.dayLists = state.dayLists;

    // Data-Week Calendar
    nState.basisWeekDate = state.basisWeekDate;
    nState.addingWeek = state.addingWeek;
    nState.preAddingWeek = state.preAddingWeek;
    nState.indexAddingWeek = state.indexAddingWeek;
    nState.now = state.now;
    nState.selectionDayAndHour = state.selectionDayAndHour;
    nState.allDayEventsMap = state.allDayEventsMap;
    nState.hourEventsMap = state.hourEventsMap;
    nState.daysAndWeekdaysList = state.daysAndWeekdaysList;
    nState.hoursList = state.hoursList;

    // Data-Event List
    nState.eventListTitle = state.eventListTitle;
    nState.eventList = state.eventList;

    // UI-Month Calendar/Week Calendar
    nState.cellActive = state.cellActive;

    // UI-Month Calendar
    nState.dayPartIndex = state.dayPartIndex;

    // UI-Week Calendar
    nState.hourPartIndex = state.hourPartIndex;

    // UI-Event List
    nState.eventListIndex = state.eventListIndex;

    return nState;
  }
}

// Type-Month Calendar/Week Calendar
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

// Type-Month Calendar
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

// Type-Week Calendar
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

class CalendarPageNotifier extends StateNotifier<CalendarPageState> {
  final Ref ref;

  CalendarPageNotifier(this.ref, CalendarPageState state)
      : super(state);

  initState(VoidCallback afterInit) async {
    // Data-Month Calendar/Week Calendar
    state.now = DateTime.now();

    // Data-Month Calendar
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

    await updateMonthCalendarData();
    state.selectionDay = DateTime(state.now.year, state.now.month,
        state.now.day);
    await setCurrentDay(state.selectionDay, state.eventsMap);
    final homeNotifier = ref.read(homePageNotifierProvider.notifier);
    homeNotifier.setCurrentDay(state.selectionDay, false);

    // UI-Month Calendar/Week Calendar
    state.cellActive = true;
    DateTime now = state.now;

    // UI-Month Calendar
    state.dayPartIndex = 0;
    for (int i=0; i < state.dayLists[1].length; i++) {
      if (state.dayLists[1][i].id == DateTime(now.year, now.month, now.day)) {
        state.dayPartIndex = i;
        break;
      }
    }

    // Data-Week Calendar
    await initWeekCalendar();

    afterInit();
  }

  initWeekCalendar() async {
    state.basisWeekDate = state.selectionDay;
    await updateWeekCalendarData();
    state.selectionAllDay = false;
    state.selectionDayAndHour = DateTime(state.selectionDay.year,
        state.selectionDay.month, state.selectionDay.day, state.now.hour);
    await setCurrentHour(state.selectionAllDay, state.selectionDayAndHour,
        state.allDayEventsMap, state.hourEventsMap);
  }

  // MonthCalendar

  onCalendarPageChanged(int monthIndex) async {
    int addingMonth = monthIndex - CalendarPageState.pseudoUnlimitedCenterIndex;
    if (state.addingMonth == addingMonth) {
      return;
    }
    // debugPrint('onCalendarPageChanged addingMonth=$addingMonth');
    state.addingMonth = addingMonth;
    state.now = DateTime.now();
    await updateMonthCalendarData();
    state.monthCalendarReload = true;

    await selectDay();
  }

  updateMonthCalendarData() async {
    state.dayLists = createDayLists(state.basisMonthDate, state.addingMonth);
    var calendars  = await getCalendars();
    var calendarMap = convertCalendarMap(calendars);
    var startDate = state.dayLists.first.first.id;
    var endDate = state.dayLists.last.last.id;
    var events = await getEventsForWeekCalendar(calendars, startDate, endDate);
    state.eventsMap = createEventsMap(events);
    state.dayLists = addEventsForMonthCalendar(state.dayLists, state.eventsMap,
        calendarMap);
  }

  setCurrentDay(DateTime date, Map<DateTime, List<Event>> eventsMap) async {
    state.eventListTitle = DateFormat.MMMEd('ja') // 6月12日(月)
        .format(date).toString();
    var eventList = eventsMap[date] ?? [];
    await setEventList(eventList);
  }

  List<List<DayDisplay>> createDayLists(DateTime basisDate, int addingMonth) {
    const columnNum = CalendarPageState.weekdayPartColNum;

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

  List<List<DayDisplay>> addEventsForMonthCalendar(List<List<DayDisplay>> dayLists,
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
      state.cellActive = true;
      state.dayPartIndex = index;
      state.eventListIndex = null;
    } else if (state.dayPartIndex >= state.dayLists[1].length) {
      state.dayPartIndex -= CalendarPageState.weekdayPartColNum;
    }

    state.selectionDay = state.dayLists[1][state.dayPartIndex].id;
    await setCurrentDay(state.selectionDay, state.eventsMap);

    await updateSelectionDayOfHome();
    updateState();
  }

  // Week Calendar

  onHourCalendarPageChanged(int index) async {
    state.now = DateTime.now();
    await updateWeekCalendarData();
    state.weekCalendarReload = true;

    await selectHour();
  }

  onWeekCalendarPageChanged(int index) async {
    int addingWeek = index - CalendarPageState.pseudoUnlimitedCenterIndex
      + state.indexAddingWeek;
    debugPrint('onWeekCalendarPageChanged addingWeek=$addingWeek');

    state.addingWeek = addingWeek;
    state.preAddingWeek = state.addingWeek;

    state.now = DateTime.now();
    await updateWeekCalendarData();
    state.weekCalendarReload = true;

    await selectHour();
  }

  updateWeekCalendarData() async {
    state.daysAndWeekdaysList = createDayAndWeekdayLists(state.basisWeekDate,
        state.addingWeek, state.selectionDay);
    state.hoursList = createHourLists(state.basisWeekDate,
        state.addingWeek, state.selectionDay);
    var calendars  = await getCalendars();
    var calendarMap = convertCalendarMap(calendars);
    var startDate = state.hoursList.first.first.id;
    var endDate = state.hoursList.last.last.id;
    var events = await getEventsForWeekCalendar(calendars, startDate, endDate);
    state.allDayEventsMap = createAllDayEventsMap(events);
    state.hourEventsMap = createHourEventsMap(events);
    state.hoursList = addEvents(state.hoursList,
        state.allDayEventsMap, state.hourEventsMap, calendarMap);
  }

  setCurrentHour(bool allDay, DateTime date,
      Map<DateTime, List<Event>> allDayEventsMap,
      Map<DateTime, List<Event>> hourEventsMap) async {
    state.eventListTitle = '${DateFormat.MMMEd('ja') // 6月12日(月)
        .format(date)} ${allDay ? '終日' : DateFormat.Hm('ja') // 0:00
        .format(date)}';

    var eventList = (allDay ? allDayEventsMap[date] : hourEventsMap[date])
        ?? [];
    await setEventList(eventList);
  }

  List<List<DayAndWeekdayDisplay>> createDayAndWeekdayLists(DateTime basisDate,
      int addingWeek, DateTime selectionDay) {
    const weekdayRowNum = CalendarPageState.weekdayPartRowNum;

    DateTime currentDay = DateTime(basisDate.year, basisDate.month,
        basisDate.day - selectionDay.weekday % weekdayRowNum - weekdayRowNum
            + addingWeek * weekdayRowNum, 0);

    List<List<DayAndWeekdayDisplay>> dayAndWeekdayLists = [];
    for (int pageIndex = 0; pageIndex < 3; pageIndex++) {
      List<DayAndWeekdayDisplay> dayAndWeekdayList = [];
      for (int rowIndex = 0; rowIndex < weekdayRowNum; rowIndex++) {
        DateTime day = DateTime(
            currentDay.year, currentDay.month, currentDay.day
            + pageIndex * weekdayRowNum + rowIndex);
        dayAndWeekdayList.add(DayAndWeekdayDisplay(
            dayAndWeekTitle: DateFormat('M/d\n(E)', 'ja').format(day),
            dayAndWeekTitleColor: rowIndex % weekdayRowNum == 0 ? Colors.pink
                : rowIndex % weekdayRowNum == weekdayRowNum - 1
                ? Colors.green : Colors.black
        ));
      }
      dayAndWeekdayLists.add(dayAndWeekdayList);
    }

    return dayAndWeekdayLists;
  }

  List<List<HourDisplay>> createHourLists(DateTime basisDate,
      int addingWeek, DateTime selectionDay) {
    const weekdayRowNum = CalendarPageState.weekdayPartRowNum;

    DateTime currentWeek = DateTime(basisDate.year, basisDate.month,
        basisDate.day - selectionDay.weekday % weekdayRowNum + addingWeek
            * weekdayRowNum, 0);
    DateTime prevWeek = DateTime(currentWeek.year, currentWeek.month,
        currentWeek.day - weekdayRowNum, 0);
    DateTime nextWeek = DateTime(currentWeek.year, currentWeek.month,
        currentWeek.day + weekdayRowNum, 0);

    // 基準時間
    List<DateTime> weeks = [prevWeek, currentWeek, nextWeek];

    List<List<HourDisplay>> calendarLists = [];
    for (var week in weeks) {
      List<HourDisplay> calendarList = createHourList(week);
      calendarLists.add(calendarList);
    }

    return calendarLists;
  }

  List<HourDisplay> createHourList(DateTime week) {
    const timeColNum = 6;
    var timeInterval = 24 ~/ timeColNum;
    const weekdayRowNum = CalendarPageState.weekdayPartRowNum;

    List<HourDisplay> wholeTimeList = [];
    for (int rowIndex = 0; rowIndex < weekdayRowNum; rowIndex++) {
      for (int colIndex = 0; colIndex < timeColNum + 1; colIndex++) {
        bool allDay = colIndex == timeColNum;
        DateTime id = DateTime(week.year, week.month, week.day
            + rowIndex, allDay ? 0 : week.hour + colIndex * timeInterval);
        DateTime now = DateTime(state.now.year, state.now.month,
            state.now.day);
        DateTime currentDay = DateTime(id.year, id.month, id.day);
        Color bgColor = now == currentDay ? todayBgColor
            : Colors.transparent;
        wholeTimeList.add(HourDisplay(id: id, allDay: allDay, eventList: [],
            bgColor: bgColor));
      }
    }
    return wholeTimeList;
  }

  Map<DateTime, List<Event>> createAllDayEventsMap(List<Event> events) {
    Map<DateTime, List<Event>> eventsMap = {};
    for (int i = 0; i < events.length; i++) {
      var event = events[i];
      if (!event.allDay!) {
        continue;
      }
      var dateTime = event.start!;
      var id = DateTime(dateTime.year, dateTime.month, dateTime.day);
      eventsMap[id] = eventsMap[id] ?? [];
      eventsMap[id]!.add(event);
    }
    //debugPrint('終日ごとのイベント数 ${eventsMap.length}');
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
          // TODO: 四時間ごとにまとめる
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


    for (var hourList in hourLists) {
      for (var hourInfo in hourList) {

        hourInfo.eventList.clear();

        var events = (hourInfo.allDay ? allDayEventsMap[hourInfo.id]
            : hourEventsMap[hourInfo.id]) ?? [];

        // TODO: デバック中
        var dhmStr = DateFormat('dd HH').format(hourInfo.id);
        hourInfo.eventList.add(HourEventDisplay(
            title: dhmStr, titleColor: Colors.black));

        for (var event in events) {
          var calendar = calendarMap[event.calendarId]!;
          hourInfo.eventList.add(HourEventDisplay(
              title: event.title!,
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
      state.cellActive = true;
      state.hourPartIndex = index;
      state.eventListIndex = null;
    }

    var hourPart = state.hoursList[1];
    state.selectionAllDay = hourPart[state.hourPartIndex].allDay;
    state.selectionDayAndHour = hourPart[state.hourPartIndex].id;

    await setCurrentHour(state.selectionAllDay, state.selectionDayAndHour,
        state.allDayEventsMap, state.hourEventsMap);

    await updateSelectionDayOfHome();
    updateState();
  }

  // Event List

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

  selectEventListPart(int index) {
    state.cellActive = false;
    state.eventListIndex = index;
    updateState();
  }

  // Common

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

  Future<List<Event>> getEventsForWeekCalendar(List<Calendar> calendars,
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

  updateSelectionDayOfHome() async {
    final homeNotifier = ref.read(homePageNotifierProvider.notifier);
    homeNotifier.setCurrentDay(state.selectionDay, true);
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