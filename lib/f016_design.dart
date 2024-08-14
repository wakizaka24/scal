import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const FontWeight appBarTitleFontWeight = FontWeight.w400;
const double selectedBoarderWidth = 2;
const double eventSelectedBoarderWidth = 2;
const double normalBoarderWidth = 0.3;
const double calendarFontSize1 = 13;
const double calendarFontSize1Down1 = 11.5;
const FontWeight calendarFontWeight1 = FontWeight.w300;
const double calendarFontSize2 = 10;
const FontWeight calendarFontWeight2 = FontWeight.w400;
const double eventListFontSize1 = 13.5;
const FontWeight eventListFontWeight1 = FontWeight.w300;
const double eventListFontSize2 = 13;
const FontWeight eventListFontWeight2 = FontWeight.w400;
const double eventListFontSize3 = 13;
const FontWeight eventListFontWeight3 = FontWeight.w400;
const double buttonFontSize = 13;
const FontWeight buttonFontWeight = FontWeight.w300;
const FontWeight dialogFontWeight = FontWeight.w300;
const double eventListBottomSafeArea = 56;

const MaterialColor originalLightPink = MaterialColor(
    _originalLightPinkPrimary,
    {
      50: Color(0xFFFFF6F8),
      100: Color(0xFFFFE9EC),
      200: Color(0xFFFFDBE0),
      300: Color(0xFFFFCCD4),
      400: Color(0xFFFFC1CA),
      500: Color(_originalLightPinkPrimary),
      600: Color(0xFFFFAFBB),
      700: Color(0xFFFFA6B3),
      800: Color(0xFFFF9EAB),
      900: Color(0xFFFF8E9E),
    });
const int _originalLightPinkPrimary = 0xFFFFB6C1;

const MaterialColor originalLightBlue = MaterialColor(
    _originalLightBluePrimary,
    {
      50: Color(0xFFF5F8FF),
      100: Color(0xFFE6EDFF),
      200: Color(0xFFD5E2FF),
      300: Color(0xFFC4D6FF),
      400: Color(0xFFB7CDFF),
      500: Color(_originalLightBluePrimary),
      600: Color(0xFFA3BEFF),
      700: Color(0xFF99B6FF),
      800: Color(0xFF90AFFF),
      900: Color(0xFF7FA2FF),
});
const int _originalLightBluePrimary = 0xFFAAC4FF;

const MaterialColor originalBrown = MaterialColor(
    _originalBrownPrimary, <int, Color>{
      50: Color(0xFFF7F6F5),
      100: Color(0xFFECE8E6),
      200: Color(0xFFDFD9D6),
      300: Color(0xFFD2C9C6),
      400: Color(0xFFC8BEB9),
      500: Color(_originalBrownPrimary),
      600: Color(0xFFB8ABA6),
      700: Color(0xFFAFA29C),
      800: Color(0xFFA79993),
      900: Color(0xFF998A83),
});
const int _originalBrownPrimary = 0xFFBEB2AD;

const MaterialColor originalLightGray = MaterialColor(
    _originalLightGrayPrimary, <int, Color>{
      50: Color(0xFFF2F2F2),
      100: Color(0xFFDEDEDE),
      200: Color(0xFFC8C8C8),
      300: Color(0xFFB1B1B1),
      400: Color(0xFFA1A1A1),
      500: Color(_originalLightGrayPrimary),
      600: Color(0xFF888888),
      700: Color(0xFF7D7D7D),
      800: Color(0xFF737373),
      900: Color(0xFF616161),
});
const int _originalLightGrayPrimary = 0xFF909090;

abstract final class BackgroundColors {
    static const Color extraLightGrey = Color(0xFFD3D3D3);
    static const Color cream = Color(0xFFF3ECD8);
    static const Color cream3 = Color(0xFFEAE1CF);
    static const Color darkModeGrey = Color(0xFF313131);
}

abstract final class BorderColors {
    static const Color gold = Color(0xCCC4B8A5);
    static const Color pink = Color(0xFFFFCCD4);
    static const Color indigo = Color(0xFFC4DDFF);
    static const Color darkModeGrey = Color(0xFF212121);
}

abstract final class CardColors {
    static const Color grey = Color(0xFFE5E5E5);
    static const Color cream = Color(0xFFF8F5EB);
    static const Color darkModeBlack = Colors.black26;
}

enum ColorConfig {
    normal15Brown(
        'normal15Brown',
        true, // useMaterial3
        Brightness.light, // brightness
        originalBrown, // primarySwatch
        Color(0xFFAFA29C), // accentColor
        BackgroundColors.extraLightGrey, // backgroundColor
        CardColors.grey, // cardColor
        Colors.black, // normalTextColor
        Colors.black54, // disabledTextColor
        BorderColors.gold, // borderColor
        80, // calendarTodayBgColorAlpha
        50, // calendarLineBgColorAlpha
        135, // highlightBgColorAlpha
        Colors.black // cardTextColor
    ),
    normal35Pink(
        'normal35Pink',
        true, // useMaterial3
        Brightness.light, // brightness
        originalLightPink, // primarySwatch
        Color(0xFFFFA6B3), // accentColor
        BackgroundColors.cream, // backgroundColor
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
        originalLightBlue, // primarySwatch
        Color(0xFF99B6FF), // accentColor
        BackgroundColors.cream3, // backgroundColor
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
        originalLightGray, // primarySwatch
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

    const ColorConfig(
        this.name,
        this.useMaterial3,
        this.brightness,
        this.primarySwatch,
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

    final String name;
    final bool useMaterial3;
    final Brightness brightness;
    final MaterialColor primarySwatch;
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

}

class DesignConfigState {
    ColorConfig? colorConfig;

    static DesignConfigState copy(DesignConfigState state) {
        var nState = DesignConfigState();
        nState.colorConfig = state.colorConfig;
        return nState;
    }
}

class DesignConfigNotifier extends StateNotifier<DesignConfigState> {
    final Ref ref;
    DesignConfigNotifier(this.ref, DesignConfigState state) : super(state);

    bool applyColorConfig(Brightness brightness) {
        var preColorConfig = state.colorConfig;
        if (brightness == Brightness.light) {
            state.colorConfig = ColorConfig.normal15Brown;
        } else if (brightness == Brightness.dark) {
            state.colorConfig = ColorConfig.dark11Gray;
        }
        return preColorConfig != state.colorConfig;
    }

    switchColorConfig() async {
        var index = (state.colorConfig!.index + 1) % ColorConfig.values.length;
        state.colorConfig = ColorConfig.values[index];
    }

    updateState() async {
        state = DesignConfigState.copy(state);
        debugPrint('updateState(DesignConfigState)!!');
    }
}

final designConfigNotifierProvider = StateNotifierProvider
    .autoDispose<DesignConfigNotifier, DesignConfigState>((ref) {
    return DesignConfigNotifier(ref, DesignConfigState());
});