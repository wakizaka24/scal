import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'f006_shared_preferences_repository.dart';

const calendarConfigDelimiter = ',';
enum CalendarHoliday {
  none('none'), // 通常
  red('red'), // 赤表示
  blue('blue'), // 青表示
  brown('brown'); // ブラウン表示
  final String configValue;
  const CalendarHoliday(this.configValue);
}

enum CalendarDisplayMode {
  display, // 表示
  hidden, // 隠し表示
  both, // 両方表示
  invisible; // 非表示
}

enum CalendarEditingMode {
  editable, // 編集可
  notEditable // 編集不可
}

enum CalendarHolidayDisplayMode {
  nonHolidayDisplay, // 非祝日表示
  holidayDisplay // 祝日表示
}

class CalendarConfigState {
  List<CalendarHoliday> calendarHolidayList = [];
  List<String> calendarHiddenCalendarIds = [];
  List<String> calendarBothCalendarIds = [];
  List<String> calendarInvisibleCalendarIds = [];
  List<String> calendarNotEditableCalendarIds = [];
  List<String> calendarHolidayCalendarIds = [];

  static CalendarConfigState copy(CalendarConfigState state) {
    var nState = CalendarConfigState();
    nState.calendarHolidayList = state.calendarHolidayList;
    nState.calendarHiddenCalendarIds = state.calendarHiddenCalendarIds;
    nState.calendarBothCalendarIds = state.calendarBothCalendarIds;
    nState.calendarInvisibleCalendarIds = state.calendarInvisibleCalendarIds;
    nState.calendarNotEditableCalendarIds = state
        .calendarNotEditableCalendarIds;
    nState.calendarHolidayCalendarIds = state.calendarHolidayCalendarIds;
    return nState;
  }
}

class CalendarConfigNotifier extends StateNotifier<CalendarConfigState> {
  final Ref ref;
  CalendarConfigNotifier(this.ref, CalendarConfigState state) : super(state);

  initState(
      String? calendarHolidayList,
      String? calendarHiddenCalendarIds,
      String? calendarBothCalendarIds,
      String? calendarInvisibleCalendarIds,
      String? calendarNotEditableCalendarIds,
      String? calendarHolidayCalendarIds) async {

    state.calendarHolidayList = calendarHolidayList
        ?.split(calendarConfigDelimiter)
        .map((value) => CalendarHoliday.values.where((holiday)=>holiday
        .configValue == value).first
    ).toList() ?? [CalendarHoliday.red, CalendarHoliday.none,
      CalendarHoliday.none, CalendarHoliday.none,
      CalendarHoliday.none, CalendarHoliday.none,
      CalendarHoliday.blue];
    state.calendarHiddenCalendarIds = calendarHiddenCalendarIds
        ?.split(calendarConfigDelimiter).toList() ?? [];
    state.calendarBothCalendarIds = calendarBothCalendarIds
        ?.split(calendarConfigDelimiter).toList() ?? [];
    state.calendarInvisibleCalendarIds = calendarInvisibleCalendarIds
        ?.split(calendarConfigDelimiter).toList() ?? [];
    state.calendarNotEditableCalendarIds = calendarNotEditableCalendarIds
        ?.split(calendarConfigDelimiter).toList() ?? [];
    state.calendarHolidayCalendarIds = calendarHolidayCalendarIds
        ?.split(calendarConfigDelimiter).toList() ?? [];
  }

  switchCalendarHolidaySunday(int index) async {
    var holidayConfig = CalendarHoliday.values;
    var holidaySunday = state.calendarHolidayList[index];
    holidaySunday = holidayConfig[(holidaySunday.index + 1)
        % holidayConfig.length];
    state.calendarHolidayList[index] = holidaySunday;
    var sundayConfig = listToCalendarConfig(state.calendarHolidayList
        .map((holiday)=>holiday.configValue).toList());
    await SharedPreferencesRepository().setString(
        SharedPreferenceStringKey.calendarHolidayList,
        sundayConfig
    );
  }

  Future<CalendarDisplayMode> getCalendarDisplayMode(String calendarId) async {
    List<String> calendarHiddenCalendarIds = state.calendarHiddenCalendarIds;
    List<String> calendarBothCalendarIds = state.calendarBothCalendarIds;
    List<String> calendarInvisibleCalendarIds = state
        .calendarInvisibleCalendarIds;

    var hidden = calendarHiddenCalendarIds.where((id)=>id == calendarId)
        .firstOrNull != null;
    var both = calendarBothCalendarIds.where((id)=>id == calendarId)
        .firstOrNull != null;
    var invisible = calendarInvisibleCalendarIds.where((id)=>id == calendarId)
        .firstOrNull != null;

    CalendarDisplayMode mode = hidden ? CalendarDisplayMode.hidden
        : both ? CalendarDisplayMode.both
        : invisible ? CalendarDisplayMode.invisible
        : CalendarDisplayMode.display;
    return mode;
  }

  Future<CalendarDisplayMode> switchCalendarDisplayMode(String calendarId
      ) async {
    var modeList = CalendarDisplayMode.values.toList();
    List<String> calendarHiddenCalendarIds = state.calendarHiddenCalendarIds;
    List<String> calendarBothCalendarIds = state.calendarBothCalendarIds;
    List<String> calendarInvisibleCalendarIds = state
        .calendarInvisibleCalendarIds;

    var mode = await getCalendarDisplayMode(calendarId);
    mode = modeList[(mode.index + 1) % modeList.length];

    calendarHiddenCalendarIds.remove(calendarId);
    calendarBothCalendarIds.remove(calendarId);
    calendarInvisibleCalendarIds.remove(calendarId);

    switch(mode) {
      case CalendarDisplayMode.display:
        break;
      case CalendarDisplayMode.hidden:
        calendarHiddenCalendarIds.add(calendarId);
        break;
      case CalendarDisplayMode.both:
        calendarBothCalendarIds.add(calendarId);
        break;
      case CalendarDisplayMode.invisible:
        calendarInvisibleCalendarIds.add(calendarId);
        break;
    }

    if (calendarHiddenCalendarIds != state.calendarHiddenCalendarIds) {
      state.calendarHiddenCalendarIds = calendarHiddenCalendarIds;
      await SharedPreferencesRepository().setString(
          SharedPreferenceStringKey.calendarHiddenCalendarIds,
          listToCalendarConfig(calendarHiddenCalendarIds)
      );
    }

    if (calendarBothCalendarIds != state.calendarBothCalendarIds) {
      state.calendarBothCalendarIds = calendarBothCalendarIds;
      await SharedPreferencesRepository().setString(
          SharedPreferenceStringKey.calendarBothCalendarIds,
          listToCalendarConfig(calendarBothCalendarIds)
      );
    }

    if (calendarInvisibleCalendarIds != state.calendarInvisibleCalendarIds) {
      state.calendarInvisibleCalendarIds = calendarInvisibleCalendarIds;
      await SharedPreferencesRepository().setString(
          SharedPreferenceStringKey.calendarInvisibleCalendarIds,
          listToCalendarConfig(calendarInvisibleCalendarIds)
      );
    }

    return mode;
  }

  Future<CalendarEditingMode> getCalendarEditingMode(String calendarId) async {
    List<String> calendarNotEditableCalendarIds = state
        .calendarNotEditableCalendarIds;

    var notEditable = calendarNotEditableCalendarIds.where((id)=>id
        == calendarId).firstOrNull != null;

    CalendarEditingMode mode = notEditable ? CalendarEditingMode.notEditable
        : CalendarEditingMode.editable;
    return mode;
  }

  Future<CalendarEditingMode> switchCalendarEditingMode(String calendarId
      ) async {
    var modeList = CalendarEditingMode.values.toList();
    List<String> calendarNotEditableCalendarIds = state
        .calendarNotEditableCalendarIds;

    var mode = await getCalendarEditingMode(calendarId);
    mode = modeList[(mode.index + 1) % modeList.length];

    calendarNotEditableCalendarIds.remove(calendarId);

    switch(mode) {
      case CalendarEditingMode.editable:
        break;
      case CalendarEditingMode.notEditable:
        calendarNotEditableCalendarIds.add(calendarId);
        break;
    }

    if (calendarNotEditableCalendarIds != state.calendarNotEditableCalendarIds) {
      state.calendarNotEditableCalendarIds = calendarNotEditableCalendarIds;
      await SharedPreferencesRepository().setString(
          SharedPreferenceStringKey.calendarNotEditableCalendarIds,
          listToCalendarConfig(calendarNotEditableCalendarIds)
      );
    }

    return mode;
  }

  Future<CalendarHolidayDisplayMode> getCalendarHolidayDisplayMode(
      String calendarId) async {
    List<String> calendarHolidayCalendarIds = state.calendarHolidayCalendarIds;

    var holiday = calendarHolidayCalendarIds.where((id)=>id
        == calendarId).firstOrNull != null;

    CalendarHolidayDisplayMode mode = holiday ? CalendarHolidayDisplayMode
        .holidayDisplay : CalendarHolidayDisplayMode.nonHolidayDisplay;
    return mode;
  }

  Future<CalendarHolidayDisplayMode> switchCalendarHolidayDisplayMode(
      String calendarId) async {

    var modeList = CalendarHolidayDisplayMode.values.toList();
    List<String> calendarHolidayCalendarIds = state.calendarHolidayCalendarIds;

    var mode = await getCalendarHolidayDisplayMode(calendarId);
    mode = modeList[(mode.index + 1) % modeList.length];

    calendarHolidayCalendarIds.remove(calendarId);

    switch(mode) {
      case CalendarHolidayDisplayMode.nonHolidayDisplay:
        break;
      case CalendarHolidayDisplayMode.holidayDisplay:
        calendarHolidayCalendarIds.add(calendarId);
        break;
    }

    if (calendarHolidayCalendarIds != state.calendarHolidayCalendarIds) {
      state.calendarHolidayCalendarIds = calendarHolidayCalendarIds;
      await SharedPreferencesRepository().setString(
          SharedPreferenceStringKey.calendarHolidayCalendarIds,
          listToCalendarConfig(calendarHolidayCalendarIds)
      );
    }

    return mode;
  }

  String listToCalendarConfig(List<String> list) {
    return list.reduce((value, configValue) {
      if (value.isNotEmpty) {
        value += calendarConfigDelimiter;
      }
      value += configValue;
      return value;
    });
  }

  updateState() async {
    state = CalendarConfigState.copy(state);
    debugPrint('updateState(calendar config)');
  }
}

final calendarConfigNotifierProvider = StateNotifierProvider
    .autoDispose<CalendarConfigNotifier, CalendarConfigState>((ref) {
  var state = CalendarConfigState();
  return CalendarConfigNotifier(ref, state);
});