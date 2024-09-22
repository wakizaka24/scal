import 'package:shared_preferences/shared_preferences.dart';

enum SharedPreferenceStringKey {
  brightnessMode('brightnessMode'),
  lightColorMode('lightColorMode'),
  darkColorMode('darkColorMode'),
  calendarHolidayList('calendarHolidayList'),
  calendarHiddenCalendarIds('calendarHiddenCalendarIds'),
  calendarBothCalendarIds('calendarBothCalendarIds'),
  calendarInvisibleCalendarIds('calendarInvisibleCalendarIds'),
  calendarNotEditableCalendarIds('calendarNotEditableCalendarIds'),
  calendarHolidayCalendarIds('calendarHolidayCalendarIds'),

  ;

  final String id;
  const SharedPreferenceStringKey(this.id);
}

abstract interface class SharedPreferenceStringValue implements Enum {
  final String configValue;
  const SharedPreferenceStringValue(this.configValue);
}

enum SharedPreferenceStringListKey {
  calendarHolidaySundayConfig('calendarHolidaySundayConfig');
  final String id;
  const SharedPreferenceStringListKey(this.id);
}

class SharedPreferencesRepository {
  static final SharedPreferencesRepository _instance
  = SharedPreferencesRepository._internal();
  SharedPreferencesRepository._internal();

  factory SharedPreferencesRepository() {
    return _instance;
  }

  Future<bool> clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.clear();
  }

  Future<bool> setStringEnum<T extends SharedPreferenceStringValue>(
      SharedPreferenceStringKey key, T? value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value != null) {
      return await prefs.setString(key.id, value.configValue);
    } else {
      return await prefs.remove(key.id);
    }
  }

  Future<T?> getStringEnum<T extends SharedPreferenceStringValue>(
      SharedPreferenceStringKey key, List<T> values) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(key.id);
    if (id == null) {
      return null;
    } else {
      var list = values.where((value) {
        return value.configValue == id;
      }).toList();
      return list.isEmpty ? null : list.first;
    }
  }

  Future<bool> setString(SharedPreferenceStringKey key, String? value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value != null) {
      return await prefs.setString(key.id, value);
    } else {
      return await prefs.remove(key.id);
    }
  }

  Future<String?> getString(SharedPreferenceStringKey key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key.id);
  }
}