import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'f003_end_drawer.dart';
import 'f004_calendar_page.dart';

final GlobalKey<ScaffoldState> homePageScaffoldKey
  = GlobalKey<ScaffoldState>();

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  /*
  pageViewController.value.animateToPage(index,
    duration: const Duration(milliseconds: 200),
    curve: Curves.easeOut);
   */

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Widgetの一番上で取得可能な項目
    // アンセーフエリア上の高さ
    double unSafeAreaTopHeight = MediaQuery.of(context).padding.top;

    final selectedIndex = useState(0);
    final pageViewController = useState(PageController());

    return Scaffold(
      key: homePageScaffoldKey,
      endDrawer: const EndDrawer(),
      appBar: AppBar(
        title: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('2023年6月'),
          ],
        ),
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal, // 横
        controller: pageViewController.value,
        pageSnapping: true, // ページごとにスクロールを止める
        onPageChanged: (index) {
          selectedIndex.value = index;
        },
        children: <Widget>[
          CalendarPage(unSafeAreaTopHeight: unSafeAreaTopHeight),
          CalendarPage(unSafeAreaTopHeight: unSafeAreaTopHeight),
        ],
      ),
    );
  }
}