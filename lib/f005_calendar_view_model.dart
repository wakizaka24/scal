import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import 'f002_home_view_model.dart';
import 'f008_calendar_repository.dart';
import 'f015_calendar_date_utils.dart';

class CalendarPageState {
  // Control-Common
  // 擬似無制限中央インデックス
  static const int pseudoUnlimitedCenterIndex = 36001;

  // Control-Month Calendar/Week Calendar
  PageController calendarSwitchingController = PageController(
    initialPage: 0);

  // Control-Month Calendar
  bool monthCalendarReload = false;
  PageController monthCalendarController = PageController(
      initialPage: pseudoUnlimitedCenterIndex);

  // Data-Month Calendar/Week Calendar
  late DateTime now;
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
  int preAddingMonth = 0;
  int indexAddingMonth = 0;
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
  List<EventDisplay> editingEventList = [];

  static CalendarPageState copy(CalendarPageState state) {
    var nState = CalendarPageState();

    // Control-Month Calendar/Week Calendar
    nState.calendarSwitchingController = state.calendarSwitchingController;

    // Control-Month Calendar
    nState.monthCalendarReload = state.monthCalendarReload;
    nState.monthCalendarController = state.monthCalendarController;

    // Data-Month Calendar/Week Calendar
    nState.now = state.now;
    nState.calendarMap = state.calendarMap;
    nState.calendarEvents = state.calendarEvents;
    nState.eventIdEventMap = state.eventIdEventMap;
    nState.eventIdStartDateMap = state.eventIdStartDateMap;
    nState.cellActive = state.cellActive;
    nState.calendarSwitchingIndex = state.calendarSwitchingIndex;

    // Data-Month Calendar
    nState.basisMonthDate = state.basisMonthDate;
    nState.addingMonth = state.addingMonth;
    nState.preAddingMonth = state.preAddingMonth;
    nState.indexAddingMonth = state.indexAddingMonth;
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
    nState.editingEventList = state.editingEventList;

    return nState;
  }
}

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

  EventDisplay({
    required this.eventId,
    required this.calendarId,
    required this.editing,
    required this.sameCell,
    required this.readOnly,
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

class CalendarPageNotifier extends StateNotifier<CalendarPageState> {
  final Ref ref;
  CalendarRepository calendarRepo = CalendarRepository();

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
    state.selectionDate = DateTime(state.now.year, state.now.month,
        state.now.day);

    // UI-Month Calendar/Week Calendar
    state.cellActive = true;
    DateTime now = state.now;

    // UI-Month Calendar
    selectDayPartIndex(now);

    await updateSelectionDayOfHome();
    await setDayEventList(state.selectionDate, state.dayEventsMap);
    await updateWeekCalendarData();
    await initSelectionWeekCalendar();

    afterInit();
  }

  // Month Calendar/Week Calendar

  selectDayPartIndex(DateTime date) {
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
    state.indexAddingMonth = state.preAddingMonth;
    if (index == 0) {
      await selectDay();
      await updateWeekCalendarData();
      await initSelectionWeekCalendar();
      await updateSelectionDayOfHome();
    } else {
      await selectHour();
      await updateSelectionDayOfHome();
    }
    await updateState();
  }

  String getCalendarSwitchingButtonTitle() {
    return state.calendarSwitchingIndex == 0 ?
        "Weekly" : state.calendarSwitchingIndex == 1
        ? "Monthly" : "";
  }

  // Month Calendar

  onTapDownCalendarDay(int index) async {
    // 選択中のセル
    if (state.dayPartIndex == index) {
    }

    await selectDay(index: index);
    await updateWeekCalendarData();
    await initSelectionWeekCalendar();
    await updateSelectionDayOfHome();
    await updateState();
  }

  onCalendarPageChanged(int monthIndex) async {
    int addingMonth = monthIndex - CalendarPageState.pseudoUnlimitedCenterIndex
        + state.indexAddingMonth;
    state.preAddingMonth = addingMonth;
    if (state.addingMonth == addingMonth) {
      return;
    }
    debugPrint('onCalendarPageChanged addingMonth=$addingMonth');
    state.addingMonth = addingMonth;

    await updateCalendar();
    await selectDay();
    await initSelectionWeekCalendar();
    await updateSelectionDayOfHome();
    await updateState();
  }

  initSelectionWeekCalendar() async {
    // Data-Week Calendar
    state.selectionAllDay = false;
    state.selectionHour = DateTime(state.selectionDate.year,
        state.selectionDate.month, state.selectionDate.day, state.now.hour);

    // UI-Week Calendar
    var hoursPartCowNum = state.hours.length ~/ CalendarPageState
        .hoursPartRowNum;
    var hoursPartTimeInterval = 24 / (hoursPartCowNum - 1);

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

  updateCalendar() async {
    state.now = DateTime.now();
    await updateMonthCalendarData();
    state.monthCalendarReload = true;

    await updateWeekCalendarData();
  }

  updateMonthCalendarData() async {
    state.dayLists = createDayLists(state.basisMonthDate, state.addingMonth);
    var calendars  = await getCalendars();
    state.calendarMap = convertCalendarMap(calendars);
    var startDate = state.dayLists.first.first.id;
    var endDate = state.dayLists.last.last.id;
    state.calendarEvents = await getEvents(calendars, startDate,
        endDate);
    state.eventIdEventMap = createEventIdEventMap(state.calendarEvents);
    state.eventIdStartDateMap = createEventIdStartDateMap(state.calendarEvents);
    state.dayEventsMap = createDayEventsMap(state.calendarEvents);
    state.dayLists = addEventsForMonthCalendar(state.dayLists,
        state.dayEventsMap, state.calendarMap);
  }

  setDayEventList(DateTime date, Map<DateTime, List<Event>> eventsMap) async {
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
      var allDays = CalendarDateUtils().getAllDays(event.start!, event.end!);
      allDays.fold(eventsMap, (events, day) {
        events[day] = events[day] ?? [];
        events[day]!.add(event);
        return events;
      });
    }
    // debugPrint('日付ごとのイベント数 ${eventsMap.length}');

    return eventsMap;
  }

  List<List<DayDisplay>> addEventsForMonthCalendar(
      List<List<DayDisplay>> dayLists, Map<DateTime, List<Event>> eventsMap,
      Map<String, Calendar> calendarMap) {
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

    state.selectionDate = state.dayLists[1][state.dayPartIndex].id;
    await setDayEventList(state.selectionDate, state.dayEventsMap);
  }

  // Week Calendar

  onTapDownCalendarHour(int index) async {
    // 選択中のセル
    if (state.hourPartIndex == index) {
    }

    await selectHour(index: index);
    await updateSelectionDayOfHome();
    await updateState();
  }

  updateWeekCalendarData() async {
    state.dayAndWeekdayList = createDayAndWeekdayList(state.selectionDate);
    state.hours = createHourList(state.selectionDate);
    state.allDayEventsMap = createAllDayEventsMap(state.calendarEvents);
    state.hourEventsMap = createHourEventsMap(state.calendarEvents);
    state.hours = addEvents(state.hours, state.allDayEventsMap,
        state.hourEventsMap, state.calendarMap);
  }

  setHourEventList(bool allDay, DateTime date,
      Map<DateTime, List<Event>> allDayEventsMap,
      Map<DateTime, List<Event>> hourEventsMap) async {
    var timeInterval = 24 ~/ CalendarPageState.timeColNum;
    var dateUntil = date.add(Duration(hours:timeInterval - 1));
    var hourStr = '${date.hour}h〜${dateUntil.hour}h'; // 0h〜4h
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

    List<DayAndWeekdayDisplay> dayAndWeekdayList = [];
    for (int rowIndex = 0; rowIndex < weekdayRowNum; rowIndex++) {
      DateTime now = DateTime(state.now.year, state.now.month,
          state.now.day);
      DateTime currentDay = DateTime(
          day.year, day.month, day.day + rowIndex);
      dayAndWeekdayList.add(DayAndWeekdayDisplay(
          dayAndWeekTitle: DateFormat('M/d\n(E)', 'ja').format(currentDay),
          dayAndWeekTitleColor: rowIndex % weekdayRowNum == 0 ? Colors.pink
              : rowIndex % weekdayRowNum == weekdayRowNum - 1
              ? Colors.green : Colors.black,
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

    List<HourDisplay> wholeTimeList = [];
    for (int rowIndex = 0; rowIndex < weekdayRowNum; rowIndex++) {
      for (int colIndex = 0; colIndex < timeColNum + 1; colIndex++) {
        bool allDay = colIndex == timeColNum;
        DateTime id = DateTime(week.year, week.month, week.day
            + rowIndex, allDay ? 0 : week.hour + colIndex * timeInterval);
        DateTime now = DateTime(state.now.year, state.now.month,
            state.now.day);
        DateTime currentDay = DateTime(id.year, id.month, id.day);

        var title = '${id.hour}h';
        if (colIndex == timeColNum) {
          title = '終日';
        }

        var titleColor = rowIndex % weekdayRowNum == 0 ? Colors.pink
            : rowIndex % weekdayRowNum == weekdayRowNum - 1
            ? Colors.green : Colors.black;

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
      var allDays = CalendarDateUtils().getAllDays(event.start!, event.end!);
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
        var allHours = CalendarDateUtils().getAllHours(event.start!, event.end!,
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

    for (var hourInfo in hours) {
      hourInfo.eventList.clear();

      var events = (hourInfo.allDay ? allDayEventsMap[hourInfo.id]
          : hourEventsMap[hourInfo.id]) ?? [];

      //var dhmStr = DateFormat('dd HH').format(hourInfo.id);
      // hourInfo.eventList.add(HourEventDisplay(
      //     title: dhmStr, titleColor: Colors.black));

      for (var event in events) {
        var calendar = calendarMap[event.calendarId]!;
        hourInfo.eventList.add(HourEventDisplay(
            title: event.title!,
            titleColor: calendar.isDefault! ? Colors.black
                : const Color(0xffaaaaaa)));
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
    if (event.sameCell) {
      return await CalendarRepository().deleteEvent(event.calendarId,
          event.eventId);
    } else {
      return await deleteAfterEvent(event.eventId);
    }
  }

  Future<bool> deleteAfterEvent(String eventId) async {
    var timeInterval = 24 ~/ CalendarPageState.timeColNum;
    Event event = state.eventIdEventMap[eventId]!;

    var deletionDate = state.selectionHour;
    if (state.calendarSwitchingIndex == 0) {
      deletionDate = deletionDate.add(const Duration(days: -1));
    } else if (state.calendarSwitchingIndex == 1) {
      deletionDate = deletionDate.add(Duration(hours: -timeInterval));
    }

    var deletionTZDate = calendarRepo.convertTZDateTime(deletionDate);

    if (event.end!.isAfter(deletionTZDate)) {
      event.end = deletionTZDate;
    }

    var repetitionEndDate = event.recurrenceRule?.endDate;
    if (repetitionEndDate != null) {
      if (repetitionEndDate.isAfter(deletionDate)) {
        event.recurrenceRule?.endDate
          = calendarRepo.convertTZDateTime(deletionDate);
      }
    }

    return await calendarRepo.createOrUpdateEvent(event);
  }

  onPressedEventListFixedButton(int index) async {
    var event = state.eventList[index];
    event.editing = true;
    event.sameCell = true;
    state.editingEventList.add(
        EventDisplay(eventId: event.eventId, calendarId: event.calendarId,
            editing: true, sameCell: false, readOnly: event.readOnly,
            head: event.head, lineColor: event.lineColor, title: event.title,
            fontColor: event.fontColor)
    );

    await updateState();
  }

  Future<bool> copyIndexEvent(int index) async {
    var eventId = state.eventList[index].eventId;
    Event event = state.eventIdEventMap[eventId]!;

    var editingEvent = copyEvent(event);
    return await calendarRepo.createOrUpdateEvent(editingEvent);
  }

  Future<bool> moveIndexEvent(int index) async {
    var eventId = state.eventList[index].eventId;
    Event event = state.eventIdEventMap[eventId]!;

    var endPeriod = event.end!.difference(event.start!);
    Duration? repeatEndPeriod;
    if (event.recurrenceRule?.endDate != null) {
      repeatEndPeriod = event.recurrenceRule!.endDate!
          .difference(event.start!);
    }

    DateTime selectionDate;
    if (state.calendarSwitchingIndex == 0) {
      selectionDate = state.selectionDate;
    } else if (state.calendarSwitchingIndex == 1) {
      selectionDate = state.selectionHour;
      event.allDay = state.selectionAllDay;
    } else {
      return false;
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

  onPressedEventListCancelButton(int index) async {
    await editingCancel(index);

    await updateEventList();
    await updateState();
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
    if (state.eventListIndex != null
        && state.eventListIndex! >= eventList.length) {
      if (eventList.isNotEmpty) {
        state.eventListIndex = eventList.length - 1;
      } else {
        state.eventListIndex = 0;
      }
    }

    List<EventDisplay> creatingEventList = [];
    for (int i = 0; i < eventList.length; i++) {
      var event = eventList[i];
      var calendars = await calendarRepo.getCalendars();
      var calendar = calendars.firstWhere((calendar) =>
      calendar.id == event.calendarId);
      var eventId = event.eventId!;
      var editing = state.editingEventList
          .where((editingEvent) => editingEvent.eventId == event.eventId)
          .firstOrNull != null;
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

      var sameCell = true;
      var startDate = state.eventIdStartDateMap[event.eventId!]!;
      if (state.calendarSwitchingIndex == 0) {
        var eventDay = DateTime(startDate.year, startDate.month, startDate.day);
        sameCell = eventDay == state.selectionDate;
      } else if (state.calendarSwitchingIndex == 1) {
        var eventHour = DateTime(startDate.year, startDate.month, startDate.day,
            startDate.hour);
        sameCell = eventHour == state.selectionHour
          && event.allDay == state.selectionAllDay;
      }

      creatingEventList.add(EventDisplay(eventId: eventId,
          calendarId: calendar.id!, editing: editing,
          sameCell: sameCell, readOnly: calendar.isReadOnly!,
          head: head, lineColor: lineColor, title: title,
          fontColor: fontColor
      ));
    }

    var otherEventList = state.editingEventList
      .where((event) => creatingEventList
        .where((ce) => ce.eventId == event.eventId
    ).firstOrNull == null);

    state.eventList = [...otherEventList, ...creatingEventList];
  }

  selectEventListPart(int index) async {
    state.cellActive = false;
    state.eventListIndex = index;
    await updateState();
  }

  // Common

  onPressedAddingButton() async {
    // if (state.cellActive) {
    // } else if (state.eventList.isEmpty) {
    // } else {
    //   var event = state.eventList[state.eventListIndex!];
    // }
  }

  Future<List<Calendar>> getCalendars() async {
    List<Calendar> calendars = [];
    if (await calendarRepo.hasPermissions()) {
      calendars = await calendarRepo.getCalendars();
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
        events.addAll(await calendarRepo.getEvents(calendar.id!,
            startDate, endDate));
      }
    }
    return events;
  }

  updateSelectionDayOfHome() async {
    final homeNotifier = ref.read(homePageNotifierProvider.notifier);
    homeNotifier.setAppBarTitle(state.selectionDate, true);
  }

  updateState() async {
    state = CalendarPageState.copy(state);
    debugPrint('updateState!!');
  }
}

final calendarPageNotifierProvider = StateNotifierProvider.family
    .autoDispose<CalendarPageNotifier, CalendarPageState, int>((ref, index) {
  var list = List.filled(2, CalendarPageState());
  return CalendarPageNotifier(ref, list[index]);
});