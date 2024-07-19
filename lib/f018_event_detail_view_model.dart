import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'f002_home_view_model.dart';

enum EventDetailPageContentsMode {
  simpleInput,
  detailInput;
}

class EventDetailPageState {
  // Control
  GlobalKey contentsKey = GlobalKey();

  // Data
  double? deviceHeight;
  double? contentsHeight = 809;
  EventDetailPageContentsMode contentsMode
    = EventDetailPageContentsMode.detailInput;

  static EventDetailPageState copy(EventDetailPageState state) {
    var nState = EventDetailPageState();
    nState.contentsKey = state.contentsKey;
    nState.deviceHeight = state.deviceHeight;
    nState.contentsHeight = state.contentsHeight;
    nState.contentsMode = state.contentsMode;
    return nState;
  }
}

class EventDetailPageNotifier extends StateNotifier<EventDetailPageState> {
  final Ref ref;

  EventDetailPageNotifier(this.ref, EventDetailPageState state)
      : super(state);

  initState() async {

  }

  // setDeviceHeight(double deviceHeight) async {
  //   state.deviceHeight = deviceHeight;
  //   state.contentsHeight = await getContentsHeight();
  // }

  // setContentsHeight(double contentsHeight) async {
  //   state.contentsHeight = contentsHeight;
  // }

  setContentsMode(EventDetailPageContentsMode contentsMode) async {
    state.contentsMode = contentsMode;
    state.contentsHeight = await getContentsHeight();
    updateState();
  }

  Future<double> getContentsHeight() async {
    switch (state.contentsMode) {
      case EventDetailPageContentsMode.simpleInput:
        return 670;
      case EventDetailPageContentsMode.detailInput:
        return 809;
    }
  }

  updateState() async {
    state = EventDetailPageState.copy(state);
  }
}

final eventDetailPageNotifierProvider = StateNotifierProvider
    .autoDispose<EventDetailPageNotifier, EventDetailPageState>((ref) {
  return EventDetailPageNotifier(ref, EventDetailPageState());
});
