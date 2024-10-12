import 'package:shared_preferences/shared_preferences.dart';

enum SharedPreferenceKey {
  brightnessMode('brightnessMode'),
  lightColorMode('lightColorMode'),
  darkColorMode('darkColorMode'),
  initCalendarConfig('initCalendarConfig'),
  calendarHolidayList('calendarHolidayList'),
  calendarHiddenCalendarIds('calendarHiddenCalendarIds'),
  calendarBothCalendarIds('calendarBothCalendarIds'),
  calendarInvisibleCalendarIds('calendarInvisibleCalendarIds'),
  calendarNotEditableCalendarIds('calendarNotEditableCalendarIds'),
  calendarUseCalendarId('calendarUseCalendarId'),
  calendarHolidayCalendarIds('calendarHolidayCalendarIds'),
  ;

  final String id;
  const SharedPreferenceKey(this.id);
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
      SharedPreferenceKey key, T? value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value != null) {
      return await prefs.setString(key.id, value.configValue);
    } else {
      return await prefs.remove(key.id);
    }
  }

  Future<T?> getStringEnum<T extends SharedPreferenceStringValue>(
      SharedPreferenceKey key, List<T> values) async {
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

  Future<bool> setBool(SharedPreferenceKey key, bool? value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value != null) {
      return await prefs.setBool(key.id, value);
    } else {
      return await prefs.remove(key.id);
    }
  }

  Future<bool?> getBool(SharedPreferenceKey key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key.id);
  }

  Future<bool> setString(SharedPreferenceKey key, String? value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value != null) {
      return await prefs.setString(key.id, value);
    } else {
      return await prefs.remove(key.id);
    }
  }

  Future<String?> getString(SharedPreferenceKey key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key.id);
  }
}