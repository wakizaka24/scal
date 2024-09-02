import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EndDrawerPageState {
  static EndDrawerPageState copy(EndDrawerPageState state) {
    var nState = EndDrawerPageState();
    return nState;
  }
}

class EndDrawerPageNotifier extends StateNotifier<EndDrawerPageState> {
  final Ref ref;

  EndDrawerPageNotifier(this.ref, EndDrawerPageState state)
      : super(state);

  initState() async {

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