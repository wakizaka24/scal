import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scal/f001_home_page.dart';

import 'f002_home_view_model.dart';
import 'f016_design.dart';

class EventDetailPage extends StatefulHookConsumerWidget {
  final double unsafeAreaTopHeight;

  const EventDetailPage({super.key,
    required this.unsafeAreaTopHeight
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
    double deviceHeight = MediaQuery.of(context).size.height;
    // ページの幅
    double pageWidget = deviceWidth * 0.8;
    // ページの高さ
    double pageHeight = (deviceHeight
        - widget.unsafeAreaTopHeight
        - appBarHeight) * 0.6;

    // 閉じるボタンの幅
    double closingButtonWidth = 39;

    var contents = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              child: SizedBox(width: closingButtonWidth,
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
              )
          ),
          const Spacer()
        ]
    );

    var center = Center(
      child: SizedBox(width: pageWidget, height: pageHeight,
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
        SizedBox(height: widget.unsafeAreaTopHeight),
        Expanded(child: center)
      ])
    ]);
  }
}