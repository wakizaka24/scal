import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'f003_end_drawer.dart';
import 'f004_calendar_page.dart';
import 'f005_calendar_view_model.dart';

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
    final state = ref.watch(calendarPageNotifierProvider);
    final notifier = ref.watch(calendarPageNotifierProvider.notifier);

    // Widgetの一番上で取得可能な項目
    // アンセーフエリア上の高さ
    double unSafeAreaTopHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      key: homePageScaffoldKey,
      endDrawer: const EndDrawer(),
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(state.appBarTitle),
          ],
        ),
      ),
      body: PageView(
        // physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical, // 縦
        controller: state.homePageController,
        pageSnapping: true, // ページごとにスクロールを止める
        onPageChanged: (index) {
        },
        children: <Widget>[
          CalendarPage(unSafeAreaTopHeight: unSafeAreaTopHeight),
          CalendarPage(unSafeAreaTopHeight: unSafeAreaTopHeight),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
      floatingActionButton: FloatingActionButton(
        heroTag: "calendar_hero_tag",
        onPressed: () {
          //homePageScaffoldKey.currentState!.openEndDrawer();
        },
        tooltip: 'イベント追加',
        child: Icon(state.dayPartActive ? Icons.add : Icons.add_circle_outline),
      ),
    );
  }
}