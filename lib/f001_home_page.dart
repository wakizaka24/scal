import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'f002_home_view_model.dart';
import 'f011_end_drawer.dart';
import 'f003_month_calendar_page.dart';
import 'f005_month_calendar_view_model.dart';

final GlobalKey<ScaffoldState> homePageScaffoldKey
  = GlobalKey<ScaffoldState>();

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homePageNotifierProvider);
    final homeNotifier = ref.watch(homePageNotifierProvider.notifier);

    // Widgetの一番上で取得可能な項目
    // アンセーフエリア上の高さ
    double unSafeAreaTopHeight = MediaQuery.of(context).padding.top;
    // アンセーフエリア下の高さ
    double unSafeAreaBottomHeight = MediaQuery.of(context).padding.bottom;
    // 画面の高さ
    double deviceHeight = MediaQuery.of(context).size.height;
    // アプリバーの高さ
    double appBarHeight = homeState.appBarHeight;//AppBar().preferredSize.height;

    useEffect(() {
      debugPrint('parent useEffect');
      // Pageの初期化処理
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        debugPrint('parent addPostFrameCallback');
      });

      homeState.homePageController.addListener(() async {
        double offset = homeState.homePageController.offset;
        double contentHeight = deviceHeight - appBarHeight
            - unSafeAreaTopHeight;
        var index = homeState.homePageIndex;
        if (offset <= 0) {
          index = 0;
        } else if (offset >= contentHeight) {
          index = 1;
        }
        if (index != homeState.homePageIndex) {
          homeState.homePageIndex = index;
          homeNotifier.setHomePageIndex(index);
          final calendarNotifier = ref.watch(calendarPageNotifierProvider(
              homeState.homePageIndex).notifier);
          calendarNotifier.selectDayPart();
        }
      });

      return () {
        // Pageの解放処理
      };
    }, const []);

    return Scaffold(
      key: homePageScaffoldKey,
      endDrawer: const EndDrawer(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(homeState.appBarHeight),
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
              })
          ),
        ),
      ),
      body: PageView(
        // physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical, // 縦
        controller: homeState.homePageController,
        pageSnapping: true, // ページごとにスクロールを止める
        onPageChanged: (index) {
        },
        children: <Widget>[
          MonthCalendarPage(unSafeAreaTopHeight: unSafeAreaTopHeight,
              unSafeAreaBottomHeight: unSafeAreaBottomHeight,
              pageIndex: 0),
          MonthCalendarPage(unSafeAreaTopHeight: unSafeAreaTopHeight,
              unSafeAreaBottomHeight: unSafeAreaBottomHeight,
              pageIndex: 1),
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