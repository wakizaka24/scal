import 'package:flutter/material.dart';

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
        context: context,
        builder: (_) {
          return WillPopScope(
            child: AlertDialog(
              title: Text(title),
              content: Text(message),
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
                    child: Text(negativeTitle ?? ""),
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
                    child: Text(positiveTitle)
                )
              ],
            ),
            onWillPop: () async => false,
          );
        });
  }
}