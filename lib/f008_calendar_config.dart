import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CalendarConfigState {
  // BrightnessMode? brightnessMode;


  static CalendarConfigState copy(CalendarConfigState state) {
    var nState = CalendarConfigState();
    return nState;
  }
}

class CalendarConfigNotifier extends StateNotifier<CalendarConfigState> {
  final Ref ref;
  CalendarConfigNotifier(this.ref, CalendarConfigState state) : super(state);

  initState() async {
    // state.brightnessMode = brightnessMode;
  }

  updateState() async {
    state = CalendarConfigState.copy(state);
    debugPrint('updateState(calendar config)');
  }
}

