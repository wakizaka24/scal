import 'package:flutter/material.dart';

import 'f016_ui_define.dart';

class CommonUtils {
  static final CommonUtils _instance = CommonUtils._internal();
  CommonUtils._internal();

  factory CommonUtils() {
    return _instance;
  }

  Future<String?> showMessageDialog(
      BuildContext context, String title, String message,
      [String positiveTitle = 'OK', String? negativeTitle]) async {

    return await showDialog<String>(
        barrierColor: Colors.black12,
        context: context,
        builder: (_) {
          return PopScope(
              canPop: false,
              child: AlertDialog(
                title: Text(title,
                    style: const TextStyle(
                        fontSize: 21
                    )
                ),
                content: Text(message,
                    style: const TextStyle(
                        fontSize: 15
                    )),
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
                          style: TextStyle(color: cardTextColor)),
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
                          style: TextStyle(color: cardTextColor))
                  )
                ],
              )
          );
        });
  }
}