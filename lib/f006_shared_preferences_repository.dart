import 'package:shared_preferences/shared_preferences.dart';
import 'f016_design_config.dart';

enum SharedPreferenceKey {
  brightnessMode('brightnessMode'),
  colorConfig('colorConfig'),
  lightColorConfig('lightColorConfig'),
  darkColorConfig('darkColorConfig'),



  ;
  final String id;
  const SharedPreferenceKey(this.id);
}

abstract interface class SharedPreferenceStringValue implements Enum {
  final String id;
  const SharedPreferenceStringValue(this.id);
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
      return await prefs.setString(key.id, value.id);
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
      var list = values.where((mode) {
        return mode.id == id;
      }).toList();
      return list.isEmpty ? null : list.first;
    }
  }

  /*
        await SharedPreferencesRepository().setStringEnum(
        SharedPreferenceKey.brightnessMode, BrightnessMode.light);

      var a = await SharedPreferencesRepository().getStringEnum(
          BrightnessMode.values,
          SharedPreferenceKey.brightnessMode);

      await SharedPreferencesRepository().setStringEnum(
          SharedPreferenceKey.brightnessMode, null);

      var b = await SharedPreferencesRepository().getStringEnum(
          BrightnessMode.values,
          SharedPreferenceKey.brightnessMode);
   */
}