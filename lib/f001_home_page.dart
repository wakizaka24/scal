import 'dart:io';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scal/f017_event_detail_page.dart';

import 'f002_home_view_model.dart';
import 'f011_end_drawer.dart';
import 'f003_calendar_page.dart';
import 'f005_calendar_view_model.dart';
import 'f016_design.dart';
import 'f018_event_detail_view_model.dart';

final GlobalKey<ScaffoldState> homePageScaffoldKey
  = GlobalKey<ScaffoldState>();

// アプリバーの高さ
const double appBarHeight = 39;
// カレンダーウィジェットの数
const calendarWidgetNum = 1;

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final AppLifecycleState? appLifecycleState = useAppLifecycleState();
    final preAppLifecycle = useState(appLifecycleState);
    final maximumUnsafeAreaBottomHeight = useState(0.0);

    final homeState = ref.watch(homePageNotifierProvider);
    final homeNotifier = ref.watch(homePageNotifierProvider.notifier);

    final colorConfigNotifier = ref.watch(designConfigNotifierProvider
        .notifier);
    List<CalendarPageNotifier> calendarNotifiers = [];
    for (int i=0; i < calendarWidgetNum; i++) {
      calendarNotifiers.add(ref.watch(calendarPageNotifierProvider(i)
          .notifier));
    }

    final calendarNotifier = calendarNotifiers[homeState.homePageIndex];

    // final eventDetailState = ref.watch(eventDetailPageNotifierProvider);
    final eventDetailNotifier = ref.watch(eventDetailPageNotifierProvider
        .notifier);

    // Widgetの一番上で取得可能な項目
    // アンセーフエリア上の高さ
    double unsafeAreaTopHeight = MediaQuery.of(context).padding.top;
    if (Platform.isIOS) {
      unsafeAreaTopHeight += -17;
    }
    if (unsafeAreaTopHeight < 10) {
      unsafeAreaTopHeight = 10;
    }
    // アンセーフエリア下の高さ
    // キーボード表示時セーフエリアが小さくなるので最大の値を使用する。
    double bottomHeight = MediaQuery.of(context).padding.bottom;
    if (bottomHeight < 10) {
      bottomHeight = 10;
    }
    if (bottomHeight > maximumUnsafeAreaBottomHeight.value) {
      maximumUnsafeAreaBottomHeight.value = bottomHeight;
    }
    double unsafeAreaBottomHeight = maximumUnsafeAreaBottomHeight.value;
    // 画面の幅
    double deviceWidth = MediaQuery.of(context).size.width;
    // 画面の高さ
    double deviceHeight = MediaQuery.of(context).size.height;

    useEffect(() {
      debugPrint('parent useEffect');

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
          await homeNotifier.setHomePageIndex(index);
          final calendarNotifier = ref.watch(calendarPageNotifierProvider(
              homeState.homePageIndex).notifier);
          calendarNotifier.updateSelectionDayOfHome();
        }
      });

      return () {
        // Pageの解放処理
      };
    }, const []);

    // useEffect(() {
    //   if (!homeState.uICover) {
    //   }
    //
    //   return () {
    //   };
    // }, [homeState.uICover]);

    // アプリに復帰時(再開以外から再開)またはアプリ再開以外
    var appDistant = appLifecycleState != null
      && ((appLifecycleState == AppLifecycleState.resumed
      && preAppLifecycle.value != AppLifecycleState.resumed)
        || appLifecycleState != AppLifecycleState.resumed);
    preAppLifecycle.value = appLifecycleState;
    //debugPrint('appLifecycleState=$appLifecycleState');
    if (appDistant) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final Brightness brightness = MediaQuery.platformBrightnessOf(
            context);
        if (colorConfigNotifier.applyColorConfig(brightness)) {
          for (var i = 0; i < calendarWidgetNum; i++) {
            await calendarNotifiers[i].initState();
            await calendarNotifiers[i].updateCalendar(
                dataExclusion: true);
          }
          await colorConfigNotifier.updateState();
        }
      });
    }

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
                          fontWeight: appBarTitleFontWeight,
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
                  onPressed: () async {
                    await colorConfigNotifier.switchColorConfig();
                    for (var i=0; i < calendarWidgetNum; i++) {
                      await calendarNotifiers[i].initState();
                      await calendarNotifiers[i].updateCalendar(
                          dataExclusion: true);
                    }
                    await colorConfigNotifier.updateState();
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
                  onPressed: () async {
                    await calendarNotifier.onTapTodayButton();
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
                  onPressed: () async {
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
                  for (var i=0; i < calendarWidgetNum; i++) ... {
                    CalendarPage(unsafeAreaTopHeight: unsafeAreaTopHeight,
                        unsafeAreaBottomHeight: unsafeAreaBottomHeight,
                        pageIndex: i),
                  }
                ],
              )
          )
        ]
    );

    var floatingActionButton = FloatingActionButton(
        heroTag: 'calendar_hero_tag',
        onPressed: () async {
          var _ = await calendarNotifier.getSelectionEvent();

          // 閉じた時のスピードが遅いので保留
          // if (!context.mounted) {
          //   return;
          // }
          // await Navigator.push(context,
          //   PageRouteBuilder(
          //       opaque: false,
          //       pageBuilder: (BuildContext context, Animation<double> animation,
          //           Animation<double> secondaryAnimation) {
          //         return EventDetailPage(
          //             unsafeAreaTopHeight: unsafeAreaTopHeight,
          //             unsafeAreaBottomHeight: unsafeAreaBottomHeight);
          //         },
          //       transitionDuration: const Duration(seconds: 0)
          //   )
          // );

          await homeNotifier.setUICover(true);
          await homeNotifier.setUICoverWidget(
              EventDetailPage(unsafeAreaTopHeight: unsafeAreaTopHeight,
                unsafeAreaBottomHeight: unsafeAreaBottomHeight));
          await eventDetailNotifier.setDeviceHeight(deviceHeight);
          await homeNotifier.updateState();
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

    var stack = Stack(children: [
      SizedBox(width: deviceWidth, height: unsafeAreaTopHeight + appBarHeight,
          child: Container(color: theme.primaryColor)
      ),
      // Image.asset('images/IMG_3173_3.jpeg'),
      appTitle,
      appBar,
      calendars,
      Column(
          children: [
            const Spacer(),
            Row(children: [
              const Spacer(),
              Container(width: deviceWidth, height: unsafeAreaBottomHeight,
                  color: Colors.transparent),
            ])
          ]
      ),
      Column(
          children: [
            const Spacer(),
            Row(children: [
              const Spacer(),
              floatingActionButton,
              Container(width: 10)
            ]),
            SizedBox(width: deviceWidth, height: unsafeAreaBottomHeight)
          ]
      ),
      if (homeState.uICover)
        Container(color: Colors.black.withAlpha(100)),
      if (homeState.uICoverWidget != null)
        homeState.uICoverWidget!,
    ]);

    Widget? scaffold;
    if (!homeState.uICover) {
      scaffold = Scaffold(
          key: homePageScaffoldKey,
          resizeToAvoidBottomInset: false,
          endDrawer: EndDrawer(unsafeAreaTopHeight: unsafeAreaTopHeight),
          body: stack
      );
    } else {
      scaffold = Scaffold(
          key: homePageScaffoldKey,
          resizeToAvoidBottomInset: false,
          body: stack
      );
    }

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