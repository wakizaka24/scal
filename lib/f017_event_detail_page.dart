import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'f002_home_view_model.dart';
import 'f016_design.dart';
import 'f018_event_detail_view_model.dart';

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
    final colorConfigState = ref.watch(designConfigNotifierProvider);
    var normalTextColor = colorConfigState.colorConfig!.normalTextColor;
    var borderColor = colorConfigState.colorConfig!.normalTextColor;
    final homeNotifier = ref.watch(homePageNotifierProvider.notifier);
    final eventDetailState = ref.watch(eventDetailPageNotifierProvider);
    final eventDetailNotifier = ref.watch(eventDetailPageNotifierProvider
        .notifier);

    useEffect(() {
      return () {
      };
    }, const []);

    // 画面の幅
    double deviceWidth = MediaQuery.of(context).size.width;
    // キーボードの高さ
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    // ページの幅
    double pageWidget = deviceWidth * 0.9;

    // 閉じるボタンの幅
    double closingButtonWidth = 39;

    var contents = Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                SizedBox(width: closingButtonWidth,
                    height: closingButtonWidth,
                    child: TextButton(
                      onPressed: () async {
                        // Navigator.pop(context);

                        homeNotifier.setUICover(false);
                        homeNotifier.setUICoverWidget(null);
                        homeNotifier.resetUICoverWidgetHeight();
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
                SizedBox(width: closingButtonWidth,
                    height: closingButtonWidth,
                    child: TextButton(
                      onPressed: () async {
                        var contentsMode = eventDetailState.contentsMode;
                        switch (contentsMode) {
                          case EventDetailPageContentsMode.simpleInput:
                            contentsMode = EventDetailPageContentsMode.detailInput;
                          case EventDetailPageContentsMode.detailInput:
                            contentsMode = EventDetailPageContentsMode.simpleInput;
                        }
                        await eventDetailNotifier.setContentsMode(contentsMode);

                        await homeNotifier.resetKeyboardOffset(
                            eventDetailState.contentsHeight!,
                            eventDetailState.deviceHeight!,
                            keyboardHeight);
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
              ]),

              const SizedBox(height: 8),

              Row(children: [
                SizedBox(width: 52,
                  child: Text('タイトル', textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13,
                          color: normalTextColor
                      )
                  )
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                      height: 41,
                      child: TextField(
                        // controller: textField1Controller,
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(8),
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: borderColor,
                                    width: 2
                                )
                            ),
                            hintText: 'タイトル',
                          ),
                          // keyboardType: TextInputType.multiline,
                          // maxLines: 2,
                          onTap: () {
                            homeNotifier.setKeyboardAdjustment(15);
                          },
                          onChanged: (text) {
                            debugPrint("Textの変更検知={$text}");
                          }
                      )
                  )
                ),
                const SizedBox(width: 45)
              ]),

              const SizedBox(height: 8),

              Row(children: [
                SizedBox(width: 52,
                    child: Text('場所', textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            color: normalTextColor
                        )
                    )
                ),
                const SizedBox(width: 8),
                Expanded(
                    child: SizedBox(
                        height: 41,
                        child: TextField(
                          // controller: textField1Controller,
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(8),
                              border: const OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: borderColor,
                                      width: 2
                                  )
                              ),
                              hintText: '場所',
                            ),
                            // keyboardType: TextInputType.multiline,
                            // maxLines: 1,
                            onTap: () {
                              homeNotifier.setKeyboardAdjustment(15);
                            },
                            onChanged: (text) {
                              debugPrint("Textの変更検知={$text}");
                            }
                        )
                    )
                ),
              ]),

              const SizedBox(height: 8),

              Row(children: [
                SizedBox(width: 52,
                    child: Text('開始', textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            color: normalTextColor
                        )
                    )
                ),
                const SizedBox(width: 8),
                Expanded(
                    child: SizedBox(
                        height: 41,
                        child: TextField(
                          // controller: textField1Controller,
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(8),
                              border: const OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: borderColor,
                                      width: 2
                                  )
                              ),
                              hintText: '場所',
                            ),
                            // keyboardType: TextInputType.multiline,
                            // maxLines: 1,
                            onTap: () {
                              homeNotifier.setKeyboardAdjustment(15);
                            },
                            onChanged: (text) {
                              debugPrint("Textの変更検知={$text}");
                            }
                        )
                    )
                ),
              ]),

              const Spacer(),
            ]
        )
    );

    var center = Center(
      child: SizedBox(width: pageWidget, height: eventDetailState
          .contentsHeight! - widget.unsafeAreaTopHeight
          - widget.unsafeAreaBottomHeight,
          child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: contents)
      )
    );

    return Column(children: [
      SizedBox(width: deviceWidth, height: widget.unsafeAreaTopHeight),

      // const Spacer(),
      // SizedBox(width: pageWidget, height: eventDetailState.contentsHeight!
      //     - widget.unsafeAreaTopHeight
      //     - widget.unsafeAreaBottomHeight,
      //     child: Container(
      //         decoration: BoxDecoration(
      //           color: theme.colorScheme.background,
      //           borderRadius: BorderRadius.circular(16),
      //         ),
      //         child: contents)
      // ),

      const Spacer(),
      center,
      const Spacer(),

      SizedBox(width: deviceWidth, height: widget.unsafeAreaBottomHeight),
    ]);
  }
}