import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'f002_home_view_model.dart';
import 'f005_end_drawer.dart';
import 'f003_calendar_page.dart';
import 'f004_calendar_view_model.dart';

final GlobalKey<ScaffoldState> homePageScaffoldKey
  = GlobalKey<ScaffoldState>();

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homePageNotifierProvider);
    final notifier = ref.watch(homePageNotifierProvider.notifier);

    // Widgetの一番上で取得可能な項目
    // アンセーフエリア上の高さ
    double unSafeAreaTopHeight = MediaQuery.of(context).padding.top;
    // 画面の高さ
    double deviceHeight = MediaQuery.of(context).size.height;
    // アプリバーの高さ
    double appBarHeight = state.appBarHeight;//AppBar().preferredSize.height;

    state.homePageController.addListener(() async {
      double offset = state.homePageController.offset;
      double contentHeight = deviceHeight - unSafeAreaTopHeight - appBarHeight;
      var index = state.homePageIndex;
      if (offset <= 0) {
        index = 0;
      } else if (offset >= contentHeight) {
        index = 1;
      }
      if (index != state.homePageIndex) {
        state.homePageIndex = index;
        notifier.setHomePageIndex(index);
      }
    });

    return Scaffold(
      key: homePageScaffoldKey,
      endDrawer: const EndDrawer(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(state.appBarHeight),
        child: AppBar(
          title: Consumer(
              builder: ((context, ref, child) {
                final homeState = ref.watch(homePageNotifierProvider);
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(homeState.appBarTitle,
                        style: const TextStyle(
                            height: 1.3,
                            fontSize: 21
                        )
                    ),
                  ],
                );
              }
              )
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
          CalendarPage(unSafeAreaTopHeight: unSafeAreaTopHeight, pageIndex: 0),
          CalendarPage(unSafeAreaTopHeight: unSafeAreaTopHeight, pageIndex: 1),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
      floatingActionButton: FloatingActionButton(
        heroTag: "calendar_hero_tag",
        onPressed: () {
          //homePageScaffoldKey.currentState!.openEndDrawer();
        },
        tooltip: 'イベント追加',
        child: Consumer(
          builder: ((context, ref, child) {
            final homeState = ref.watch(homePageNotifierProvider);
            final calendarState = ref.watch(calendarPageNotifierProvider(
                homeState.homePageIndex));
            return Icon(calendarState.dayPartActive
                ? Icons.add : Icons.add_circle_outline);
          })
        )
      ),
    );
  }
}