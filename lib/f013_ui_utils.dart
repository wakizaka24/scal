import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'f016_design_config.dart';
import 'f024_bottom_safe_area_view_model.dart';

class UIUtils {
  static final UIUtils _instance = UIUtils._internal();
  UIUtils._internal();

  factory UIUtils() {
    return _instance;
  }

  Future<String?> showMessageDialog(
      BuildContext context, WidgetRef ref, String title, String message,
      [String positiveTitle = 'OK', String? negativeTitle]) async {
    return await showDialog<String>(
        context: context,
        builder: (_) {
          final designConfigState = ref.watch(designConfigNotifierProvider);
          return PopScope(
              canPop: false,
              child: AlertDialog(
                title: Text(title,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: dialogFontWeight,
                    )
                ),
                content: Text(message,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: dialogFontWeight,
                    )
                ),
                actions: <Widget>[
                  Visibility(
                    visible: negativeTitle != null,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (context.mounted) {
                          Navigator.pop(context, 'negative');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 13),
                        padding: const EdgeInsets.all(0),
                      ),
                      child: Text(negativeTitle ?? "",
                          style: TextStyle(
                              fontSize: buttonFontSize,
                              fontWeight: buttonFontWeight,
                              color: designConfigState.colorConfig!
                              .cardTextColor
                          )
                      ),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (context.mounted) {
                          Navigator.pop(context, 'positive');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 13),
                        padding: const EdgeInsets.all(0),
                      ),
                      child: Text(positiveTitle,
                          style: TextStyle(
                              fontSize: buttonFontSize,
                              fontWeight: buttonFontWeight,
                              color: designConfigState.colorConfig!
                              .cardTextColor
                          )
                      )
                  )
                ],
              )
          );
        });
  }

  Function(Widget child, {double height}) useShowBottomArea(
      WidgetRef ref) {
    final context = useContext();
    final safeAreaViewNotifier = ref.watch(bottomSafeAreaViewNotifierProvider
        .notifier);
    safeAreaViewNotifier.setBottomSheetContext(context);
    return (Widget child, {double height = 215}) {
      showBottomSheet(
        context: context,
        builder: (BuildContext context) {
          final colorConfig = ref.watch(designConfigNotifierProvider)
              .colorConfig!;
          return Container(
            height: height,
            padding: const EdgeInsets.all(0),
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            color: colorConfig.backgroundColor,
            child: SafeArea(
              top: false,
              child: child,
            ),
          );
        },
      );
    };
  }
}