import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
  startDate,
  startHour,
  endDate,
  endHour,
  repeat,
  repeatEnd,
  repeatEndDate,
  memo,
  destinationCalendar
}

enum TextFieldItem {
  title,
  place,
  allDay,
  startDate,
  startHour,
  endDate,
  endHour,
  repeat,
  repeatEnd,
  repeatEndDate,
  memo,
  destinationCalendar
}

const double firstContentsHeight = 907;

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
  int? formStartYear;
  int? formStartMonth;
  int? formStartDay;
  int? formStartHour;
  int? formStartMinute;
  int? formEndYear;
  int? formEndMonth;
  int? formEndDay;
  int? formEndHour;
  int? formEndMinute;

  RepeatingPattern? repeatingPattern;
  bool? repeatingEnd;
  int? formRepeatEndYear;
  int? formRepeatEndMonth;
  int? formRepeatEndDay;
  String? calendarId;
  String? prevCalendarId;

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
    nState.formStartYear = state.formStartYear;
    nState.formStartMonth = state.formStartMonth;
    nState.formStartDay = state.formStartDay;
    nState.formStartHour = state.formStartHour;
    nState.formStartMinute = state.formStartMinute;
    nState.formEndYear = state.formEndYear;
    nState.formEndMonth = state.formEndMonth;
    nState.formEndDay = state.formEndDay;
    nState.formEndHour = state.formEndHour;
    nState.formEndMinute = state.formEndMinute;

    nState.repeatingPattern = state.repeatingPattern;
    nState.repeatingEnd = state.repeatingEnd;
    nState.formRepeatEndYear = state.formRepeatEndYear;
    nState.formRepeatEndMonth = state.formRepeatEndMonth;
    nState.formRepeatEndDay = state.formRepeatEndDay;
    nState.calendarId = state.calendarId;
    nState.prevCalendarId = state.prevCalendarId;

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
        km[item] = TextEditingController(text: 'aaaa');
      }
      return km;
    })();

    // Data
    state.contentsMode = EventDetailPageContentsMode.detailInput;
    state.contentsHeight = await getContentsHeight();

    state.title = '';
    state.place = '';
    state.allDay = false;
    state.formStartYear = 2024;
    state.formStartMonth = 4;
    state.formStartDay = 30;
    state.textEditingControllers!
    [TextFieldItem.startDate]!.text = '2024/04/30';

    state.formStartHour = 7;
    state.formStartMinute = 30;
    state.formEndYear = 2025;
    state.formEndMonth = 5;
    state.formEndDay = 31;
    state.formEndHour = 08;
    state.formEndMinute = 31;

    state.repeatingPattern = RepeatingPattern.none;
    state.repeatingEnd = false;
    state.formRepeatEndYear = null;
    state.formRepeatEndMonth = null;
    state.formRepeatEndDay = null;
    state.calendarId = 'TEST_ID_1';
    state.prevCalendarId = 'TEST_ID_1';

    state.highlightItem = HighlightItem.none;
  }

  @override
  dispose() {
    super.dispose();

    for (var controller in state.textEditingControllers!.values) {
      controller.dispose();
    }
  }

  updateHighlightItem(HighlightItem item) {
    state.highlightItem = item;
    updateState();
  }

  setContentsMode(EventDetailPageContentsMode contentsMode) async {
    state.contentsMode = contentsMode;
    state.contentsHeight = await getContentsHeight();
    updateState();
  }

  Future<double> getContentsHeight() async {
    switch (state.contentsMode!) {
      case EventDetailPageContentsMode.simpleInput:
        return 670;
      case EventDetailPageContentsMode.detailInput:
        return firstContentsHeight;
    }
  }

  updateState() async {
    state = EventDetailPageState.copy(state);
  }
}

final eventDetailPageNotifierProvider = StateNotifierProvider
    .autoDispose<EventDetailPageNotifier, EventDetailPageState>((ref) {
  return EventDetailPageNotifier(ref, EventDetailPageState());
});
