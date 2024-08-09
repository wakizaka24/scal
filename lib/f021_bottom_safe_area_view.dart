import 'package:flutter/cupertino.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'f024_bottom_safe_area_view_model.dart';

class BottomSafeAreaView extends StatefulHookConsumerWidget {
  final double unsafeAreaTopHeight;
  final double unsafeAreaBottomHeight;
  final double contentsWidth;
  final double contentsHeight;
  final Widget child;

  const BottomSafeAreaView({super.key,
    required this.unsafeAreaTopHeight,
    required this.unsafeAreaBottomHeight,
    required this.contentsWidth,
    required this.contentsHeight,
    required this.child
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState()
  => _BottomSafeAreaView();
}

class ScrollStatus {
  final double offset;
  final double scrollOffset;
  final bool forceScroll;
  final int milliseconds;

  const ScrollStatus({
    required this.offset,
    required this.scrollOffset,
    required this.forceScroll,
    required this.milliseconds
  });
}

class _BottomSafeAreaView extends ConsumerState<BottomSafeAreaView> {
  @override
  Widget build(BuildContext context) {
    final safeAreaViewState = ref.watch(bottomSafeAreaViewNotifierProvider);
    final safeAreaViewNotifier = ref.watch(bottomSafeAreaViewNotifierProvider
        .notifier);

    final firstPrimaryOffsetY = useState<double>(0.0);
    final firstPrimaryFocusY = useState<double>(0.0);
    final preKeyboardHeight = useState<double>(0.0);
    final keyboardMovingCompletion = useState<bool>(false);

    useEffect(() {
      safeAreaViewNotifier.initState();

      return () {
      };
    }, const []);

    // 画面の高さ
    double deviceHeight = MediaQuery.of(context).size.height;

    // キーボードの高さ
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // フォーカス項目
    var focusItem = false;
    double focusY = 0;
    double? focusHeight;
    // フォーカスにコンテキストがない場合落ちる
    try {
      focusItem = /*primaryFocus?.runtimeType == FocusNode
          && */deviceHeight != primaryFocus?.rect.height;
      focusY = primaryFocus?.offset.dy ?? 0;
      // debugPrint('keyboard focusItem=$focusItem type'
      //     '=${primaryFocus?.runtimeType ?? 'null'}');
      focusHeight = primaryFocus?.rect.height;
    } catch (_) {}

    // フォーカステキストの位置
    if (!focusItem) {
      keyboardMovingCompletion.value = false;
      // キーボード表示時にコンボボックスなどでキーボードを閉じて、再度キーボードを開いた時、
      // スクロールが必要であればスクロールする。
    } else if (firstPrimaryOffsetY.value
        != safeAreaViewState.keyboardScrollController!.offset
        || firstPrimaryFocusY.value != focusY) {
      firstPrimaryOffsetY.value = safeAreaViewState.keyboardScrollController!
          .offset;
      firstPrimaryFocusY.value = focusY;
    }
    double primaryOffsetY = firstPrimaryOffsetY.value;
    double primaryFocusY = firstPrimaryFocusY.value;
    // フォーカステキストの高さ
    double primaryFocusHeight = !focusItem ? 0
        : focusHeight ?? 0;

    // キーボードを閉じた場合
    var keyboardDown = !focusItem && keyboardHeight == 0;
    if (keyboardDown) {
      safeAreaViewNotifier.setSafeAreaAdjustment(0);
    }

    double bottom = 0;
    adjustScroll(scrollStatus) async {
      if (scrollStatus.offset < scrollStatus.scrollOffset
          || scrollStatus.forceScroll) {
        await safeAreaViewState.keyboardScrollController?.animateTo(
            scrollStatus.scrollOffset, duration: Duration(
            milliseconds: scrollStatus.milliseconds), curve: Curves.linear);
        // homeState.keyboardScrollController?.jumpTo(scrollOffset);
      }
    }

    ScrollStatus calcScrollStatus(double bottomHeight) {
      var offset = safeAreaViewState.keyboardScrollController!.offset;
      // 見切れるスクロールの上限
      var upperLimitOffset = primaryFocusY + primaryOffsetY
          - widget.unsafeAreaTopHeight;
      // キーボードで隠れるのでスクロールの下限
      var lowerLimitOffset = upperLimitOffset
          - (deviceHeight - widget.unsafeAreaTopHeight - bottomHeight
              - primaryFocusHeight);

      // debugPrint('Test=$primaryOffsetY $primaryFocusY $upperLimitOffset'
      //     ' $lowerLimitOffset ${homeState.keyboardAdjustment}');

      var scrollOffset = lowerLimitOffset;
      var forceScroll = false;

      if (scrollOffset <= upperLimitOffset) {
        scrollOffset = lowerLimitOffset + safeAreaViewState.safeAreaAdjustment;
      } else {
        // エリアが上限を上回る場合は上限に合わせる
        forceScroll = true;
        scrollOffset = upperLimitOffset;
      }

      var scroll = offset - scrollOffset;
      var distance = scroll.abs().toInt();
      var milliseconds = (distance * 0.52).toInt();
      if (milliseconds == 0) {
        milliseconds = 1;
      }

      if (scroll < 0) {
        // 非表示エリアの食い込み
        var biting = (widget.contentsHeight - deviceHeight - offset).abs();
        bottom = scroll.abs() - biting;
        if (bottom < 0) {
          bottom = 0;
        }
      }

      return ScrollStatus(offset: offset, scrollOffset: scrollOffset,
          forceScroll: forceScroll, milliseconds: milliseconds);
    }

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        preKeyboardHeight.value = keyboardHeight;
        await Future.delayed(const Duration(milliseconds: 100));
        if (keyboardHeight == 0 || preKeyboardHeight.value == keyboardHeight) {
          try {
            keyboardMovingCompletion.value = true;
          } catch(_) {}
          // debugPrint('keyboard not moving $keyboardHeight');
        } else {
          keyboardMovingCompletion.value = false;
          // debugPrint('keyboard moving $keyboardHeight');
        }
      });

      return () {
      };
    }, [keyboardHeight]);

    useEffect(() {
      // debugPrint('keyboard Upping Event ${keyboardMovingCompletion.value} '
      //     '$focusItem');
      if (keyboardMovingCompletion.value && focusItem) {
        var scrollState = calcScrollStatus(keyboardHeight);
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          adjustScroll(scrollState);
        });
      }

      return () {
      };
    }, [keyboardMovingCompletion.value]);

    var safeAreaHeight = safeAreaViewState.safeAreaHeight;
    useEffect(() {
      if (safeAreaHeight > 0) {
        var scrollState = calcScrollStatus(safeAreaHeight);
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          adjustScroll(scrollState);
        });
      }
      return () {
      };
    }, [safeAreaHeight]);

    return SingleChildScrollView(
        controller: safeAreaViewState.keyboardScrollController,
        physics: const ClampingScrollPhysics(),
        child: Padding(padding: EdgeInsets.only(
            bottom: /*safeAreaHeight > 0 ? safeAreaHeight : keyboardHeight*/
            bottom),
            child: SizedBox(
                width: widget.contentsWidth,
                height: widget.contentsHeight,
                child: widget.child
            )
        )
    );
  }
}