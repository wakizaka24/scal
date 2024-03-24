import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'f016_design.dart';

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
                      fontWeight: dialogFontWidth,
                    )
                ),
                content: Text(message,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: dialogFontWidth,
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
}