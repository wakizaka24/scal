import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class HomePageState {
  // UI
  double appBarHeight = 39;
  PageController homePageController = PageController(initialPage: 1);

  // Data
  int homePageIndex = 1;
  String appBarTitle = '';

  static HomePageState copy(HomePageState state) {
    var nState = HomePageState();

    // UI
    nState.appBarHeight = state.appBarHeight;
    nState.homePageController = state.homePageController;

    // Data
    nState.homePageIndex = state.homePageIndex;
    nState.appBarTitle = state.appBarTitle;

    return nState;
  }
}

class HomePageNotifier extends StateNotifier<HomePageState> {
  final Ref ref;

  HomePageNotifier(this.ref, HomePageState state)
      : super(state);

  initState() async {
  }

  setHomePageIndex(int index) {
    state.homePageIndex = index;
    updateState();
  }

  setCurrentDay(DateTime date) {
    state.appBarTitle = DateFormat.yMMM('ja') // 2023年6月
        .format(date).toString();
    updateState();
  }

  updateState() async {
    state = HomePageState.copy(state);
  }
}

final homePageNotifierProvider = StateNotifierProvider
    .autoDispose<HomePageNotifier, HomePageState>((ref) {
  return HomePageNotifier(ref, HomePageState());
});