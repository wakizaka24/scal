import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'f017_design_config.dart';

class WeekdayDisplay {
  String title;
  Color titleColor;

  WeekdayDisplay({
    required this.title,
    required this.titleColor
  });
}

class EndDrawerPageState {
  List<WeekdayDisplay> weekdayList = [];

  static EndDrawerPageState copy(EndDrawerPageState state) {
    var nState = EndDrawerPageState();
    nState.weekdayList = state.weekdayList;
    return nState;
  }
}

class EndDrawerPageNotifier extends StateNotifier<EndDrawerPageState> {
  final Ref ref;

  EndDrawerPageNotifier(this.ref, EndDrawerPageState state)
      : super(state);

  initState() async {
    state.weekdayList = createWeekdayList();
  }

  List<WeekdayDisplay> createWeekdayList() {
    var normalTextColor = ref.read(designConfigNotifierProvider).colorConfig!
        .normalTextColor;
    return [
      WeekdayDisplay(title: '日',
          titleColor: Colors.pink),
      WeekdayDisplay(title: '月',
          titleColor: normalTextColor),
      WeekdayDisplay(title: '火',
          titleColor: normalTextColor),
      WeekdayDisplay(title: '水',
          titleColor: normalTextColor),
      WeekdayDisplay(title: '木',
          titleColor: normalTextColor),
      WeekdayDisplay(title: '金',
          titleColor: normalTextColor),
      WeekdayDisplay(title: '土',
          titleColor: Colors.blueAccent),
    ];
  }

  updateState() async {
    state = EndDrawerPageState.copy(state);
    debugPrint('updateState(end_drawer)');
  }
}

final endDrawerPageNotifierProvider = StateNotifierProvider
    .autoDispose<EndDrawerPageNotifier, EndDrawerPageState>((ref) {
  return EndDrawerPageNotifier(ref, EndDrawerPageState());
});