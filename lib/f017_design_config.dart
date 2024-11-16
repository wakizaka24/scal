import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scal/f006_shared_preferences_repository.dart';

const double selectedBoarderWidth = 2;
const double eventSelectedBoarderWidth = 2;
const double normalBoarderWidth = 0.3;
const double calendarDayFontSize = 12.5;
const double calendarEventFontSize = 8;
const double eventListTitleFontSize = 13;
const double eventListItemFontSize = 13;
const double buttonFontSize = 13;
const double eventListBottomSafeArea = 56;
const double drawerMenuFontSize = 15;
const double drawerWeekButtonFontSize = 13;
const double drawerSettingTitleFontSize = 13.5;
const double drawerSettingItemFontSize = 11;

MaterialColor createMaterialColor(Color primary) {
  List<double> strengths = [.05];
  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }

  Map<int, Color> swatch = {};
  for (var strength in strengths) {
    double rate = 0.5 - strength;
    var addValue = ((int value, double rate) {
      return ((rate < 0 ? value : (255 - value)) * rate).round();
    });
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      primary.red + addValue(primary.red, rate),
      primary.green + addValue(primary.green, rate),
      primary.blue + addValue(primary.blue, rate),
      1,
    );
  }
  return MaterialColor(primary.value, swatch);
}

abstract final class BackgroundColors {
  static const Color white = Colors.white;
  static const Color darkModeGrey = Color(0xFF313131);
}

abstract final class BorderColors {
  static const Color green = Color(0xFFB9F6CA);
  static const Color pink = Color(0xFFFFCCD4);
  static const Color indigo = Color(0xFFC4DDFF);
  static const Color darkModeGrey = Color(0xFF212121);
}

abstract final class CardColors {
  static const Color cream = Color(0xFFF8F5EB);
  static const Color darkModeBlack = Colors.black26;
}

enum BrightnessMode implements SharedPreferenceStringValue {
  lightAndDark('lightAndDark'),
  light('light'),
  dark('dark');
  @override
  final String configValue;
  const BrightnessMode(this.configValue);
}

enum ColorConfig implements SharedPreferenceStringValue {
  normal15White(
      'normal15Green',
      true, // useMaterial3
      Brightness.light, // brightness
      Colors.greenAccent, // primaryColor
      Color(0xFF00C853), // accentColor
      BackgroundColors.white, // backgroundColor
      CardColors.cream, // cardColor
      Colors.black, // normalTextColor
      Colors.black54, // disabledTextColor
      BorderColors.green, // borderColor
      80, // calendarTodayBgColorAlpha
      50, // calendarLineBgColorAlpha
      135, // highlightBgColorAlpha
      Colors.black // cardTextColor
  ),
  normal35Pink(
      'normal35Pink',
      true, // useMaterial3
      Brightness.light, // brightness
      Color(0xFFFFB6C1), // primaryColor
      Color(0xFFFFA6B3), // accentColor
      BackgroundColors.white, // backgroundColor
      CardColors.cream, // cardColor
      Colors.black, // normalTextColor
      Colors.black54, // disabledTextColor
      BorderColors.pink, // borderColor
      80, // calendarTodayBgColorAlpha
      50, // calendarLineBgColorAlpha
      135, // highlightBgColorAlpha
      Colors.black // cardTextColor
  ),
  normal17LightBlue(
      'normal17LightBlue',
      true, // useMaterial3
      Brightness.light, // brightness
      Color(0xFFAAC4FF), // primaryColor
      Color(0xFF99B6FF), // accentColor
      BackgroundColors.white, // backgroundColor
      CardColors.cream, // cardColor
      Colors.black, // normalTextColor
      Colors.black54, // disabledTextColor
      BorderColors.indigo, // borderColor
      80, // calendarTodayBgColorAlpha
      50, // calendarLineBgColorAlpha
      95, // highlightBgColorAlpha
      Colors.black // cardTextColor
  ),
  dark11Gray(
      'dark11Gray',
      true, // useMaterial3
      Brightness.dark, // brightness
      Color(0xFFC8C8C8), // primaryColor
      Color(0xFFC8C8C8), // accentColor
      BackgroundColors.darkModeGrey, // backgroundColor
      CardColors.darkModeBlack, // cardColor
      Colors.white54, // normalTextColor
      Colors.white30, // disabledTextColor
      BorderColors.darkModeGrey, // borderColor
      135, // calendarTodayBgColorAlpha
      80, // calendarLineBgColorAlpha
      135, // highlightBgColorAlpha
      Colors.white // cardTextColor
  );

  @override
  final String configValue;
  final bool useMaterial3;
  final Brightness brightness;
  final Color primaryColor;
  final Color accentColor;
  final Color? cardColor;
  final Color? backgroundColor;
  final Color normalTextColor;
  final Color disabledTextColor;
  final Color borderColor;
  final int calendarTodayBgColorAlpha;
  final int calendarLineBgColorAlpha;
  final int highlightBgColorAlpha;
  final Color cardTextColor;

  const ColorConfig(
      this.configValue,
      this.useMaterial3,
      this.brightness,
      this.primaryColor,
      this.accentColor,
      this.backgroundColor,
      this.cardColor,
      this.normalTextColor,
      this.disabledTextColor,
      this.borderColor,
      this.calendarTodayBgColorAlpha,
      this.calendarLineBgColorAlpha,
      this.highlightBgColorAlpha,
      this.cardTextColor);
}

class DesignConfigState {
  BrightnessMode? brightnessMode;
  Brightness? brightness;
  ColorConfig? colorConfig;
  ColorConfig? preColorConfig;
  ColorConfig? lightColorConfig;
  ColorConfig? darkColorConfig;

  static DesignConfigState copy(DesignConfigState state) {
    var nState = DesignConfigState();
    nState.brightnessMode = state.brightnessMode;
    nState.brightness = state.brightness;
    nState.colorConfig = state.colorConfig;
    nState.preColorConfig = state.preColorConfig;
    nState.lightColorConfig = state.lightColorConfig;
    nState.darkColorConfig = state.darkColorConfig;
    return nState;
  }
}

class DesignConfigNotifier extends StateNotifier<DesignConfigState> {
  final Ref ref;
  DesignConfigNotifier(this.ref, DesignConfigState state) : super(state);

  ColorConfig initState(BrightnessMode? brightnessMode, Brightness brightness,
      ColorConfig? lightColorConfig, ColorConfig? darkColorConfig) {
    state.brightnessMode = brightnessMode;
    state.brightness = brightness;
    state.lightColorConfig = lightColorConfig;
    state.darkColorConfig = darkColorConfig;
    confirmColorConfig();
    return state.colorConfig!;
  }

  bool applyColorConfig(Brightness brightness) {
    state.brightness = brightness;
    if (state.brightnessMode == null) {
      return false;
    }
    confirmColorConfig();
    if (state.preColorConfig == state.colorConfig) {
      return false;
    }
    state.preColorConfig = state.colorConfig;
    return true;
  }

  bool switchBrightnessMode() {
    var brightnessMode = state.brightnessMode!;
    var modes = BrightnessMode.values;
    state.brightnessMode = modes[(brightnessMode.index + 1) % modes.length];
    SharedPreferencesRepository().setStringEnum(
        SharedPreferenceKey.brightnessMode, state.brightnessMode);
    confirmColorConfig();
    if (state.preColorConfig == state.colorConfig) {
      return false;
    }
    state.preColorConfig = state.colorConfig;
    return true;
  }

  confirmColorConfig() {
    if (state.brightness == Brightness.light
        && state.brightnessMode == BrightnessMode.lightAndDark
        || state.brightnessMode == BrightnessMode.light) {
      if (state.colorConfig != state.lightColorConfig) {
        state.colorConfig = state.lightColorConfig!;
      }
    }

    if (state.brightness == Brightness.dark
        && state.brightnessMode == BrightnessMode.lightAndDark
        || state.brightnessMode == BrightnessMode.dark) {
      if (state.colorConfig != state.darkColorConfig) {
        state.colorConfig = state.darkColorConfig!;
      }
    }
  }

  bool switchColorConfig() {
    // var index = (state.colorConfig!.index + 1) % ColorConfig.values.length;
    // state.colorConfig = ColorConfig.values[index];

    ColorConfig config = state.colorConfig!;
    BrightnessMode mode = state.brightnessMode!;
    Brightness brightness = state.brightness!;

    var num = ColorConfig.values.length;
    var i = (config.index + 1) % num;
    while (i != config.index) {
      var nextConfig = ColorConfig.values[i];
      if (mode == BrightnessMode.lightAndDark
          && brightness == Brightness.light
          && nextConfig.brightness == Brightness.light
          || mode == BrightnessMode.light
              && nextConfig.brightness == Brightness.light
      ) {
        SharedPreferencesRepository().setStringEnum(
            SharedPreferenceKey.lightColorMode, nextConfig);
        state.lightColorConfig = nextConfig;
        state.colorConfig = nextConfig;
        return config != nextConfig;
      }

      if (mode == BrightnessMode.lightAndDark
          && brightness == Brightness.dark
          && nextConfig.brightness == Brightness.dark
          || mode == BrightnessMode.dark
              && nextConfig.brightness == Brightness.dark
      ) {
        SharedPreferencesRepository().setStringEnum(
            SharedPreferenceKey.darkColorMode, nextConfig);
        state.lightColorConfig = nextConfig;
        state.colorConfig = nextConfig;
        return config != nextConfig;
      }

      i = (i + 1) % num;
    }
    return false;
  }

  List<ColorConfig> getColorConfigs() {
    switch (state.brightnessMode!) {
      case BrightnessMode.lightAndDark:
        return ColorConfig.values.where((config) {
          return config.brightness == state.brightness;
        }).toList();
      case BrightnessMode.light:
        return ColorConfig.values.where((config) {
          return config.brightness == Brightness.light;
        }).toList();
      case BrightnessMode.dark:
        return ColorConfig.values.where((config) {
          return config.brightness == Brightness.dark;
        }).toList();
    }
  }

  updateState() async {
    state = DesignConfigState.copy(state);
    debugPrint('updateState(design config)');
  }
}

final designConfigNotifierProvider = StateNotifierProvider
    .autoDispose<DesignConfigNotifier, DesignConfigState>((ref) {
  var state = DesignConfigState();
  return DesignConfigNotifier(ref, state);
});