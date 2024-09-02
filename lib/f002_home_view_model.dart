import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import 'f017_design_config.dart';

class HomePageState {
  // Data
  String appBarTitle = '';
  bool uICover = false;
  Widget? uICoverWidget;
  String? brightnessModeAssetName;

  static HomePageState copy(HomePageState state) {
    var nState = HomePageState();

    // Data
    nState.appBarTitle = state.appBarTitle;
    nState.uICover = state.uICover;
    nState.uICoverWidget = state.uICoverWidget;
    nState.brightnessModeAssetName = state.brightnessModeAssetName;
    return nState;
  }
}

class HomePageNotifier extends StateNotifier<HomePageState> {
  final Ref ref;

  HomePageNotifier(this.ref, HomePageState state)
      : super(state);

  initState() async {
    final designConfigState = ref.read(designConfigNotifierProvider);
    setBrightnessMode(designConfigState.brightnessMode!);
  }

  setBrightnessMode(BrightnessMode brightnessMode) {
    state.brightnessModeAssetName = getBrightnessModeAssetName(
        brightnessMode);
  }

  getBrightnessModeAssetName(BrightnessMode brightnessMode) {
    switch(brightnessMode) {
      case BrightnessMode.lightAndDark:
        return 'images/icon_light_and_dark@3x.png';
      case BrightnessMode.light:
        return 'images/icon_bright@3x.png';
      case BrightnessMode.dark:
        return 'images/icon_dark@3x.png';
    }
  }

  setAppBarTitle(DateTime date, bool update) async {
    state.appBarTitle = DateFormat.yMMM('ja') // 2023年6月
        .format(date).toString();
    if (update) {
      updateState();
    }
  }

  setUICover(bool cover) async {
    state.uICover = cover;
  }

  setUICoverWidget(Widget? widget) async {
    state.uICoverWidget = widget;
  }

  updateState() async {
    state = HomePageState.copy(state);
    debugPrint('updateState(home)');
  }
}

final homePageNotifierProvider = StateNotifierProvider
    .autoDispose<HomePageNotifier, HomePageState>((ref) {
  return HomePageNotifier(ref, HomePageState());
});