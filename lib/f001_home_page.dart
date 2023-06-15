import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'f002_end_drawer.dart';
import 'f003_calendar_page.dart';
import 'f004_calendar_view_model.dart';

final GlobalKey<ScaffoldState> homePageScaffoldKey
  = GlobalKey<ScaffoldState>();

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarPageNotifierProvider);
    // final notifier = ref.watch(calendarPageNotifierProvider.notifier);

    // Widgetの一番上で取得可能な項目
    // アンセーフエリア上の高さ
    double unSafeAreaTopHeight = MediaQuery.of(context).padding.top;

    // 画面の高さ
    // double deviceHeight = MediaQuery.of(context).size.height;

    state.homePageController.addListener(() async {
      // double offset = state.homePageController.offset;

      // int index = 1;
      // if (offset <= 0) {
      //   index = 0;
      // } else if (offset >= deviceHeight * 2) {
      //   index = 2;
      // }

    });

    return Scaffold(
      key: homePageScaffoldKey,
      endDrawer: const EndDrawer(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(state.appBarHeight),
        child: AppBar(
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(state.appBarTitle,
                  style: const TextStyle(
                      height: 1.3,
                      fontSize: 21
                  )
              ),
            ],
          ),
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