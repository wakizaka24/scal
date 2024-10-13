import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'f006_shared_preferences_repository.dart';
import 'f007_calendar_repository.dart';
import 'f017_design_config.dart';

const calendarConfigDelimiter = ',';
enum CalendarHoliday {
  none('none'), // 通常
  red('red'), // 赤表示
  blue('blue'), // 青表示
  brown('brown'); // ブラウン表示
  final String value;
  const CalendarHoliday(this.value);
}

enum CalendarDisplayMode {
  display('表示'),
  hidden('隠し表示'),
  both('両方表示'),
  invisible('非表示');
  final String title;
  const CalendarDisplayMode(this.title);
}

enum CalendarEditingMode {
  editable('編集可'),
  notEditable('編集不可');
  final String title;
  const CalendarEditingMode(this.title);
}

enum CalendarUseMode {
  use('使用'),
  notUse('未使用');
  final String title;
  const CalendarUseMode(this.title);
}

enum CalendarHolidayDisplayMode {
  nonHolidayDisplay('非祝日表示'),
  holidayDisplay('祝日表示');
  final String title;
  const CalendarHolidayDisplayMode(this.title);
}

initCalendarConfig() async {
  var init = await SharedPreferencesRepository().getBool(
      SharedPreferenceKey.initCalendarConfig) ?? false;
  await SharedPreferencesRepository().setBool(
      SharedPreferenceKey.initCalendarConfig, true);
  if (init) {
    return;
  }

  const iOSCalendarAccountName = 'Subscribed Calendars';
  const japaneseHolidayName = '日本の祝日';

  await CalendarRepository().hasPermissions();
  var calendars = await CalendarRepository().getCalendars();

  var holidayCalendarId = calendars
      .where((calendar) => calendar.accountName == iOSCalendarAccountName
      && calendar.name == japaneseHolidayName)
      .map((calendar) => calendar.id!).firstOrNull;
  if (holidayCalendarId == null) {
    var filteredCalendars = calendars
        .where((calendar) => calendar.name == japaneseHolidayName).toList();
    filteredCalendars.sort((calendar1, calendar2) => calendar1.accountName!
        .compareTo(calendar2.accountName!));
    holidayCalendarId = filteredCalendars.map((calendar) => calendar.id!)
        .firstOrNull;
  }

  if (holidayCalendarId != null) {
    await SharedPreferencesRepository().setString(
        SharedPreferenceKey.calendarHolidayCalendarIds,
        holidayCalendarId
    );

    var otherHolidayCalendars = calendars
        .where((calendar) => calendar.name == japaneseHolidayName
        && calendar.id != holidayCalendarId)
        .map((calendar) => calendar.id!).toList();

    await SharedPreferencesRepository().setString(
        SharedPreferenceKey.calendarInvisibleCalendarIds,
        listToCalendarConfig(otherHolidayCalendars)
    );
  }

  var useCalendar = calendars.where((calendar) => calendar.isDefault!)
      .map((calendar) => calendar.id!)
      .firstOrNull;
  useCalendar ??= calendars.where((calendar) => !calendar.isReadOnly!)
      .map((calendar) => calendar.id!).firstOrNull;
  if (useCalendar != null) {
    await SharedPreferencesRepository().setString(
        SharedPreferenceKey.calendarUseCalendarId,
        useCalendar
    );
  }
}

String? listToCalendarConfig(List<String> list) {
  if (list.isEmpty) {
    return null;
  }
  return list.reduce((value, configValue) {
    if (value.isNotEmpty) {
      value += calendarConfigDelimiter;
    }
    value += configValue;
    return value;
  });
}

Future<(
  BrightnessMode?, // brightnessMode
  ColorConfig?, // lightColorConfig
  ColorConfig?, // darkColorConfig
  String?, // calendarHolidayList
  bool?, // calendarHiddenMode
  String?, // calendarHiddenCalendarIds
  String?, // calendarBothCalendarIds
  String?, // calendarInvisibleCalendarIds
  String?, // calendarNotEditableCalendarIds
  String?, // calendarUseCalendarId
  String? // calendarHolidayCalendarIds
)> getCalendarConfigs() async {
  return (
    await SharedPreferencesRepository()
        .getStringEnum(SharedPreferenceKey.brightnessMode,
        BrightnessMode.values),
    await SharedPreferencesRepository()
        .getStringEnum(SharedPreferenceKey.lightColorMode,
        ColorConfig.values) ??
        ColorConfig.values.firstWhere((config) => config
            .brightness == Brightness.light),
    await SharedPreferencesRepository()
        .getStringEnum(SharedPreferenceKey.darkColorMode,
        ColorConfig.values) ??
        ColorConfig.values.firstWhere((config) => config
            .brightness == Brightness.dark),
    await SharedPreferencesRepository()
        .getString(SharedPreferenceKey.calendarHolidayList),
    await SharedPreferencesRepository()
        .getBool(SharedPreferenceKey.calendarHiddenMode),
    await SharedPreferencesRepository()
        .getString(SharedPreferenceKey.calendarHiddenCalendarIds),
    await SharedPreferencesRepository()
        .getString(SharedPreferenceKey.calendarBothCalendarIds),
    await SharedPreferencesRepository()
        .getString(SharedPreferenceKey.calendarInvisibleCalendarIds),
    await SharedPreferencesRepository()
        .getString(SharedPreferenceKey.calendarNotEditableCalendarIds),
    await SharedPreferencesRepository()
        .getString(SharedPreferenceKey.calendarUseCalendarId),
    await SharedPreferencesRepository()
        .getString(SharedPreferenceKey.calendarHolidayCalendarIds)
  );
}

class CalendarAndAdditionalInfo {
  Calendar calendar;
  CalendarDisplayMode displayMode;
  CalendarEditingMode editingMode;
  CalendarUseMode useMode;
  CalendarHolidayDisplayMode holidayDisplayMode;

  CalendarAndAdditionalInfo({
    required this.calendar,
    required this.displayMode,
    required this.editingMode,
    required this.useMode,
    required this.holidayDisplayMode
  });
}

class CalendarConfigState {
  List<CalendarHoliday> calendarHolidayList = [];
  bool calendarHiddenMode = false;
  List<String> calendarHiddenCalendarIds = [];
  List<String> calendarBothCalendarIds = [];
  List<String> calendarInvisibleCalendarIds = [];
  List<String> calendarNotEditableCalendarIds = [];
  String? calendarUseCalendarId;
  List<String> calendarHolidayCalendarIds = [];

  static CalendarConfigState copy(CalendarConfigState state) {
    var nState = CalendarConfigState();
    nState.calendarHolidayList = state.calendarHolidayList;
    nState.calendarHiddenMode = state.calendarHiddenMode;
    nState.calendarHiddenCalendarIds = state.calendarHiddenCalendarIds;
    nState.calendarBothCalendarIds = state.calendarBothCalendarIds;
    nState.calendarInvisibleCalendarIds = state.calendarInvisibleCalendarIds;
    nState.calendarNotEditableCalendarIds = state
        .calendarNotEditableCalendarIds;
    nState.calendarUseCalendarId = state.calendarUseCalendarId;
    nState.calendarHolidayCalendarIds = state.calendarHolidayCalendarIds;
    return nState;
  }
}

class CalendarConfigNotifier extends StateNotifier<CalendarConfigState> {
  final Ref ref;
  CalendarConfigNotifier(this.ref, CalendarConfigState state) : super(state);

  initState(
      String? calendarHolidayList,
      bool? calendarHiddenMode,
      String? calendarHiddenCalendarIds,
      String? calendarBothCalendarIds,
      String? calendarInvisibleCalendarIds,
      String? calendarNotEditableCalendarIds,
      String? calendarUseCalendarId,
      String? calendarHolidayCalendarIds) async {

    state.calendarHolidayList = calendarHolidayList
        ?.split(calendarConfigDelimiter)
        .map((value) => CalendarHoliday.values.where((holiday)=>holiday
        .value == value).first
    ).toList() ?? [CalendarHoliday.red, CalendarHoliday.none,
      CalendarHoliday.none, CalendarHoliday.none,
      CalendarHoliday.none, CalendarHoliday.none,
      CalendarHoliday.blue];
    state.calendarHiddenMode = calendarHiddenMode ?? false;
    state.calendarHiddenCalendarIds = calendarHiddenCalendarIds
        ?.split(calendarConfigDelimiter).toList() ?? [];
    state.calendarBothCalendarIds = calendarBothCalendarIds
        ?.split(calendarConfigDelimiter).toList() ?? [];
    state.calendarInvisibleCalendarIds = calendarInvisibleCalendarIds
        ?.split(calendarConfigDelimiter).toList() ?? [];
    state.calendarNotEditableCalendarIds = calendarNotEditableCalendarIds
        ?.split(calendarConfigDelimiter).toList() ?? [];
    state.calendarUseCalendarId = calendarUseCalendarId;
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
        .map((holiday)=>holiday.value).toList());
    await SharedPreferencesRepository().setString(
        SharedPreferenceKey.calendarHolidayList,
        sundayConfig
    );
  }

  Future<List<CalendarAndAdditionalInfo>> createCalendarAndAddInfoList(
      ) async {
    await CalendarRepository().hasPermissions();
    var calendars = await CalendarRepository().getCalendars();

    // debugPrint('カレンダー数 ${calendars.length}');
    // debugPrint('カレンダー一覧');
    // for (var cal in calendars) {
    //   debugPrint('name:${cal.name} isReadOnly:${cal.isReadOnly}'
    //       ' isDefault:${cal.isDefault} accountType:${cal.accountType}'
    //       ' accountName:${cal.accountName}');
    // }

    List<CalendarAndAdditionalInfo> calendarAndAddInfoList = [];
    for (int i=0; i < calendars.length; i++) {
      var calendar = calendars[i];

      calendarAndAddInfoList.add(
          CalendarAndAdditionalInfo(
            calendar: calendar,
            displayMode: getCalendarDisplayMode(calendar.id!),
            editingMode: getCalendarEditingMode(calendar.id!),
            useMode: getCalendarUseMode(calendars, calendar.id!),
            holidayDisplayMode: getCalendarHolidayDisplayMode(
                calendar.id!),
          )
      );
    }

    return calendarAndAddInfoList;
  }

  CalendarDisplayMode getCalendarDisplayMode(String calendarId) {
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
    List<String> calendarHiddenCalendarIds = [...state
        .calendarHiddenCalendarIds];
    List<String> calendarBothCalendarIds = [...state.calendarBothCalendarIds];
    List<String> calendarInvisibleCalendarIds = [...state
        .calendarInvisibleCalendarIds];

    var mode = getCalendarDisplayMode(calendarId);
    mode = modeList[(mode.index + 1) % modeList.length];

    calendarHiddenCalendarIds.remove(calendarId);
    calendarBothCalendarIds.remove(calendarId);
    calendarInvisibleCalendarIds.remove(calendarId);

    switch (mode) {
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
          SharedPreferenceKey.calendarHiddenCalendarIds,
          listToCalendarConfig(calendarHiddenCalendarIds)
      );
    }

    if (calendarBothCalendarIds != state.calendarBothCalendarIds) {
      state.calendarBothCalendarIds = calendarBothCalendarIds;
      await SharedPreferencesRepository().setString(
          SharedPreferenceKey.calendarBothCalendarIds,
          listToCalendarConfig(calendarBothCalendarIds)
      );
    }

    if (calendarInvisibleCalendarIds != state.calendarInvisibleCalendarIds) {
      state.calendarInvisibleCalendarIds = calendarInvisibleCalendarIds;
      await SharedPreferencesRepository().setString(
          SharedPreferenceKey.calendarInvisibleCalendarIds,
          listToCalendarConfig(calendarInvisibleCalendarIds)
      );
    }

    return mode;
  }

  CalendarEditingMode getCalendarEditingMode(String calendarId) {
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
    List<String> calendarNotEditableCalendarIds = [...state
        .calendarNotEditableCalendarIds];

    var mode = getCalendarEditingMode(calendarId);
    mode = modeList[(mode.index + 1) % modeList.length];

    calendarNotEditableCalendarIds.remove(calendarId);

    switch (mode) {
      case CalendarEditingMode.editable:
        break;
      case CalendarEditingMode.notEditable:
        calendarNotEditableCalendarIds.add(calendarId);
        break;
    }

    if (calendarNotEditableCalendarIds != state
        .calendarNotEditableCalendarIds) {
      state.calendarNotEditableCalendarIds = calendarNotEditableCalendarIds;
      await SharedPreferencesRepository().setString(
          SharedPreferenceKey.calendarNotEditableCalendarIds,
          listToCalendarConfig(calendarNotEditableCalendarIds)
      );
    }

    return mode;
  }

  String? getUseCalendarId(List<Calendar> calendars) {
    return calendars.map((calendar) => calendar.id)
        .where((id) => id == state.calendarUseCalendarId)
        .firstOrNull ?? getUseAbleCalendarId(calendars);
  }

  String? getUseAbleCalendarId(List<Calendar> calendars,
      {String? withoutCalendarId}) {
    return calendars.where((calendar) =>
      !calendar.isReadOnly! && (withoutCalendarId == null
          || calendar.id! != withoutCalendarId))
        .map((calendar) => calendar.id).firstOrNull;
  }

  CalendarUseMode getCalendarUseMode(List<Calendar> calendars,
      String calendarId) {

    return getUseCalendarId(calendars) == calendarId
        ? CalendarUseMode.use : CalendarUseMode.notUse;
  }

  Future<CalendarUseMode> switchCalendarUseMode(
    List<Calendar> calendars, String calendarId) async {

    var modeList = CalendarUseMode.values.toList();

    var mode = getCalendarUseMode(calendars, calendarId);
    mode = modeList[(mode.index + 1) % modeList.length];

    switch (mode) {
      case CalendarUseMode.use:
        state.calendarUseCalendarId = calendarId;
        break;
      case CalendarUseMode.notUse:
        state.calendarUseCalendarId = getUseAbleCalendarId(calendars,
            withoutCalendarId: calendarId);
        break;
    }

    await SharedPreferencesRepository().setString(
        SharedPreferenceKey.calendarHolidayCalendarIds,
        state.calendarUseCalendarId
    );

    return mode;
  }

  CalendarHolidayDisplayMode getCalendarHolidayDisplayMode(
      String calendarId) {
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
    List<String> calendarHolidayCalendarIds = [...state
        .calendarHolidayCalendarIds];

    var mode = getCalendarHolidayDisplayMode(calendarId);
    mode = modeList[(mode.index + 1) % modeList.length];

    calendarHolidayCalendarIds.remove(calendarId);

    switch (mode) {
      case CalendarHolidayDisplayMode.nonHolidayDisplay:
        break;
      case CalendarHolidayDisplayMode.holidayDisplay:
        calendarHolidayCalendarIds.add(calendarId);
        break;
    }

    if (calendarHolidayCalendarIds != state.calendarHolidayCalendarIds) {
      state.calendarHolidayCalendarIds = calendarHolidayCalendarIds;
      await SharedPreferencesRepository().setString(
          SharedPreferenceKey.calendarHolidayCalendarIds,
          listToCalendarConfig(calendarHolidayCalendarIds)
      );
    }

    return mode;
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