import 'package:flutter/cupertino.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'f024_keyboard_safe_area_view_model.dart';

class KeyboardSafeAreaView extends StatefulHookConsumerWidget {
  final ScrollController keyboardScrollController;
  final double unsafeAreaTopHeight;
  final double unsafeAreaBottomHeight;
  final double contentsWidth;
  final double contentsHeight;
  final Widget child;

  const KeyboardSafeAreaView({super.key,
    required this.keyboardScrollController,
    required this.unsafeAreaTopHeight,
    required this.unsafeAreaBottomHeight,
    required this.contentsWidth,
    required this.contentsHeight,

    required this.child
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState()
  => _KeyboardSafeAreaView();
}

class _KeyboardSafeAreaView extends ConsumerState<KeyboardSafeAreaView> {
  @override
  Widget build(BuildContext context) {
    final keyboardViewState = ref.watch(keyboardSafeAreaViewNotifierProvider);
    final keyboardViewNotifier = ref.watch(keyboardSafeAreaViewNotifierProvider
        .notifier);

    final firstPrimary = useState<bool>(true);
    final firstPrimaryOffsetY = useState<double>(0.0);
    final firstPrimaryFocusY = useState<double>(0.0);
    final preKeyboardHeight = useState<double>(0.0);
    final keyboardMovingCompletion = useState<bool>(false);

    // 画面の高さ
    double deviceHeight = MediaQuery.of(context).size.height;

    // キーボードの高さ
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // フォーカス項目
    var focusItem = false;
    // フォーカスにコンテキストがない場合落ちる
    try {
      focusItem = deviceHeight != primaryFocus?.rect.height;
    } catch (_) {}

    // フォーカステキストの位置
    if (!focusItem) {
      firstPrimary.value = true;
      keyboardMovingCompletion.value = false;
    } else if (firstPrimary.value) {
      firstPrimary.value = false;
      firstPrimaryOffsetY.value = widget.keyboardScrollController.offset;
      firstPrimaryFocusY.value = primaryFocus?.offset.dy ?? 0;
    }
    double primaryOffsetY = firstPrimaryOffsetY.value;
    double primaryFocusY = firstPrimaryFocusY.value;
    // フォーカステキストの高さ
    double primaryFocusHeight = !focusItem ? 0
        : primaryFocus?.rect.height ?? 0;

    // キーボードを閉じた場合
    if (!focusItem && keyboardHeight == 0) {
      keyboardViewNotifier.setKeyboardAdjustment(0);
    }

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        preKeyboardHeight.value = keyboardHeight;
        await Future.delayed(const Duration(milliseconds: 100));
        if (preKeyboardHeight.value == keyboardHeight) {
          keyboardMovingCompletion.value = true;
        } else {
          keyboardMovingCompletion.value = false;
        }
      });

      return () {
      };
    }, [keyboardHeight]);

    useEffect(() {
      if (keyboardMovingCompletion.value && focusItem) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          var offset = widget.keyboardScrollController.offset;
          // 見切れるスクロールの上限
          var upperLimitOffset = primaryFocusY + primaryOffsetY
              - widget.unsafeAreaTopHeight;
          // キーボードで隠れるのでスクロールの下限
          var lowerLimitOffset = upperLimitOffset
              - (deviceHeight - widget.unsafeAreaTopHeight - keyboardHeight
                  - primaryFocusHeight);

          // debugPrint('Test=$primaryOffsetY $primaryFocusY $upperLimitOffset'
          //     ' $lowerLimitOffset ${homeState.keyboardAdjustment}');

          var scrollOffset = lowerLimitOffset;
          var forceScroll = false;
          if (scrollOffset <= upperLimitOffset) {
            scrollOffset = lowerLimitOffset + keyboardViewState
                .keyboardAdjustment;
          } else {
            // エリアが上限を上回る場合は上限に合わせる
            forceScroll = true;
            scrollOffset = upperLimitOffset;
          }

          if (offset < scrollOffset || forceScroll) {
            var distance = (offset - scrollOffset).abs().toInt();
            keyboardViewState.keyboardScrollController?.animateTo(scrollOffset,
                duration: Duration(milliseconds: (distance * 0.52).toInt()),
                curve: Curves.linear);
            // homeState.keyboardScrollController?.jumpTo(scrollOffset);
          }
        });
      }

      return () {
      };
    }, [keyboardMovingCompletion.value]);

    return SingleChildScrollView(
        controller: widget.keyboardScrollController,
        physics: const ClampingScrollPhysics(),
        child: Padding(padding: EdgeInsets.only(
            bottom: keyboardHeight),
            child: SizedBox(
                width: widget.contentsWidth,
                height: widget.contentsHeight,
                child: widget.child
            )
        )
    );
  }
}