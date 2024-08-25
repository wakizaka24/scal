import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import 'f008_calendar_repository.dart';
import 'f015_calendar_utils.dart';

enum RepeatingPattern {
  none('なし', true, null, null),
  daily('毎日', true, RecurrenceFrequency.Daily, 1),
  weekly('毎週', true, RecurrenceFrequency.Weekly, 1),
  biweekly('隔週', true, RecurrenceFrequency.Weekly, 2),
  monthly('毎月', true, RecurrenceFrequency.Monthly, 1),
  yearly('毎年', true, RecurrenceFrequency.Yearly, 1),
  other('その他', false, null, null);

  final String name;
  final bool defaultDisplay;
  final RecurrenceFrequency? frequency;
  final int? interval;

  const RepeatingPattern(
      this.name,
      this.defaultDisplay,
      this.frequency,
      this.interval
  );

  static List<RepeatingPattern> getDisplayList(bool all) {
    return values.where((type) {
      return type.defaultDisplay || all;
    }).toList();
  }

  static RepeatingPattern getType(RecurrenceFrequency? frequency,
      int? interval) {
    var list = values.where((type) {
      return type.defaultDisplay && type.frequency == frequency
        && type.interval == interval;
    }).toList();
    if (list.length == 1) {
      return list.first;
    } else {
      return RepeatingPattern.other;
    }
  }
}

enum HighlightItem {
  none,
  title,
  place,
  allDay,
  startDate,
  startTime,
  endDate,
  endTime,
  repeat,
  repeatEnd,
  repeatEndDate,
  memo,
  // 移動する
  // destinationCalendar
}

enum TextFieldItem {
  title,
  place,
  startDate,
  startTime,
  endDate,
  endTime,
  repeat,
  repeatingEndDate,
  memo,
  // 移動する
  // destinationCalendar
}

class EventDetailPageState {
  // Control
  GlobalKey? contentsKey;
  Map<TextFieldItem, TextEditingController>? textEditingControllers;

  // Data
  double? contentsHeight;

  Calendar? calendar;
  Event? event;
  bool? readOnly;
  String? title;
  String? place;
  bool? allDay;
  DateTime? startDate;
  DateTime? endDate;
  RepeatingPattern? repeatingPattern;
  bool? repeatingEndWithOther;
  bool? repeatingEnd;
  DateTime? repeatingEndDate;
  String? memo;
  bool? saveButtonEnabled;

  HighlightItem? highlightItem;

  static EventDetailPageState copy(EventDetailPageState state) {
    var nState = EventDetailPageState();
    nState.contentsKey = state.contentsKey;
    nState.textEditingControllers = state.textEditingControllers;

    nState.contentsHeight = state.contentsHeight;

    nState.calendar = state.calendar;
    nState.event = state.event;
    nState.readOnly = state.readOnly;
    nState.title = state.title;
    nState.place = state.place;
    nState.allDay = state.allDay;
    nState.startDate = state.startDate;
    nState.endDate = state.endDate;

    nState.repeatingPattern = state.repeatingPattern;
    nState.repeatingEndWithOther = state.repeatingEndWithOther;
    nState.repeatingEnd = state.repeatingEnd;
    nState.repeatingEndDate = state.repeatingEndDate;
    nState.memo = state.memo;
    nState.saveButtonEnabled = state.saveButtonEnabled;

    nState.highlightItem = state.highlightItem;

    return nState;
  }
}

class EventDetailPageNotifier extends StateNotifier<EventDetailPageState> {
  final Ref ref;
  CalendarRepository calendarRepo = CalendarRepository();

  EventDetailPageNotifier(this.ref, EventDetailPageState state)
      : super(state);

  initState(bool selectDateOrTime, {bool? selectDay,
    DateTime? selectionDateTime, Calendar? calendar, Event? event}) async {

    // Control
    state.contentsKey = GlobalKey();
    state.textEditingControllers = (() {
      var km = <TextFieldItem, TextEditingController>{};
      for (var item in TextFieldItem.values) {
        km[item] = TextEditingController();
        km[item]!.addListener((){
          switch (item) {
            case TextFieldItem.title:
              state.title = km[item]!.text;
              if (state.title!.isEmpty == state.saveButtonEnabled) {
                state.saveButtonEnabled = state.title!.isNotEmpty;
                updateState();
              }
              break;
            case TextFieldItem.place:
              state.place = km[item]!.text;
              break;
            case TextFieldItem.memo:
              state.memo = km[item]!.text;
              break;
            default:
              break;
          }
        });
      }
      return km;
    })();

    // Data
    state.contentsHeight = await getContentsHeight();

    state.calendar = calendar;
    state.event = event;
    state.readOnly = calendar != null && calendar.isReadOnly!;
    state.title = selectDateOrTime ? '' : event!.title;
    setTextFieldController(TextFieldItem.title);

    state.place = selectDateOrTime ? '' : event!.location;
    setTextFieldController(TextFieldItem.place);

    state.allDay = selectDateOrTime ? false : event!.allDay;

    if (selectDateOrTime) {
      var date = selectionDateTime!;
      if (selectDay!) {
        state.startDate = DateTime(date.year, date.month, date.day,
            DateTime.now().hour);
      } else {
        state.startDate = date;
      }
      state.endDate = state.startDate!.add(const Duration(hours: 1));
    } else {
      state.startDate = CalendarUtils().convertDateTime(event!.start)!;
      state.endDate = CalendarUtils().convertDateTime(event.end)!;
    }
    setTextFieldController(TextFieldItem.startDate);
    setTextFieldController(TextFieldItem.startTime);
    setTextFieldController(TextFieldItem.endDate);
    setTextFieldController(TextFieldItem.endTime);

    if (selectDateOrTime) {
      state.repeatingPattern = RepeatingPattern.none;
      state.repeatingEndWithOther = false;
      state.repeatingEnd = false;
      state.repeatingEndDate = null;
    } else {
      var rule = event!.recurrenceRule;
      state.repeatingPattern = RepeatingPattern.getType(
          rule?.recurrenceFrequency, rule?.interval);
      state.repeatingEndWithOther = state.repeatingPattern
          == RepeatingPattern.other;
      state.repeatingEnd = rule?.endDate != null;
      state.repeatingEndDate = rule?.endDate;
    }
    setTextFieldController(TextFieldItem.repeat);
    setTextFieldController(TextFieldItem.repeatingEndDate);

    state.memo = selectDateOrTime ? '' : event!.description;
    setTextFieldController(TextFieldItem.memo);

    // state.calendarId = 'TEST_ID_1';
    // setTextFieldController(TextFieldItem.destinationCalendar);

    state.saveButtonEnabled = state.title!.isNotEmpty && !state.readOnly!;

    state.highlightItem = HighlightItem.none;

    await setContentsHeight();
  }

  @override
  dispose() {
    for (var controller in state.textEditingControllers!.values) {
      controller.dispose();
    }
    super.dispose();
  }

  updateHighlightItem(HighlightItem item) async {
    state.highlightItem = item;
    await updateState();
  }

  Future<void> setContentsHeight() async {
    state.contentsHeight = await getContentsHeight();
  }

  Future<double> getContentsHeight() async {
    double baseHeight = /*500 + */620;

    if (state.repeatingPattern != RepeatingPattern.none) {
      baseHeight += 50;
    }

    return baseHeight;
  }

  setTextFieldController<T>(TextFieldItem item, {T? value}) async {
    switch (item) {
      case TextFieldItem.title:
        if (value != null) {
          state.title = value as String?;
        }
        state.textEditingControllers!
        [TextFieldItem.title]!.text = state.title ?? '';
        break;
      case TextFieldItem.place:
        if (value != null) {
          state.place = value as String?;
        }
        state.textEditingControllers!
        [TextFieldItem.place]!.text = state.place ?? '';
        break;
      case TextFieldItem.startDate:
        if (value != null) {
          state.startDate = value as DateTime?;
        }
        state.textEditingControllers!
        [TextFieldItem.startDate]!.text = DateFormat('yyyy/MM/dd')
            .format(state.startDate!);
        changeStartDate(state.startDate);
        break;
      case TextFieldItem.startTime:
        if (value != null) {
          state.startDate = value as DateTime?;
        }
        state.textEditingControllers!
        [TextFieldItem.startTime]!.text = DateFormat('HH:mm')
            .format(state.startDate!);
        changeStartDate(state.startDate);
        break;
      case TextFieldItem.endDate:
        if (value != null) {
          state.endDate = value as DateTime?;
        }
        state.textEditingControllers!
        [TextFieldItem.endDate]!.text = DateFormat('yyyy/MM/dd')
            .format(state.endDate!);
        changeEndDate(state.endDate);
        break;
      case TextFieldItem.endTime:
        if (value != null) {
          state.endDate = value as DateTime?;
        }
        state.textEditingControllers!
        [TextFieldItem.endTime]!.text = DateFormat('HH:mm')
            .format(state.endDate!);
        changeEndDate(state.endDate);
        break;
      case TextFieldItem.repeat:
        if (value != null) {
          state.repeatingPattern = value as RepeatingPattern?;
        }
        state.textEditingControllers!
        [TextFieldItem.repeat]!.text = state.repeatingPattern!.name;
        break;
      case TextFieldItem.repeatingEndDate:
        if (value != null) {
          state.repeatingEndDate = value as DateTime?;
        }
        if (state.repeatingEndDate == null) {
          state.textEditingControllers!
          [TextFieldItem.repeatingEndDate]!.text = '';
        } else {
          state.textEditingControllers!
          [TextFieldItem.repeatingEndDate]!.text = DateFormat('yyyy/MM/dd')
              .format(state.repeatingEndDate!);
        }
        changeRepeatingEndDate(state.repeatingEndDate);
        break;
      case TextFieldItem.memo:
        if (value != null) {
          state.memo = value as String?;
        }
        state.textEditingControllers!
        [TextFieldItem.memo]!.text = state.memo ?? "";
        break;
      // 移動する
      // case TextFieldItem.destinationCalendar:
      //   if (value != null) {
      //     state.calendarId = value as String?;
      //   }
      //   state.textEditingControllers!
      //   [TextFieldItem.destinationCalendar]!.text = state.calendarId!;
      //   break;
    }
  }

  changeStartDate(startDate) async {
    if (state.endDate == null) {
      return;
    }

    if (!state.allDay! && startDate == state.endDate
        || startDate.isAfter(state.endDate)) {
      debugPrint('changeStartDate ${state.endDate}');
      state.endDate = !state.allDay! ? startDate.add(
          const Duration(hours: 1)) : startDate;
      setTextFieldController(TextFieldItem.endDate);
      setTextFieldController(TextFieldItem.endTime);
    }
  }

  changeEndDate(endDate) async {
    if (!state.allDay! && endDate == state.startDate
        || endDate.isBefore(state.startDate)) {
      debugPrint('changeEndDate ${state.startDate}');
      state.startDate = !state.allDay! ? endDate.add(
          const Duration(hours: -1)) : endDate;
      setTextFieldController(TextFieldItem.startDate);
      setTextFieldController(TextFieldItem.startTime);
    }

    if (state.repeatingEndDate != null && state.repeatingEnd == true && (
        endDate.isAfter(state.repeatingEndDate))) {
      state.repeatingEndDate = CalendarUtils().trimDate(endDate, maxTime: true);
      setTextFieldController(TextFieldItem.repeatingEndDate,
          value: state.repeatingEndDate);
    }
  }

  changeRepeatingEndDate(endRepeatingDate) async {
    if (endRepeatingDate != null &&
        endRepeatingDate.isBefore(state.endDate)) {
      state.endDate = endRepeatingDate;
      setTextFieldController(TextFieldItem.endDate);
      setTextFieldController(TextFieldItem.endTime);
    }
  }

  setRepeatingEnd(repeatingEnd) async {
    state.repeatingEnd = repeatingEnd;
  }

  Future<bool> saveEvent() async {
    var event = state.event ?? Event(state.calendar!.id);

    event.title = state.title;
    event.location = state.place;
    event.allDay = state.allDay;
    event.start = calendarRepo.convertTZDateTime(state.startDate!);
    event.end = calendarRepo.convertTZDateTime(state.endDate!);
    event.recurrenceRule = null;
    if (state.repeatingPattern != RepeatingPattern.none) {
      var repeatingEndDate = !state.repeatingEnd! ? null
          : state.repeatingEndDate;
      if (state.repeatingPattern != RepeatingPattern.other) {
        var frequency = state.repeatingPattern!.frequency;
        var interval = state.repeatingPattern!.interval;
        event.recurrenceRule = RecurrenceRule(frequency, interval: interval,
            endDate: repeatingEndDate);
      } else {
        event.recurrenceRule!.endDate = repeatingEndDate;
      }
    }
    event.description = state.memo;

    return await calendarRepo.createOrUpdateEvent(event);
  }

  updateState() async {
    state = EventDetailPageState.copy(state);
    debugPrint('updateState(detail)');
  }
}

final eventDetailPageNotifierProvider = StateNotifierProvider
    .autoDispose<EventDetailPageNotifier, EventDetailPageState>((ref) {
  return EventDetailPageNotifier(ref, EventDetailPageState());
});
