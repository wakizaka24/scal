import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BottomSafeAreaViewState {
  // Control
  ScrollController? keyboardScrollController;
  BuildContext? bottomSheetContext;

  // Data
  double safeAreaAdjustment = 0;
  double safeAreaHeight = 0;
  bool forceScroll = false;

  static BottomSafeAreaViewState copy(BottomSafeAreaViewState state) {
    var nState = BottomSafeAreaViewState();

    // Control
    nState.keyboardScrollController = state.keyboardScrollController;
    nState.bottomSheetContext = state.bottomSheetContext;

    // Data
    nState.safeAreaAdjustment = state.safeAreaAdjustment;
    nState.safeAreaHeight = state.safeAreaHeight;
    nState.forceScroll = state.forceScroll;

    return nState;
  }
}

class BottomSafeAreaViewNotifier extends StateNotifier<BottomSafeAreaViewState> {
  final Ref ref;

  BottomSafeAreaViewNotifier(this.ref, BottomSafeAreaViewState state)
      : super(state);

  initState() async {
    state.keyboardScrollController = ScrollController();
  }

  @override
  dispose() {
    state.keyboardScrollController!.dispose();
    super.dispose();
  }

  setSafeAreaAdjustment(double addingOffset) async {
    state.safeAreaAdjustment = addingOffset;
  }

  setSafeAreaHeight(double height) async {
    state.safeAreaHeight = height;
  }

  downBottomSheet() async {
    if (state.safeAreaHeight > 0) {
      if (state.bottomSheetContext != null
          && state.bottomSheetContext!.mounted) {
        Navigator.pop(state.bottomSheetContext!);
      }
      await setBottomSheetContext(null);
      await setSafeAreaAdjustment(0);
      await setForceScroll(false);
      await setSafeAreaHeight(0);
      await updateState();
    }
  }

  setBottomSheetContext(BuildContext? context) async {
    state.bottomSheetContext = context;
  }

  setForceScroll(bool forceScroll) async {
    state.forceScroll = forceScroll;
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