import 'dart:io';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:scal/f017_design_config.dart';

import 'f002_home_view_model.dart';
import 'f007_calendar_repository.dart';
import 'f008_calendar_config.dart';
import 'f016_calendar_utils.dart';
import 'f021_event_detail_view_model.dart';

// Type-Month Calendar/Week Calendar
class EventDisplay {
  String eventId;
  String calendarId;
  bool editing;
  bool sameCell;
  bool readOnly;
  String head;
  Color lineColor;
  String title;
  Color fontColor;
  DateTime? fixedDateTime;
  String? fixedTitle;
  bool hourMoving;
  bool hourChoiceMode;
  List<int> movingHourChoices;
  Event? event;

  EventDisplay({
    required this.eventId,
    required this.calendarId,
    required this.editing,
    required this.sameCell,
    required this.readOnly,
    required this.head,
    required this.lineColor,
    required this.title,
    required this.fontColor,
    required this.fixedDateTime,
    required this.fixedTitle,
    required this.hourMoving,
    required this.hourChoiceMode,
    required this.movingHourChoices,
    this.event
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
  bool today;

  DayDisplay({
    required this.id,
    required this.title,
    required this.titleColor,
    required this.eventList,
    required this.today
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
  bool today;

  DayAndWeekdayDisplay({
    required this.dayAndWeekTitle,
    required this.dayAndWeekTitleColor,
    required this.today
  });
}

class HourDisplay {
  bool allDay;
  DateTime id;
  String title;
  Color titleColor;
  List<HourEventDisplay> eventList;
  bool today;

  HourDisplay({
    required this.allDay,
    required this.id,
    required this.title,
    required this.titleColor,
    required this.eventList,
    required this.today
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

class CalendarPageState {
  // Control-Common
  // 擬似無制限中央インデックス
  static const int pseudoUnlimitedCenterIndex = 36001;

  // Control-Month Calendar/Week Calendar
  PageController calendarSwitchingController = PageController(
    initialPage: 0);

  // Control-Month Calendar
  PageController monthCalendarController = PageController(
      initialPage: pseudoUnlimitedCenterIndex);

  // Control-Event List
  List<GlobalKey> eventListCellKeyList = [];

  // Data-Month Calendar/Week Calendar
  bool initialized = false;
  late DateTime now;
  bool preEventDataLoading = false;
  Map<String, Calendar> calendarMap = {};
  List<Event> calendarEvents = [];
  Map<String, Event> eventIdEventMap = {};
  Map<String, DateTime> eventIdStartDateMap = {};
  bool cellActive = true;
  int calendarSwitchingIndex = 0;

  // Data-Month Calendar
  static const int weekdayPartColNum = 7;
  DateTime basisMonthDate = DateTime.now();
  int addingMonth = 0;
  Map<DateTime, List<Event>> dayEventsMap = {};
  List<WeekdayDisplay> weekdayList = [];
  List<List<DayDisplay>> dayLists = [];
  late DateTime selectionDate;
  int dayPartIndex = 0;

  // Data-Week Calendar
  static const int timeColNum = 6;
  static const int hoursPartRowNum = 7;
  late bool selectionAllDay;
  Map<DateTime, List<Event>> allDayEventsMap = {};
  Map<DateTime, List<Event>> hourEventsMap = {};
  List<DayAndWeekdayDisplay> dayAndWeekdayList = [];
  List<HourDisplay> hours = [];
  late DateTime selectionHour;
  int hourPartIndex = 0;

  // Data-Event List
  String eventListTitle = '';
  List<EventDisplay> eventList = [];
  int? eventListIndex;
  int? scrollEventListIndex;
  List<EventDisplay> editingEventList = [];

  static CalendarPageState copy(CalendarPageState state) {
    var nState = CalendarPageState();

    // Control-Month Calendar/Week Calendar
    nState.calendarSwitchingController = state.calendarSwitchingController;

    // Control-Month Calendar
    nState.monthCalendarController = state.monthCalendarController;

    // Control-Event List
    nState.eventListCellKeyList = state.eventListCellKeyList;

    // Data-Month Calendar/Week Calendar
    nState.initialized = state.initialized;
    nState.now = state.now;
    nState.preEventDataLoading = state.preEventDataLoading;
    nState.calendarMap = state.calendarMap;
    nState.calendarEvents = state.calendarEvents;
    nState.eventIdEventMap = state.eventIdEventMap;
    nState.eventIdStartDateMap = state.eventIdStartDateMap;
    nState.cellActive = state.cellActive;
    nState.calendarSwitchingIndex = state.calendarSwitchingIndex;

    // Data-Month Calendar
    nState.basisMonthDate = state.basisMonthDate;
    nState.addingMonth = state.addingMonth;
    nState.dayEventsMap = state.dayEventsMap;
    nState.weekdayList = state.weekdayList;
    nState.dayLists = state.dayLists;
    nState.selectionDate = state.selectionDate;
    nState.dayPartIndex = state.dayPartIndex;

    // Data-Week Calendar
    nState.selectionAllDay = state.selectionAllDay;
    nState.allDayEventsMap = state.allDayEventsMap;
    nState.hourEventsMap = state.hourEventsMap;
    nState.dayAndWeekdayList = state.dayAndWeekdayList;
    nState.hours = state.hours;
    nState.selectionHour = state.selectionHour;
    nState.hourPartIndex = state.hourPartIndex;

    // Data-Event List
    nState.eventListTitle = state.eventListTitle;
    nState.eventList = state.eventList;
    nState.eventListIndex = state.eventListIndex;
    nState.scrollEventListIndex = state.scrollEventListIndex;
    nState.editingEventList = state.editingEventList;

    return nState;
  }
}

class CalendarPageNotifier extends StateNotifier<CalendarPageState> {
  final Ref ref;
  CalendarRepository calendarRepo = CalendarRepository();

  CalendarPageNotifier(this.ref, CalendarPageState state)
      : super(state);

  initState() async {
    if (state.initialized) {
      return;
    }

    // Data-Month Calendar/Week Calendar
    state.now = DateTime.now();

    // Data-Month Calendar
    await updateMonthCalendarState();
    state.selectionDate = DateTime(state.now.year, state.now.month,
        state.now.day);

    // UI-Month Calendar/Week Calendar
    state.cellActive = true;
    DateTime now = state.now;

    // UI-Month Calendar
    await selectDayPartIndex(now);

    await updateSelectionDayOfHome();
    await setDayEventList(state.selectionDate, state.dayEventsMap);
    await updateWeekCalendarState();
    await initSelectionWeekCalendar();

    state.initialized = true;
  }

  @override
  dispose() {
    state.calendarSwitchingController.dispose();
    state.monthCalendarController.dispose();
    super.dispose();
  }

  // Month Calendar/Week Calendar

  selectDayPartIndex(DateTime date) async {
    state.dayPartIndex = 0;
    for (int i=0; i < state.dayLists[1].length; i++) {
      if (state.dayLists[1][i].id == DateTime(date.year, date.month,
          date.day)) {
        state.dayPartIndex = i;
        break;
      }
    }
  }

  setCalendarSwitchingPageIndex(int index) async {
    state.calendarSwitchingIndex = index;
    if (index == 0) {
      await selectDay();
      await updateWeekCalendarState();
      await initSelectionWeekCalendar();
    } else {
      await selectHour();
    }
    await updateState();
  }

  String getCalendarSwitchingButtonTitle() {
    return state.calendarSwitchingIndex == 0 ?
        "Weekly" : state.calendarSwitchingIndex == 1
        ? "Monthly" : "";
  }

  // Month Calendar

  onTapTodayButton() async {
    await moveCalendar(DateTime.now());
  }

  Future<void> moveCalendar(DateTime distDateTime, {bool allDay=false}) async {
    Future<bool> moveToday() async {
      var dayPartIndex = state.dayLists[1].indexWhere((day) {
        var diffHour = distDateTime.difference(day.id).inHours;
        return diffHour >= 0 && diffHour < 24;
      });
      if (dayPartIndex != -1) {
        if (state.dayPartIndex != dayPartIndex) {
          await onTapDownCalendarDay(dayPartIndex);
        }
        return true;
      }

      return false;
    }

    var hoursPartTimeInterval = 24 / CalendarPageState.timeColNum;
    if (state.calendarSwitchingIndex != 0) {
      var hourPartIndex = state.hours.indexWhere((hour) {
        var diffHour = distDateTime.difference(hour.id).inHours;
        var sameHour = diffHour >= 0 && diffHour < hoursPartTimeInterval;
        var sameDay = diffHour >= 0 && diffHour < 24;
        return !allDay && sameHour && !hour.allDay
            || allDay && sameDay && hour.allDay;
      });
      if (hourPartIndex != -1) {
        if (state.hourPartIndex != hourPartIndex) {
          await onTapDownCalendarHour(hourPartIndex);
        }

        return;
      }

      await state.calendarSwitchingController
          .animateToPage(0, duration: const Duration(milliseconds: 150),
          curve: Curves.easeIn);
      return;
    }

    if (await moveToday()) {
      return;
    }

    var basisDate = state.basisMonthDate;
    var calendarMonth = basisDate.year * 12 + basisDate.month
        + state.addingMonth;
    var destMonth = distDateTime.year * 12 + distDateTime.month;
    var addingMonth = destMonth - calendarMonth;
    var ms = addingMonth.abs() * 100;
    var animation = Platform.isIOS && ms <= 2400;
    var page = state.monthCalendarController.page!.toInt() + addingMonth;

    if (!animation) {
      if (Platform.isIOS) {
        await updateMonthCalendarState(preLoadingAddingMonth: addingMonth);
        state.preEventDataLoading = true;
      }
      state.monthCalendarController.jumpToPage(page);
    } else {
      await state.monthCalendarController.animateToPage(
          page, duration: Duration(milliseconds: ms),
          curve: Curves.linear);
    }

    await moveToday();
  }

  onTapDownCalendarDay(int index) async {
    await selectDay(index: index);
    await updateWeekCalendarState();
    await initSelectionWeekCalendar();
    await updateState();
  }

  onCalendarPageChanged(int monthIndex) async {
    int addingMonth = monthIndex - CalendarPageState.pseudoUnlimitedCenterIndex;
    if (state.addingMonth == addingMonth) {
      return;
    }
    debugPrint('onCalendarPageChanged addingMonth=$addingMonth');
    state.addingMonth = addingMonth;

    state.now = DateTime.now();
    await updateMonthCalendarState();
    await selectDay();
    await updateWeekCalendarState();
    await initSelectionWeekCalendar();
    await updateSelectionDayOfHome();
  }

  initSelectionWeekCalendar() async {
    // Data-Week Calendar
    state.selectionAllDay = false;
    state.selectionHour = DateTime(state.selectionDate.year,
        state.selectionDate.month, state.selectionDate.day, state.now.hour);

    // UI-Week Calendar
    var hoursPartTimeInterval = 24 / CalendarPageState.timeColNum;

    state.hourPartIndex = 0;
    for (int i=0; i < state.hours.length; i++) {
      var id = state.hours[i].id;
      if (id.year == state.selectionHour.year
          && id.month == state.selectionHour.month
          && id.day == state.selectionHour.day) {

        var nowHour = state.now.hour;
        var idHour = id.hour;

        if (nowHour >= idHour && nowHour < idHour + hoursPartTimeInterval) {
          state.hourPartIndex = i;
          break;
        }
      }
    }
  }

  updateEditingEvent(String eventId) async {
    var eventDisplay = state.editingEventList.where((event) {
      return event.eventId == eventId;
    }).firstOrNull;
    if (eventDisplay == null) {
      return;
    }

    var event = state.eventIdEventMap[eventDisplay.eventId];
    event ??= await CalendarRepository().getEvent(eventDisplay.calendarId,
          eventDisplay.eventId);
    if (event == null) {
      return;
    }

    var updateEvent = await createEventDisplay(event);
    eventDisplay.head = updateEvent.head;
    eventDisplay.title = updateEvent.title;
    eventDisplay.fixedTitle = DateFormat.yMd('ja').format(eventDisplay.event!
        .start!);
  }

  selectEventList(String eventId) async {
    for(int i=0; i<state.eventList.length; i++) {
      var event = state.eventList[i];
      if (eventId == event.eventId) {
        selectEventListPart(i);
        state.scrollEventListIndex = i;
        return;
      }
    }
  }

  updateCalendar({bool dataExclusion = false}) async {
    if (!dataExclusion) {
      state.now = DateTime.now();
    }
    await updateMonthCalendarState(dataExclusion: dataExclusion);
    await updateWeekCalendarState();
    await updateEventList();
  }

  updateMonthCalendarState({bool dataExclusion = false,
    int preLoadingAddingMonth = 0}) async {
    if (!state.preEventDataLoading) {
      state.weekdayList = createWeekdayList();
      state.dayLists = createDayLists(state.basisMonthDate,
          state.addingMonth + preLoadingAddingMonth);

      if (!dataExclusion) {
        await loadMonthCalendarData();
      }
    }
    state.preEventDataLoading = false;

    state.dayLists = addEventsForMonthCalendar(state.dayLists,
        state.dayEventsMap, state.calendarMap);
  }

  loadMonthCalendarData() async {
    var calendars = await getCalendars();
    state.calendarMap = convertCalendarMap(calendars);

    var startDate = state.dayLists.first.first.id;
    var endDate = state.dayLists.last.last.id;
    state.calendarEvents = await getEvents(calendars, startDate,
        endDate);
    state.eventIdEventMap = createEventIdEventMap(state.calendarEvents);
    state.eventIdStartDateMap =
        createEventIdStartDateMap(state.calendarEvents);
    state.dayEventsMap = createDayEventsMap(state.calendarEvents);

    state.allDayEventsMap = createAllDayEventsMap(state.calendarEvents);
    state.hourEventsMap = createHourEventsMap(state.calendarEvents);
  }

  setDayEventList(DateTime date, Map<DateTime, List<Event>> eventsMap) async {
    state.eventListTitle = DateFormat.MMMEd('ja') // 6月12日(月)
        .format(date).toString();
    var eventList = eventsMap[date] ?? [];
    await setEventList(eventList);
  }

  List<WeekdayDisplay> createWeekdayList() {
    const titleList = ['日', '月', '火', '水', '木', '金', '土'];
    var titleColors = holidayTitleColors();
    List<WeekdayDisplay> weekdayDisplayList = [];
    for(int i=0; i<titleList.length; i++) {
      var title = titleList[i];
      var titleColor = titleColors[i];
      weekdayDisplayList.add(WeekdayDisplay(title: title,
          titleColor: titleColor));
    }
    return weekdayDisplayList;
  }

  List<Color> holidayTitleColors() {
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
    return titleColors;
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

    var titleColors = holidayTitleColors();

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
              titleColor: titleColors[j % columnNum], eventList: [],
              today: currentDay == now)
        }
      ]);
    }

    return list;
  }



  Map<String, Event> createEventIdEventMap(List<Event> events) {
    Map<String, Event> eventsMap = {};
    for (int i = 0; i < events.length; i++) {
      var event = events[i];
      if (eventsMap[event.eventId!] == null) {
        eventsMap[event.eventId!] = event;
      }
    }
    return eventsMap;
  }

  Map<String, DateTime> createEventIdStartDateMap(List<Event> events) {
    Map<String, DateTime> eventsMap = {};
    for (int i = 0; i < events.length; i++) {
      var event = events[i];
      if (eventsMap[event.eventId!] == null) {
        eventsMap[event.eventId!] = event.start!;
      }
    }
    return eventsMap;
  }

  Map<DateTime, List<Event>> createDayEventsMap(List<Event> events) {
    Map<DateTime, List<Event>> eventsMap = {};
    for (int i = 0; i < events.length; i++) {
      var event = events[i];
      var allDays = CalendarUtils().getAllDays(event.start!, event.end!);
      allDays.fold(eventsMap, (events, day) {
        events[day] = events[day] ?? [];
        events[day]!.add(event);
        return events;
      });
    }
    for (int i = 0; i < eventsMap.keys.length; i++) {
      var key = List.from(eventsMap.keys)[i];
      eventsMap[key]!.sort((event1, event2) {
        var start1 = event1.start!;
        var start2 = event2.start!;
        if (start1 != start2) {
          return start1.compareTo(start2);
        } else {
          return event1.eventId!.compareTo(event2.eventId!);
        }
      });
    }
    // debugPrint('日付ごとのイベント数 ${eventsMap.length}');

    return eventsMap;
  }

  List<List<DayDisplay>> addEventsForMonthCalendar(
      List<List<DayDisplay>> dayLists, Map<DateTime, List<Event>> eventsMap,
      Map<String, Calendar> calendarMap) {
    var colorConfig = ref.read(designConfigNotifierProvider).colorConfig!;

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
              titleColor: calendar.isDefault!
                  ? colorConfig.normalTextColor
                  : colorConfig.disabledTextColor));
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

    state.selectionDate = state.dayLists[1][state.dayPartIndex].id;
    await setDayEventList(state.selectionDate, state.dayEventsMap);
  }

  // Week Calendar

  onTapDownCalendarHour(int index) async {
    await selectHour(index: index);
    await updateState();
  }

  updateWeekCalendarState() async {
    state.dayAndWeekdayList = createDayAndWeekdayList(state.selectionDate);
    state.hours = createHourList(state.selectionDate);
    state.hours = addEvents(state.hours, state.allDayEventsMap,
        state.hourEventsMap, state.calendarMap);
  }

  setHourEventList(bool allDay, DateTime date,
      Map<DateTime, List<Event>> allDayEventsMap,
      Map<DateTime, List<Event>> hourEventsMap) async {
    var timeInterval = 24 ~/ CalendarPageState.timeColNum;
    var dateUntil = date.add(Duration(hours:timeInterval));
    var hourStr = '${date.hour}:00〜${dateUntil.hour}:00'; // 0:00〜5:00
    state.eventListTitle = '${DateFormat.MMMEd('ja') // 6月12日(月)
        .format(date)} ${allDay ? '終日' : hourStr}';
    var eventList = (allDay ? allDayEventsMap[date] : hourEventsMap[date])
        ?? [];
    await setEventList(eventList);
  }

  List<DayAndWeekdayDisplay> createDayAndWeekdayList(DateTime selectionDay) {
    const weekdayRowNum = CalendarPageState.hoursPartRowNum;

    DateTime day = DateTime(selectionDay.year, selectionDay.month,
        selectionDay.day - selectionDay.weekday % weekdayRowNum, 0);

    var titleColors = holidayTitleColors();

    List<DayAndWeekdayDisplay> dayAndWeekdayList = [];
    for (int rowIndex = 0; rowIndex < weekdayRowNum; rowIndex++) {
      DateTime now = DateTime(state.now.year, state.now.month,
          state.now.day);
      DateTime currentDay = DateTime(
          day.year, day.month, day.day + rowIndex);
      dayAndWeekdayList.add(DayAndWeekdayDisplay(
          dayAndWeekTitle: DateFormat('M/d\n(E)', 'ja').format(currentDay),
          dayAndWeekTitleColor: titleColors[rowIndex % weekdayRowNum],
          today: currentDay == now
      ));
    }

    return dayAndWeekdayList;
  }

  List<HourDisplay> createHourList(DateTime selectionDay) {
    const timeColNum = CalendarPageState.timeColNum;

    var timeInterval = 24 ~/ timeColNum;
    const weekdayRowNum = CalendarPageState.hoursPartRowNum;

    DateTime week = DateTime(selectionDay.year, selectionDay.month,
        selectionDay.day - selectionDay.weekday % weekdayRowNum, 0);

    var titleColors = holidayTitleColors();
    List<HourDisplay> wholeTimeList = [];
    for (int rowIndex = 0; rowIndex < weekdayRowNum; rowIndex++) {
      for (int colIndex = 0; colIndex < timeColNum + 1; colIndex++) {
        bool allDay = colIndex == timeColNum;
        DateTime id = DateTime(week.year, week.month, week.day
            + rowIndex, allDay ? 0 : week.hour + colIndex * timeInterval);
        DateTime now = DateTime(state.now.year, state.now.month,
            state.now.day);
        DateTime currentDay = DateTime(id.year, id.month, id.day);

        // AM 0
        // var title = DateFormat('a h').format(id);
        var title = '${id.hour}時';
        if (colIndex == timeColNum) {
          title = '終日';
        }

        var titleColor = titleColors[rowIndex % weekdayRowNum];

        wholeTimeList.add(
            HourDisplay(
                allDay: allDay,
                id: id,
                title: title,
                titleColor: titleColor,
                eventList: [],
                today: now == currentDay
            )
        );
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
      var allDays = CalendarUtils().getAllDays(event.start!, event.end!);
      allDays.fold(eventsMap, (events, day) {
        events[day] = events[day] ?? [];
        events[day]!.add(event);
        return events;
      });
    }
    //debugPrint('終日ごとのイベント数 ${eventsMap.length}');
    return eventsMap;
  }

  Map<DateTime, List<Event>> createHourEventsMap(List<Event> events) {
    var timeInterval = 24 ~/ CalendarPageState.timeColNum;

    Map<DateTime, List<Event>> eventsMap = {};
    if (events.isNotEmpty) {
      for (int i = 0; i < events.length; i++) {
        var event = events[i];
        if (event.allDay!) {
          continue;
        }
        // if (event.title=='てすと') {
        //   debugPrint('!');
        // }
        var allHours = CalendarUtils().getAllHours(event.start!, event.end!,
            timeInterval);
        allHours.fold(eventsMap, (events, day) {
          // 数時間ごとにまとめる
          var hour = day.hour;
          hour = hour - hour % timeInterval;
          var editHour = DateTime(day.year, day.month, day.day, hour);
          events[editHour] = events[editHour] ?? [];
          events[editHour]!.add(event);
          return events;
        });
      }
      // debugPrint('時間ごとのイベント数 ${eventsMap.length}');
    }
    return eventsMap;
  }

  List<HourDisplay> addEvents(List<HourDisplay> hours,
      Map<DateTime, List<Event>> allDayEventsMap,
      Map<DateTime, List<Event>> hourEventsMap,
      Map<String, Calendar> calendarMap) {
    var colorConfig = ref.read(designConfigNotifierProvider).colorConfig!;

    for (var hourInfo in hours) {
      hourInfo.eventList.clear();

      var events = (hourInfo.allDay ? allDayEventsMap[hourInfo.id]
          : hourEventsMap[hourInfo.id]) ?? [];

      //var dhmStr = DateFormat('dd HH').format(hourInfo.id);
      // hourInfo.eventList.add(HourEventDisplay(
      //     title: dhmStr, titleColor: normalTextColor));

      for (var event in events) {
        var calendar = calendarMap[event.calendarId]!;
        hourInfo.eventList.add(HourEventDisplay(
            title: event.title!,
            titleColor: calendar.isDefault!
                ? colorConfig.normalTextColor
                : colorConfig.disabledTextColor));
      }
    }

    return hours;
  }

  selectHour({int? index}) async {
    state.now = DateTime.now();

    if (index != null) {
      state.cellActive = true;
      state.hourPartIndex = index;
      state.eventListIndex = null;
    }

    state.selectionAllDay = state.hours[state.hourPartIndex].allDay;
    state.selectionHour = state.hours[state.hourPartIndex].id;
    await setHourEventList(state.selectionAllDay, state.selectionHour,
        state.allDayEventsMap, state.hourEventsMap);

    selectDayPartIndex(state.selectionHour);
  }

  // Event List

  Future<bool> deleteEvent(EventDisplay event) async {
    var recurrenceRule = state.eventIdEventMap[event.eventId]!
        .recurrenceRule;
    if (event.sameCell || recurrenceRule != null) {
      return await CalendarRepository().deleteEvent(event.calendarId,
          event.eventId);
    } else {
      return await deleteAfterEvent(event.eventId);
    }
  }

  Future<bool> deleteAfterEvent(String eventId) async {
    Event event = state.eventIdEventMap[eventId]!;

    DateTime? deletionDate;
    if (state.calendarSwitchingIndex == 0) {
      deletionDate = state.selectionDate;
    } else if (state.calendarSwitchingIndex == 1) {
      deletionDate = state.selectionHour;
    } else {
      return false;
    }
    deletionDate = deletionDate.add(const Duration(minutes: -1));

    var deletionTZDate = calendarRepo.convertTZDateTime(deletionDate);

    if (event.end!.isAfter(deletionTZDate)) {
      event.end = deletionTZDate;
    }

    return await calendarRepo.createOrUpdateEvent(event) != null;
  }

  fixedEvent(int index) async {
    var ed = state.eventList[index];
    var event = state.eventIdEventMap[ed.eventId];
    ed.editing = true;
    var startDate = state.eventIdStartDateMap[ed.eventId];
    if (startDate != null) {
      ed.fixedDateTime = startDate;
      ed.fixedTitle = DateFormat.yMd('ja').format(startDate);
      ed.sameCell = await getSameCell(ed.fixedDateTime!, ed.event!.allDay!);
    }
    state.editingEventList.add(
        EventDisplay(eventId: ed.eventId, calendarId: ed.calendarId,
            editing: true, sameCell: false, readOnly: ed.readOnly,
            head: ed.head, lineColor: ed.lineColor, title: ed.title,
            fontColor: ed.fontColor, fixedDateTime: ed.fixedDateTime,
            fixedTitle: ed.fixedTitle, hourMoving: ed.hourMoving,
            hourChoiceMode: false, movingHourChoices: [], event: event)
    );
  }

  getSameCell(DateTime startDate, bool allDay) async {
    var sameCell = true;
    if (state.calendarSwitchingIndex == 0) {
      var eventDay = DateTime(startDate.year, startDate.month, startDate.day);
      sameCell = eventDay == state.selectionDate;
    } else if (state.calendarSwitchingIndex == 1) {
      var eventHour = DateTime(startDate.year, startDate.month, startDate.day,
          startDate.hour);
      var sameHour = eventHour == state.selectionHour
          || eventHour == state.selectionHour.add(const Duration(hours: 1))
          || eventHour == state.selectionHour.add(const Duration(hours: 2))
          || eventHour == state.selectionHour.add(const Duration(hours: 3));
      sameCell = sameHour && allDay == state.selectionAllDay;
    }
    return sameCell;
  }

  Future<bool> copyIndexEvent(int index) async {
    Event event = state.eventList[index].event!;

    var editingEvent = copyEvent(event);
    return await calendarRepo.createOrUpdateEvent(editingEvent) != null;
  }

  Future<String?> moveIndexEvent(int index, {int hour = 0}) async {
    var timeInterval = 24 ~/ CalendarPageState.timeColNum;
    Event event = state.eventList[index].event!;

    var endPeriod = event.end!.difference(event.start!);
    Duration? repeatEndPeriod;
    if (event.recurrenceRule?.endDate != null) {
      repeatEndPeriod = event.recurrenceRule!.endDate!
          .difference(event.start!);
    }

    DateTime selectionDate;
    if (state.calendarSwitchingIndex == 0) {
      selectionDate = state.selectionDate;

      int timeInterval = 24;
      var addingHours = event.start!.difference(selectionDate).inHours
          % timeInterval;
      selectionDate = selectionDate.add(Duration(hours: addingHours));
    } else if (state.calendarSwitchingIndex == 1) {
      selectionDate = state.selectionHour;
      event.allDay = state.selectionAllDay;

      selectionDate = selectionDate.add(Duration(hours: hour
          % timeInterval));
    } else {
      return null;
    }

    event.start = calendarRepo.convertTZDateTime(selectionDate);
    event.end = calendarRepo.convertTZDateTime(
        selectionDate.add(endPeriod));
    if (repeatEndPeriod != null) {
      event.recurrenceRule!.endDate = calendarRepo.convertTZDateTime(
          selectionDate.add(repeatEndPeriod));
    }

    return await calendarRepo.createOrUpdateEvent(event);
  }

  Event copyEvent(Event event) {
    return Event(
        event.calendarId,
        eventId: null,
        title: event.title,
        start: event.start,
        end: event.end,
        description: event.description,
        attendees: event.attendees,
        recurrenceRule: event.recurrenceRule,
        reminders: event.reminders,
        availability: event.availability,
        location: event.location,
        url: event.url,
        allDay: event.allDay,
        status: event.status
    );
  }

  editingCancel(int index) async {
    var event = state.eventList[index];
    int removeIdx = -1;
    for (int i=0; i < state.editingEventList.length; i++) {
      if (state.editingEventList[i].eventId == event.eventId) {
        removeIdx = i;
        break;
      }
    }

    state.editingEventList.removeAt(removeIdx);
  }

  updateEventList() async {
    if (state.calendarSwitchingIndex == 0) {
      await setDayEventList(state.selectionDate, state.dayEventsMap);
    } else if (state.calendarSwitchingIndex == 1) {
      await setHourEventList(state.selectionAllDay, state.selectionHour,
          state.allDayEventsMap, state.hourEventsMap);
    }
  }

  setEventList(List<Event> eventList) async {
    var colorConfig = ref.read(designConfigNotifierProvider).colorConfig!;
    var hoursPartTimeInterval = 24 / CalendarPageState.timeColNum;

    List<EventDisplay> creatingEventList = [];
    for (int i = 0; i < eventList.length; i++) {
      creatingEventList.add(await createEventDisplay(eventList[i]));
    }

    var otherEventList = state.editingEventList
      .where((event) => creatingEventList
        .where((ce) => ce.eventId == event.eventId
        ).firstOrNull == null);

    var calendars = await calendarRepo.getCalendars();
    var displayEventList = [...otherEventList, ...creatingEventList].map((event) {
      var editingEvent = state.editingEventList
          .where((e)=>e.eventId == event.eventId).firstOrNull;

      event.fixedDateTime = editingEvent?.fixedDateTime;
      event.fixedTitle = editingEvent?.fixedTitle;

      var calendar = calendars.firstWhere((calendar) =>
      calendar.id == event.calendarId);

      event.lineColor = Color(calendar.color!);
      event.fontColor = calendar.isDefault!
          ? colorConfig.normalTextColor
          : colorConfig.disabledTextColor;

      if (state.calendarSwitchingIndex == 1) {
        List<int> choices = [];
        var exclusionHour = event.event!.start!.hour;
        var hour = state.selectionHour.hour;
        for (int i = 0; i < hoursPartTimeInterval; i++) {
          if (!event.sameCell || hour + i != exclusionHour) {
            choices.add(hour + i);
          }
        }

        event.movingHourChoices = choices;
      }
      event.hourMoving = state.calendarSwitchingIndex == 1
          && !state.selectionAllDay;
      event.hourChoiceMode = state.calendarSwitchingIndex == 1
          && !state.selectionAllDay && (editingEvent?.hourChoiceMode ?? false);
      return event;
    }).toList();
    displayEventList.sort((event1, event2) {
      var editing1 = event1.editing ? 1 : 0;
      var editing2 = event2.editing ? 1 : 0;
      var start1 = event1.fixedDateTime ?? event1.event!.start!;
      var start2 = event2.fixedDateTime ?? event2.event!.start!;
      if (editing1 != editing2) {
        return editing2 - editing1;
      } else if (start1 != start2) {
        return start1.compareTo(start2);
      } else {
        return event1.event!.eventId!.compareTo(event2.event!.eventId!);
      }
    });
    state.eventListCellKeyList = List.generate(
        displayEventList.length, (i)=>GlobalKey());
    state.eventList = displayEventList;
  }

  Future<EventDisplay> createEventDisplay(Event event) async {
    var colorConfig = ref.read(designConfigNotifierProvider).colorConfig!;
    var calendars = await calendarRepo.getCalendars();
    var calendar = calendars.firstWhere((calendar) =>
    calendar.id == event.calendarId);
    var eventId = event.eventId!;
    var editing = state.editingEventList
        .where((editingEvent) => editingEvent.eventId == event.eventId)
        .firstOrNull != null;
    var head = '${DateFormat.jm('ja').format(event.start!)}\n'
        '${DateFormat.jm('ja').format(event.end!)}';
    var rule = event.recurrenceRule;
    if (rule != null) {
      var repeat = RepeatingPattern.getType(
          rule.recurrenceFrequency, rule.interval);
      head = repeat != RepeatingPattern.other ? repeat.name : '繰返し';
      if (!event.allDay!) {
        head += '\n${DateFormat.jm('ja').format(event.start!)}';
      }
    } else if (event.end!.difference(event.start!).inHours > 24) {
      head = '連日';
    } else if (event.allDay!) {
      head = '終日';
    }
    var lineColor = Color(calendar.color!);
    var title = event.title!;
    var fontColor = calendar.isDefault!
        ? colorConfig.normalTextColor
        : colorConfig.disabledTextColor;

    var editingEvent = state.editingEventList
        .where((e)=>e.eventId == event.eventId).firstOrNull;
    var startDate = editingEvent?.fixedDateTime
        ?? state.eventIdStartDateMap[eventId]!;
    var sameCell = await getSameCell(startDate, event.allDay!);

    return EventDisplay(eventId: eventId,
        calendarId: calendar.id!, editing: editing,
        sameCell: sameCell, readOnly: calendar.isReadOnly!,
        head: head, lineColor: lineColor, title: title, fontColor: fontColor,
        fixedDateTime: null, fixedTitle: null, hourMoving: false,
        hourChoiceMode: false, movingHourChoices: [], event: event
    );
  }

  selectEventListPart(int index) async {
    if (!state.cellActive && state.eventListIndex == index) {
      return;
    }

    state.cellActive = false;
    state.eventListIndex = index;
  }

  setHourChoiceMode(bool mode) async {
    var eventId = state.eventList[state.eventListIndex!].eventId;
    var event = state.editingEventList.where((event)=>event.eventId == eventId)
        .firstOrNull;
    event?.hourChoiceMode = mode;
  }

  Future<bool> isHourMove() async {
    return state.calendarSwitchingIndex == 1 && !state.selectionAllDay;
  }

  // Common

  Future<Event?> getSelectionEvent() async {
    if (state.eventListIndex == null || state.eventList.isEmpty) {
      return null;
    }
    // var event = state.eventList[state.eventListIndex!];
    // return CalendarRepository().getEvent(event.calendarId, event.eventId);
    return state.eventList[state.eventListIndex!].event;
  }

  Future<List<Calendar>> getCalendars() async {
    List<Calendar> calendars = [];
    await calendarRepo.hasPermissions();
    calendars = await calendarRepo.getCalendars();
    // debugPrint('カレンダー数 ${calendars.length}');

    // debugPrint('カレンダー一覧');
    // for (var cal in calendars) {
    //   debugPrint('name:${cal.name} isReadOnly:${cal.isReadOnly}'
    //       ' isDefault:${cal.isDefault} accountType:${cal.accountType}'
    //       ' accountName:${cal.accountName}');
    // }

    return calendars.where((cal) {
      return cal.isDefault! || true;
    }).toList();
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
        events.addAll(await calendarRepo.getEvents(calendar.id!,
            startDate, endDate));
      }
    }
    return events;
  }

  updateSelectionDayOfHome() async {
    final homeNotifier = ref.read(homePageNotifierProvider.notifier);
    if (state.dayLists.length == 3) {
      await homeNotifier.setAppBarTitle(state.dayLists[1][6].id, true);
    }
  }

  updateState() async {
    state = CalendarPageState.copy(state);
    debugPrint('updateState(calendar)');
  }
}

final calendarPageNotifierProvider = StateNotifierProvider
    .autoDispose<CalendarPageNotifier, CalendarPageState>((ref) {
  return CalendarPageNotifier(ref, CalendarPageState());
});