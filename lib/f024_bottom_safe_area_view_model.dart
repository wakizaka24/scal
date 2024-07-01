import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BottomSafeAreaViewState {
  // Control
  ScrollController? keyboardScrollController;

  // Data
  double safeAreaAdjustment = 0;
  double safeAreaHeight = 0;

  static BottomSafeAreaViewState copy(BottomSafeAreaViewState state) {
    var nState = BottomSafeAreaViewState();

    // Control
    nState.keyboardScrollController = state.keyboardScrollController;

    // Data
    nState.safeAreaAdjustment = state.safeAreaAdjustment;
    nState.safeAreaHeight = state.safeAreaHeight;

    return nState;
  }
}

class BottomSafeAreaViewNotifier extends StateNotifier<BottomSafeAreaViewState> {
  final Ref ref;

  BottomSafeAreaViewNotifier(this.ref, BottomSafeAreaViewState state)
      : super(state);

  initState() async {
  }

  setSafeAreaAdjustment(double addingOffset) async {
    state.safeAreaAdjustment = addingOffset;
  }

  setSafeAreaHeight(double height) async {
    state.safeAreaHeight = height;
  }

  updateState() async {
    state = BottomSafeAreaViewState.copy(state);
  }
}

final bottomSafeAreaViewNotifierProvider = StateNotifierProvider
    .autoDispose<BottomSafeAreaViewNotifier,
    BottomSafeAreaViewState>((ref) {
  return BottomSafeAreaViewNotifier(ref, BottomSafeAreaViewState());
});