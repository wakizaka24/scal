import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class KeyboardSafeAreaViewState {
  // Control
  ScrollController? keyboardScrollController;

  // Data
  double keyboardAdjustment = 0;

  static KeyboardSafeAreaViewState copy(KeyboardSafeAreaViewState state) {
    var nState = KeyboardSafeAreaViewState();

    // Control
    nState.keyboardScrollController = state.keyboardScrollController;

    // Data
    nState.keyboardAdjustment = state.keyboardAdjustment;

    return nState;
  }
}

class KeyboardSafeAreaViewNotifier extends StateNotifier<KeyboardSafeAreaViewState> {
  final Ref ref;

  KeyboardSafeAreaViewNotifier(this.ref, KeyboardSafeAreaViewState state)
      : super(state);

  initState() async {
  }

  setKeyboardAdjustment(double addingOffset) async {
    state.keyboardAdjustment = addingOffset;
  }

  updateState() async {
    state = KeyboardSafeAreaViewState.copy(state);
  }
}

final keyboardSafeAreaViewNotifierProvider = StateNotifierProvider
    .autoDispose<KeyboardSafeAreaViewNotifier,
    KeyboardSafeAreaViewState>((ref) {
  return KeyboardSafeAreaViewNotifier(ref, KeyboardSafeAreaViewState());
});