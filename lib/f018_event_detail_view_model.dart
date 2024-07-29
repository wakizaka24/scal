import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:scal/f008_calendar_repository.dart';

import 'f015_calendar_utils.dart';

enum RepeatingPattern {
  none('なし'),
  daily('毎日'),
  weekly('毎週'),
  biweekly('隔週'),
  monthly('毎月'),
  yearly('毎年');

  const RepeatingPattern(this.name);

  final String name;
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

  String? title;
  String? place;
  bool? allDay;
  DateTime? startDate;
  DateTime? endDate;
  RepeatingPattern? repeatingPattern;
  bool? repeatingEnd;
  DateTime? repeatingEndDate;
  String? memo;
  String? calendarId;

  HighlightItem? highlightItem;

  static EventDetailPageState copy(EventDetailPageState state) {
    var nState = EventDetailPageState();
    nState.contentsKey = state.contentsKey;
    nState.textEditingControllers = state.textEditingControllers;

    nState.contentsHeight = state.contentsHeight;

    nState.title = state.title;
    nState.place = state.place;
    nState.allDay = state.allDay;
    nState.startDate = state.startDate;
    nState.endDate = state.endDate;

    nState.repeatingPattern = state.repeatingPattern;
    nState.repeatingEnd = state.repeatingEnd;
    nState.repeatingEndDate = state.repeatingEndDate;
    nState.memo = state.memo;
    nState.calendarId = state.calendarId;

    nState.highlightItem = state.highlightItem;

    return nState;
  }
}

class EventDetailPageNotifier extends StateNotifier<EventDetailPageState> {
  final Ref ref;

  EventDetailPageNotifier(this.ref, EventDetailPageState state)
      : super(state);

  initState(bool selectDayOrTime, {bool? selectDay, DateTime? selectionDate,
    Event? event}) async {

    // Control
    state.contentsKey = GlobalKey();
    state.textEditingControllers = (() {
      var km = <TextFieldItem, TextEditingController>{};
      for (var item in TextFieldItem.values) {
        km[item] = TextEditingController();
      }
      return km;
    })();

    // Data
    state.contentsHeight = await getContentsHeight();

    // String? eventId, String? calendarId, bool? readOnly}


    state.title = '';
    state.place = '';
    state.allDay = false;

    state.startDate = DateTime(2024, 4, 30, 7, 30);
    setTextFieldController(TextFieldItem.startDate);
    setTextFieldController(TextFieldItem.startTime);

    state.endDate = DateTime(2025, 5, 31, 8, 30);
    setTextFieldController(TextFieldItem.endDate);
    setTextFieldController(TextFieldItem.endTime);

    state.repeatingPattern = RepeatingPattern.none;
    setTextFieldController(TextFieldItem.repeat);

    state.repeatingEnd = false;
    state.repeatingEndDate = null;

    state.memo = '';
    setTextFieldController(TextFieldItem.memo);

    // state.calendarId = 'TEST_ID_1';
    // setTextFieldController(TextFieldItem.destinationCalendar);

    state.highlightItem = HighlightItem.none;
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

  Future<double> getContentsHeight() async {
    double baseHeight = 606;

    if (state.allDay == true) {
      baseHeight -= 48;
    }

    if (state.repeatingEnd == true) {
      baseHeight += 49;
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
        [TextFieldItem.title]!.text = state.title!;
        break;
      case TextFieldItem.place:
        if (value != null) {
          state.place = value as String?;
        }
        state.textEditingControllers!
        [TextFieldItem.place]!.text = state.place!;
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
        [TextFieldItem.memo]!.text = state.memo!;
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
    if (!state.allDay!) {
      if (startDate == state.endDate
          || startDate.isAfter(state.endDate)) {
        state.endDate = startDate.add(const Duration(hours: 1));
        setTextFieldController(TextFieldItem.endDate);
        setTextFieldController(TextFieldItem.endTime);
      }
    } else {
      var endDate = startDate.add(const Duration(days: 1));
      if (endDate != state.endDate) {
        state.endDate = endDate;
        setTextFieldController(TextFieldItem.endDate);
        setTextFieldController(TextFieldItem.endTime);
      }
    }
  }

  changeEndDate(endDate) async {
    if (!state.allDay!) {
      if (endDate == state.startDate
          || endDate.isBefore(state.startDate)) {
        state.startDate = endDate.add(const Duration(hours: -1));
        setTextFieldController(TextFieldItem.startDate);
        setTextFieldController(TextFieldItem.startTime);
      }
    } else {
      var startDate = endDate.add(const Duration(days: -1));
      if (startDate != state.startDate) {
        state.startDate = startDate;
        setTextFieldController(TextFieldItem.startDate);
        setTextFieldController(TextFieldItem.startTime);
      }
    }

    if (state.repeatingEnd == true && (endDate == state.repeatingEndDate
        || endDate.isAfter(state.repeatingEndDate))) {
      state.repeatingEndDate = endDate;
      if (state.repeatingEndDate!.hour > 0
          || state.repeatingEndDate!.minute > 0) {
        state.repeatingEndDate = CalendarUtils().trimDate(
            state.repeatingEndDate!).add(const Duration(days: 1));
      }

      setTextFieldController(TextFieldItem.repeatingEndDate);
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

  updateState() async {
    state = EventDetailPageState.copy(state);
  }
}

final eventDetailPageNotifierProvider = StateNotifierProvider
    .autoDispose<EventDetailPageNotifier, EventDetailPageState>((ref) {
  return EventDetailPageNotifier(ref, EventDetailPageState());
});
