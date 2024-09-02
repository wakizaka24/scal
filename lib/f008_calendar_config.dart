import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'f006_shared_preferences_repository.dart';

const calendarConfigDelimiter = ',';
enum CalendarHoliday {
  none('none'),
  red('red'),
  blue('blue');
  final String configValue;
  const CalendarHoliday(this.configValue);
}

enum CalendarSwitchMode implements SharedPreferenceStringValue {
  off('off'),
  setting1('setting1'),
  setting2('setting2');
  @override
  final String configValue;
  const CalendarSwitchMode(this.configValue);
}

enum CalendarBaseConfig {
  display,
  notEditable,
  nonDisplay
}

enum CalendarHolidayConfig {
  none,
  holiday
}

class CalendarConfigState {
  List<CalendarHoliday> calendarHolidayList = [];
  CalendarSwitchMode? calendarSwitchMode;
  String? calendar1EditingCalendarId;
  List<String> calendar1NonDisplayCalendarIds = [];
  List<String> calendar1NotEditableCalendarIds = [];
  List<String> calendar1HolidayCalendarIds = [];
  String? calendar2EditingCalendarId;
  List<String> calendar2NonDisplayCalendarIds = [];
  List<String> calendar2NotEditableCalendarIds = [];
  List<String> calendar2HolidayCalendarIds = [];

  static CalendarConfigState copy(CalendarConfigState state) {
    var nState = CalendarConfigState();
    nState.calendarHolidayList = state.calendarHolidayList;
    nState.calendarSwitchMode = state.calendarSwitchMode;
    nState.calendar1EditingCalendarId = state.calendar1EditingCalendarId;
    nState.calendar1NonDisplayCalendarIds = state
        .calendar1NonDisplayCalendarIds;
    nState.calendar1NotEditableCalendarIds = state
        .calendar1NotEditableCalendarIds;
    nState.calendar1HolidayCalendarIds = state.calendar1HolidayCalendarIds;
    nState.calendar2EditingCalendarId = state.calendar2EditingCalendarId;
    nState.calendar2NonDisplayCalendarIds = state
        .calendar2NonDisplayCalendarIds;
    nState.calendar2NotEditableCalendarIds = state
        .calendar2NotEditableCalendarIds;
    nState.calendar2HolidayCalendarIds = state.calendar2HolidayCalendarIds;

    return nState;
  }
}

class CalendarConfigNotifier extends StateNotifier<CalendarConfigState> {
  final Ref ref;
  CalendarConfigNotifier(this.ref, CalendarConfigState state) : super(state);
  initState(
      String? calendarHolidaySundayConfig,
      CalendarSwitchMode? calendarSwitchMode,
      String? calendar1EditingCalendarId,
      String? calendar1NoneDisplayCalendarIds,
      String? calendar1NotEditableCalendarIds,
      String? calendar1HolidayCalendarIds,
      String? calendar2EditingCalendarId,
      String? calendar2NoneDisplayCalendarIds,
      String? calendar2NotEditableCalendarIds,
      String? calendar2HolidayCalendarIds) async {
    state.calendarHolidayList = calendarHolidaySundayConfig
        ?.split(calendarConfigDelimiter)
        .map((value) => CalendarHoliday.values.where((holiday)=>holiday
        .configValue == value).first
    ).toList() ?? [CalendarHoliday.red, CalendarHoliday.none,
      CalendarHoliday.none, CalendarHoliday.none,
      CalendarHoliday.none, CalendarHoliday.none,
      CalendarHoliday.blue];
    state.calendarSwitchMode = calendarSwitchMode;
    state.calendar1EditingCalendarId = calendar1EditingCalendarId;
    state.calendar1NonDisplayCalendarIds = calendar1NoneDisplayCalendarIds
      ?.split(calendarConfigDelimiter).toList() ?? [];
    state.calendar1NotEditableCalendarIds = calendar1NotEditableCalendarIds
        ?.split(calendarConfigDelimiter).toList() ?? [];
    state.calendar1HolidayCalendarIds = calendar1HolidayCalendarIds
        ?.split(calendarConfigDelimiter).toList() ?? [];
    state.calendar2EditingCalendarId = calendar2EditingCalendarId;
    state.calendar2NonDisplayCalendarIds = calendar2NoneDisplayCalendarIds
        ?.split(calendarConfigDelimiter).toList() ?? [];
    state.calendar2NotEditableCalendarIds = calendar2NotEditableCalendarIds
        ?.split(calendarConfigDelimiter).toList() ?? [];
    state.calendar2HolidayCalendarIds = calendar2HolidayCalendarIds
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
        SharedPreferenceStringKey.calendarHolidaySundayConfig,
        sundayConfig
    );
  }

  setEditingCalendarId(int configNo, String calendarId) async {
    if (configNo != 2) {
      await SharedPreferencesRepository().setString(
          SharedPreferenceStringKey.calendar1EditingCalendarId,
          calendarId
      );
    } else {
      await SharedPreferencesRepository().setString(
          SharedPreferenceStringKey.calendar2EditingCalendarId,
          calendarId
      );
    }
  }

  switchCalendarBaseConfig(int configNo, String calendarId, bool readOnly
      ) async {
    var configList = CalendarBaseConfig.values.where(
            (config)=>!readOnly || readOnly
                && config != CalendarBaseConfig.display).toList();
    List<String> nonDisplayCalendarIds;
    List<String> notEditableCalendarIds;
    if (configNo != 2) {
      nonDisplayCalendarIds = state.calendar1NonDisplayCalendarIds;
      notEditableCalendarIds = state.calendar1NotEditableCalendarIds;
    } else {
      nonDisplayCalendarIds = state.calendar2NonDisplayCalendarIds;
      notEditableCalendarIds = state.calendar2NotEditableCalendarIds;
    }

    var nonDisplay = nonDisplayCalendarIds.where((id)=>id == calendarId)
        .firstOrNull != null;
    var notEditable = notEditableCalendarIds.where((id)=>id == calendarId)
        .firstOrNull != null;
    var config = nonDisplay ? CalendarBaseConfig.nonDisplay
        : notEditable ? CalendarBaseConfig.notEditable
        : CalendarBaseConfig.display;
    config = configList[(config.index + 1) % configList.length];

    nonDisplayCalendarIds.remove(calendarId);
    notEditableCalendarIds.remove(calendarId);
    switch(config) {
      case CalendarBaseConfig.display:
        break;
      case CalendarBaseConfig.notEditable:
        notEditableCalendarIds.add(calendarId);
        break;
      case CalendarBaseConfig.nonDisplay:
        nonDisplayCalendarIds.add(calendarId);
        break;
    }

    if (configNo != 2) {
      if (nonDisplayCalendarIds != state.calendar1NonDisplayCalendarIds) {
        state.calendar1NonDisplayCalendarIds = nonDisplayCalendarIds;
        await SharedPreferencesRepository().setString(
            SharedPreferenceStringKey.calendar1NonDisplayCalendarIds,
            listToCalendarConfig(nonDisplayCalendarIds)
        );
      }
      if (notEditableCalendarIds != state.calendar1NotEditableCalendarIds) {
        state.calendar1NotEditableCalendarIds = notEditableCalendarIds;
        await SharedPreferencesRepository().setString(
            SharedPreferenceStringKey.calendar1NotEditableCalendarIds,
            listToCalendarConfig(nonDisplayCalendarIds)
        );
      }
    } else {
      if (nonDisplayCalendarIds != state.calendar2NonDisplayCalendarIds) {
        state.calendar2NonDisplayCalendarIds = nonDisplayCalendarIds;
        await SharedPreferencesRepository().setString(
            SharedPreferenceStringKey.calendar2NonDisplayCalendarIds,
            listToCalendarConfig(nonDisplayCalendarIds)
        );
      }
      if (notEditableCalendarIds != state.calendar2NotEditableCalendarIds) {
        state.calendar2NotEditableCalendarIds = notEditableCalendarIds;
        await SharedPreferencesRepository().setString(
            SharedPreferenceStringKey.calendar2NotEditableCalendarIds,
            listToCalendarConfig(nonDisplayCalendarIds)
        );
      }
    }
  }

  switchCalendarHolidayConfig(int configNo, String calendarId) async {
    var configList = CalendarHolidayConfig.values;
    List<String> holidayCalendarIds;
    if (configNo != 2) {
      holidayCalendarIds = state.calendar1HolidayCalendarIds;
    } else {
      holidayCalendarIds = state.calendar2HolidayCalendarIds;
    }

    var holiday = holidayCalendarIds.where((id)=>id == calendarId)
        .firstOrNull != null;
    var config = holiday ? CalendarHolidayConfig.holiday
        : CalendarHolidayConfig.none;
    config = configList[(config.index + 1) % configList.length];

    holidayCalendarIds.remove(calendarId);
    switch(config) {
      case CalendarHolidayConfig.none:
        break;
      case CalendarHolidayConfig.holiday:
        holidayCalendarIds.add(calendarId);
        break;
    }

    if (configNo != 2) {
      state.calendar1HolidayCalendarIds = holidayCalendarIds;
      await SharedPreferencesRepository().setString(
          SharedPreferenceStringKey.calendar1HolidayCalendarIds,
          listToCalendarConfig(holidayCalendarIds)
      );
    } else {
      state.calendar2HolidayCalendarIds = holidayCalendarIds;
      await SharedPreferencesRepository().setString(
          SharedPreferenceStringKey.calendar2HolidayCalendarIds,
          listToCalendarConfig(holidayCalendarIds)
      );
    }
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

