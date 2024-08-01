import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class HomePageState {
  // Data
  String appBarTitle = '';
  bool uICover = false;
  Widget? uICoverWidget;

  static HomePageState copy(HomePageState state) {
    var nState = HomePageState();

    // Data
    nState.appBarTitle = state.appBarTitle;
    nState.uICover = state.uICover;
    nState.uICoverWidget = state.uICoverWidget;
    return nState;
  }
}

class HomePageNotifier extends StateNotifier<HomePageState> {
  final Ref ref;

  HomePageNotifier(this.ref, HomePageState state)
      : super(state);

  initState() async {
  }

  setHomePageIndex(int index) async {
    updateState();
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