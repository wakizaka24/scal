import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'f002_home_view_model.dart';
import 'f016_design.dart';

class EventDetailPage extends StatefulHookConsumerWidget {
  final double unsafeAreaTopHeight;
  final double unsafeAreaBottomHeight;

  const EventDetailPage({super.key,
    required this.unsafeAreaTopHeight,
    required this.unsafeAreaBottomHeight
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState()
  => _EventDetailPage();
}

class _EventDetailPage extends ConsumerState<EventDetailPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final designConfigState = ref.watch(designConfigNotifierProvider);
    var normalTextColor = designConfigState.colorConfig!.normalTextColor;
    final homeNotifier = ref.watch(homePageNotifierProvider.notifier);

    useEffect(() {

      return () {
      };
    }, const []);

    // 画面の幅
    double deviceWidth = MediaQuery.of(context).size.width;
    // 画面の高さ
    //double deviceHeight = MediaQuery.of(context).size.height;
    // ページの幅
    double pageWidget = deviceWidth * 0.9;
    // ページの高さ
    // double pageHeight = (deviceHeight
    //     - widget.unsafeAreaTopHeight
    //     - appBarHeight) * 0.6;

    // 閉じるボタンの幅
    double closingButtonWidth = 39;

    var contents = Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: closingButtonWidth,
                  height: closingButtonWidth,
                  child: TextButton(
                    onPressed: () async {
                      // Navigator.pop(context);

                      homeNotifier.setUICover(false);
                      homeNotifier.setUICoverWidget(null);
                      homeNotifier.updateState();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: normalTextColor,
                      textStyle: const TextStyle(fontSize: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            closingButtonWidth / 2),
                      ),
                      padding: const EdgeInsets.all(0),
                    ),
                    child: Icon(Icons.check,
                        color: normalTextColor),
                  )
              ),
              // const Spacer()

              Row(children: [
                Text('タイトル', textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        color: normalTextColor
                    )
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    // controller: textField1Controller,
                    style: const TextStyle(fontSize: 15),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(8),
                      border: OutlineInputBorder(),
                      hintText: 'タイトル',
                    ),
                    onChanged: (text) {
                      debugPrint("Textの変更検知={$text}");
                    },
                  )
                )
              ],),

              const SizedBox(height: 100),

              Row(children: [
                Text('タイトル', textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        color: normalTextColor
                    )
                ),
                const SizedBox(width: 8),
                Expanded(
                    child: TextField(
                      // controller: textField1Controller,
                      style: const TextStyle(fontSize: 15),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(8),
                        border: OutlineInputBorder(),
                        hintText: 'タイトル',
                      ),
                      onChanged: (text) {
                        debugPrint("Textの変更検知={$text}");
                      },
                    )
                )
              ],),

    FloatingActionButton(
    heroTag: 'calendar_hero_tags',
    onPressed: () async {})
            ]
        )
    );

    var center = Center(
      child: SizedBox(width: pageWidget, /*height: pageHeight,*/
          child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: contents)
      )
    );

    return Stack(children: [
      Container(color: Colors.black.withAlpha(100)),
      Column(children: [
        SizedBox(width: deviceWidth, height: widget.unsafeAreaTopHeight),
        const Spacer(),
        center,
        const Spacer(),
        SizedBox(width: deviceWidth, height: widget.unsafeAreaBottomHeight),
      ])
    ]);
  }
}