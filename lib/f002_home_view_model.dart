import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class HomePageState {
  // UI
  PageController homePageController = PageController(initialPage: 1);

  // Data
  int homePageIndex = 1;
  String appBarTitle = '';

  static HomePageState copy(HomePageState state) {
    var nState = HomePageState();

    // UI
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

  setAppBarTitle(DateTime date, bool update) {
    state.appBarTitle = DateFormat.yMMM('ja') // 2023年6月
        .format(date).toString();
    if (update) {
      updateState();
    }
  }

  updateState() async {
    state = HomePageState.copy(state);
  }
}

final homePageNotifierProvider = StateNotifierProvider
    .autoDispose<HomePageNotifier, HomePageState>((ref) {
  return HomePageNotifier(ref, HomePageState());
});