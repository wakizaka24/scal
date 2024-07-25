import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

enum EventDetailPageContentsMode {
  simpleInput,
  detailInput;
}

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
  startDay,
  startHour,
  endDay,
  endHour,
  repeat,
  repeatEnd,
  repeatEndDay,
  memo,
  // 移動する
  // destinationCalendar
}

enum TextFieldItem {
  title,
  place,
  startDay,
  startTime,
  endDay,
  endTime,
  repeat,
  repeatingEndDay,
  memo,
  // 移動する
  // destinationCalendar
}

const double firstContentsHeight = 1415;

class EventDetailPageState {
  // Control
  GlobalKey? contentsKey;
  Map<TextFieldItem, TextEditingController>? textEditingControllers;

  // Data
  EventDetailPageContentsMode? contentsMode;
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

    nState.contentsMode = state.contentsMode;
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

  initState() async {
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
    state.contentsMode = EventDetailPageContentsMode.detailInput;
    state.contentsHeight = await getContentsHeight();

    state.title = '';
    state.place = '';
    state.allDay = false;

    state.startDate = DateTime(2024, 4, 30, 7, 30);
    setTextFieldController(TextFieldItem.startDay);
    setTextFieldController(TextFieldItem.startTime);

    state.endDate = DateTime(2025, 5, 31, 8, 31);
    setTextFieldController(TextFieldItem.endDay);
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

  setContentsMode(EventDetailPageContentsMode contentsMode) async {
    state.contentsMode = contentsMode;
    state.contentsHeight = await getContentsHeight();
    updateState();
  }

  Future<double> getContentsHeight() async {
    switch (state.contentsMode!) {
      case EventDetailPageContentsMode.simpleInput:
        return 776 + 500;
      case EventDetailPageContentsMode.detailInput:
        return firstContentsHeight;
    }
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
      case TextFieldItem.startDay:
        if (value != null) {
          state.startDate = value as DateTime?;
        }
        state.textEditingControllers!
        [TextFieldItem.startDay]!.text = DateFormat('yyyy/MM/dd')
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
      case TextFieldItem.endDay:
        if (value != null) {
          state.endDate = value as DateTime?;
        }
        state.textEditingControllers!
        [TextFieldItem.endDay]!.text = DateFormat('yyyy/MM/dd')
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
      case TextFieldItem.repeatingEndDay:
        state.repeatingEndDate = value as DateTime?;
        if (state.repeatingEndDate == null) {
          state.textEditingControllers!
          [TextFieldItem.repeatingEndDay]!.text = '';
        } else {
          state.textEditingControllers!
          [TextFieldItem.repeatingEndDay]!.text = DateFormat('yyyy/MM/dd')
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
    if (startDate == state.endDate
      || startDate.isAfter(state.endDate)) {
      state.endDate = startDate.add(const Duration(hours: 1));
      setTextFieldController(TextFieldItem.endDay);
      setTextFieldController(TextFieldItem.endTime);
    }
  }

  changeEndDate(endDate) async {
    if (endDate == state.startDate
      || endDate.isBefore(state.startDate)) {
      state.startDate = endDate.add(const Duration(hours: -1));
      setTextFieldController(TextFieldItem.startDay);
      setTextFieldController(TextFieldItem.startTime);
    }
  }

  changeRepeatingEndDate(endRepeatingDate) async {
    if (endRepeatingDate != null &&
        endRepeatingDate.isBefore(state.endDate)) {
      state.endDate = endRepeatingDate;
      setTextFieldController(TextFieldItem.endDay);
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
