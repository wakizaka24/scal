import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'f002_home_view_model.dart';
import 'f011_end_drawer.dart';
import 'f003_calendar_page.dart';
import 'f005_calendar_view_model.dart';

final GlobalKey<ScaffoldState> homePageScaffoldKey
  = GlobalKey<ScaffoldState>();

// アプリバーの高さ
const double appBarHeight = 39;

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final homeState = ref.watch(homePageNotifierProvider);
    final homeNotifier = ref.watch(homePageNotifierProvider.notifier);
    final calendarNotifier = ref.watch(calendarPageNotifierProvider(
        homeState.homePageIndex).notifier);

    // Widgetの一番上で取得可能な項目
    // アンセーフエリア上の高さ
    double unsafeAreaTopHeight = MediaQuery.of(context).padding.top - 21;
    if (unsafeAreaTopHeight < 10) {
      unsafeAreaTopHeight = 10;
    }
    // アンセーフエリア下の高さ
    double unsafeAreaBottomHeight = MediaQuery.of(context).padding.bottom;
    // 画面の高さ
    double deviceHeight = MediaQuery.of(context).size.height;
    // 画面の高さ
    double deviceWidth = MediaQuery.of(context).size.width;

    useEffect(() {
      debugPrint('parent useEffect');
      // Pageの初期化処理
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        debugPrint('parent addPostFrameCallback');
      });

      homeState.homePageController.addListener(() async {
        double offset = homeState.homePageController.offset;
        double contentHeight = deviceHeight - appBarHeight
            - unsafeAreaTopHeight;
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
          calendarNotifier.updateSelectionDayOfHome();
        }
      });

      return () {
        // Pageの解放処理
      };
    }, const []);

    var appTitle = Column(children: [
      SizedBox(width: deviceWidth, height: unsafeAreaTopHeight
      ),
      SizedBox(width: deviceWidth, height: appBarHeight,
        child: Consumer(
            builder: ((context, ref, child) {
              final homeState = ref.watch(
                  homePageNotifierProvider);
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(width: 8),
                  Text(homeState.appBarTitle,
                      style: const TextStyle(
                          height: 1.3,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 24
                      )
                  ),
                  const Spacer(),
                ],
              );
            })
        ),
      ),
    ]);

    var appBar = Column(children: [
      SizedBox(width: deviceWidth, height: unsafeAreaTopHeight
      ),
      SizedBox(width: deviceWidth, height: appBarHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Spacer(),
            SizedBox(width: appBarHeight, height: appBarHeight,
                child: TextButton(
                  onPressed: () {
                    calendarNotifier.onTapTodayButton();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(appBarHeight / 2),
                    ),
                    padding: const EdgeInsets.all(0),
                  ),
                  child: const Icon(Icons.check),
                )
            ),
            SizedBox(width: appBarHeight, height: appBarHeight,
                child: TextButton(
                  onPressed: () {
                    homePageScaffoldKey.currentState!
                        .openEndDrawer();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(appBarHeight / 2),
                    ),
                    padding: const EdgeInsets.all(0),
                  ),
                  child: const Icon(Icons.check),
                )
            ),
            Container(width: 8)
          ],
        ),
      ),
    ]);

    var calendars = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: deviceWidth, height: unsafeAreaTopHeight
              + appBarHeight
          ),
          Expanded(
              child: PageView(
                controller: homeState.homePageController,
                // physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical, // 縦
                pageSnapping: true, // ページごとにスクロールを止める
                onPageChanged: (index) {
                },
                children: <Widget>[
                  CalendarPage(unsafeAreaTopHeight: unsafeAreaTopHeight,
                      unsafeAreaBottomHeight: unsafeAreaBottomHeight,
                      pageIndex: 0),
                  CalendarPage(unsafeAreaTopHeight: unsafeAreaTopHeight,
                      unsafeAreaBottomHeight: unsafeAreaBottomHeight,
                      pageIndex: 1),
                ],
              )
          )
        ]
    );

    var floatingActionButton = FloatingActionButton(
        heroTag: 'calendar_hero_tag',
        onPressed: () async {
          await calendarNotifier.onPressedAddingButton();
        },
        child: Consumer(
            builder: ((context, ref, child) {
              final homeState = ref.watch(homePageNotifierProvider);
              final calendarState = ref.watch(calendarPageNotifierProvider(
                  homeState.homePageIndex));
              return Icon(calendarState.cellActive
                  ? Icons.add : Icons.add_circle_outline,
                  color: Colors.white);
            })
        )
    );

    var scaffold = Scaffold(
      key: homePageScaffoldKey,
      endDrawer: EndDrawer(unsafeAreaTopHeight: unsafeAreaTopHeight),
      body: Stack(children: [
        SizedBox(width: deviceWidth, height: unsafeAreaTopHeight + appBarHeight,
            child: Container(color: theme.primaryColor)
        ),
        // Image.asset('images/IMG_3173_3.jpeg'),
        appTitle,
        appBar,
        calendars,
        SafeArea(child: Column(
            children: [
              const Spacer(),
              Row(children: [
                const Spacer(),
                floatingActionButton,
                Container(width: 10)
              ])
            ]
        )),
        // Visibility(visible: homeState.uICover,
        //     child: Container(color: Colors.black.withAlpha(100)))
      ])
    );

    // 右端スワイプでナビゲーションを戻さない
    return PopScope(
        canPop: false,
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: scaffold
        )
    );
  }
}