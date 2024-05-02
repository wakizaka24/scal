import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'f002_home_view_model.dart';

enum EventDetailPageContentsMode {
  simpleInput,
  detailInput;
}

class EventDetailPageState {
  // Data
  double? deviceHeight;
  double? contentsHeight;
  EventDetailPageContentsMode contentsMode
    = EventDetailPageContentsMode.simpleInput;

  static EventDetailPageState copy(EventDetailPageState state) {
    var nState = EventDetailPageState();
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

  setDeviceHeight(double deviceHeight) async {
    state.deviceHeight = deviceHeight;
    state.contentsHeight = await getContentsHeight();
  }

  setContentsMode(EventDetailPageContentsMode contentsMode) async {
    final homeNotifier = ref.read(homePageNotifierProvider.notifier);

    state.contentsMode = contentsMode;
    state.contentsHeight = await getContentsHeight();
    updateState();

    await homeNotifier.setUICoverWidgetHeight(state.deviceHeight!,
        state.contentsHeight!);
    await homeNotifier.updateState();
  }

  Future<double> getContentsHeight() async {
    switch (state.contentsMode) {
      case EventDetailPageContentsMode.simpleInput:
        return 700 + 400;
      case EventDetailPageContentsMode.detailInput:
        return state.deviceHeight! + 700;
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
