import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const double selectedBoarderWidth = 2;
const double eventSelectedBoarderWidth = 2;
const double normalBoarderWidth = 0.3;
const double calendarFontSize1 = 13;
const double calendarFontSize1Down1 = 11.5;
const FontWeight calendarFontWidth1 = FontWeight.w600;
const double calendarFontSize2 = 10;
const FontWeight calendarFontWidth2 = FontWeight.w600;
const double eventListFontSize1 = 13.5;
const FontWeight eventListFontWidth1 = FontWeight.w600;
const double eventListFontSize2 = 13;
const FontWeight eventListFontWidth2 = FontWeight.w600;
const double eventListFontSize3 = 13;
const FontWeight eventListFontWidth3 = FontWeight.w600;
const double eventListBottomSafeArea = 56;

enum ColorConfig {
    // normal01OfMaterial2(
    //     false, // useMaterial3
    //     Brightness.light, // brightness
    //     Colors.purple, // primarySwatch
    //     Colors.blue, // accentColor
    //     null, // cardColor
    //     null, // backgroundColor
    //     Colors.black, // normalTextColor
    //     Color(0xffaaaaaa), // disabledTextColor
    //     Color(0xCCDED2BF), // eventListTitleBgColor
    //     Colors.white// cardTextColor
    // ),
    // dark01OfMaterial2(
    //     false, // useMaterial3
    //     Brightness.dark, // brightness
    //     Colors.purple, // primarySwatch
    //     Colors.blue, // accentColor
    //     null, // cardColor
    //     null, // backgroundColor
    //     Colors.white54, // normalTextColor
    //     Colors.white30, // disabledTextColor
    //     Colors.black, // eventListTitleBgColor
    //     Colors.white// cardTextColor
    // ),
    normal03OfMaterial3(
        true, // useMaterial3
        Brightness.light, // brightness
        Colors.blue, // primarySwatch
        Colors.blue, // accentColor
        Color(0xFFE5E5E5), // cardColor
        Colors.white, // backgroundColor
        Colors.black, // normalTextColor
        Colors.black54, // disabledTextColor
        Color(0xCCDED2BF), // eventListTitleBgColor
        Colors.black // cardTextColor
    ),
    dark02OfMaterial3(
        true, // useMaterial3
        Brightness.dark, // brightness
        Colors.blue, // primarySwatch
        Colors.blue, // accentColor
        Colors.black54, // cardColor
        Color(0xFF313131), // backgroundColor
        Colors.white54, // normalTextColor
        Colors.white30, // disabledTextColor
        Colors.black54, // eventListTitleBgColor
        Colors.white// cardTextColor
    ),
    dark03OfMaterial3(
        true, // useMaterial3
        Brightness.dark, // brightness
        Colors.blue, // primarySwatch
        Colors.blue, // accentColor
        Colors.black, // cardColor
        null, // backgroundColor
        Colors.white54, // normalTextColor
        Colors.white30, // disabledTextColor
        Colors.black54, // eventListTitleBgColor
        Colors.white// cardTextColor
    );

    const ColorConfig(
        this.useMaterial3,
        this.brightness,
        this.primarySwatch,
        this.accentColor,
        this.cardColor,
        this.backgroundColor,
        this.normalTextColor,
        this.disabledTextColor,
        this.eventListTitleBgColor,
        this.cardTextColor,
        );

    final bool useMaterial3;
    final Brightness brightness;
    final MaterialColor primarySwatch;
    final Color accentColor;
    final Color? cardColor;
    final Color? backgroundColor;
    final Color normalTextColor;
    final Color disabledTextColor;
    final Color eventListTitleBgColor;
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
            state.colorConfig = ColorConfig.normal03OfMaterial3;
        } else if (brightness == Brightness.dark) {
            state.colorConfig = ColorConfig.dark02OfMaterial3;
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