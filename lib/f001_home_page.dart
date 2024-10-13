import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:scal/f018_event_detail_page.dart';

import 'f002_home_view_model.dart';
import 'f008_calendar_config.dart';
import 'f011_end_drawer_page.dart';
import 'f003_calendar_page.dart';
import 'f005_calendar_view_model.dart';
import 'f015_ui_utils.dart';
import 'f017_design_config.dart';
import 'f021_event_detail_view_model.dart';
import 'f025_common_widgets.dart';

final GlobalKey<ScaffoldState> homePageScaffoldKey
= GlobalKey<ScaffoldState>();

// アプリバーの高さ
const double appBarHeight = 39;
const double appBarIconHeight = 21;

var uIColorColor = Colors.black.withAlpha(100);

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final AppLifecycleState? appLifecycleState = useAppLifecycleState();
    final maximumUnsafeAreaBottomHeight = useState(0.0);

    final homeState = ref.watch(homePageNotifierProvider);
    final homeNotifier = ref.watch(homePageNotifierProvider.notifier);

    final calendarState = ref.watch(calendarPageNotifierProvider);
    final calendarNotifier = ref.watch(calendarPageNotifierProvider.notifier);

    // final eventDetailState = ref.watch(eventDetailPageNotifierProvider);
    final eventDetailNotifier = ref.watch(eventDetailPageNotifierProvider
        .notifier);

    final designConfigState = ref.watch(designConfigNotifierProvider);
    final designConfigNotifier = ref.watch(designConfigNotifierProvider
        .notifier);

    // final calendarConfigState = ref.watch(calendarConfigNotifierProvider);
    final calendarConfigNotifier = ref.watch(calendarConfigNotifierProvider
        .notifier);

    // Widgetの一番上で取得可能な項目
    // アンセーフエリア上の高さ
    double unsafeAreaTopHeight = MediaQuery.of(context).padding.top;
    // if (Platform.isIOS) {
    unsafeAreaTopHeight += -11;
    // }
    if (unsafeAreaTopHeight < 21) {
      unsafeAreaTopHeight = 21;
    }
    // アンセーフエリア下の高さ
    // キーボード表示時セーフエリアが小さくなるので最大の値を使用する。
    double bottomHeight = MediaQuery.of(context).padding.bottom;
    var navigationBarGestureMode = !kIsWeb && Platform.isIOS || MediaQuery.of(context)
        .systemGestureInsets.left > 0;
    // セーフエリア下がない場合は15以上確保する。
    if (bottomHeight < 15) {
      bottomHeight = 15;
    } else if (!navigationBarGestureMode) {
      bottomHeight +=15;
    }
    if (bottomHeight > maximumUnsafeAreaBottomHeight.value) {
      maximumUnsafeAreaBottomHeight.value = bottomHeight;
    }
    double unsafeAreaBottomHeight = maximumUnsafeAreaBottomHeight.value;
    // 画面の幅
    double deviceWidth = MediaQuery.of(context).size.width;
    // 画面の高さ
    // double deviceHeight = MediaQuery.of(context).size.height;

    useEffect(() {
      debugPrint('parent useEffect');

      homeNotifier.initState();
      return () {
      };
    }, const []);

    // useEffect(() {
    //   if (!homeState.uICover) {
    //   }
    //
    //   return () {
    //   };
    // }, [homeState.uICover]);

    //debugPrint('appLifecycleState=$appLifecycleState');
    useEffect(() {
      if (appLifecycleState == AppLifecycleState.resumed) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final Brightness brightness = MediaQuery.platformBrightnessOf(
              context);
          if (calendarState.initialized && designConfigNotifier
              .applyColorConfig(brightness)) {
            await calendarNotifier.updateCalendar(dataExclusion: true);
            await designConfigNotifier.updateState();
          }

          debugPrint('home_page $appLifecycleState'
              ' ${designConfigState.colorConfig}');
        });
      }

      return () {
      };
    }, [appLifecycleState]);

    useEffect(() {
      if (appLifecycleState == AppLifecycleState.inactive) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          // Androidの場合、非活性時、キーボード表示中のテキストが、
          // 選択状態だがキーボードが表示されないので選択を外す。
          // iOSの場合、その後活性化時に再度選択される。
          primaryFocus?.unfocus();

          // ハイライト解除
          await eventDetailNotifier.updateHighlightItem(
              HighlightItem.none);
        });
      }

      return () {
      };
    }, [appLifecycleState]);

    var appTitle = Column(children: [
      SizedBox(width: deviceWidth, height: unsafeAreaTopHeight),
      SizedBox(width: deviceWidth, height: appBarHeight,
        child: Consumer(
            builder: ((context, ref, child) {
              final homeState = ref.watch(
                  homePageNotifierProvider);
              return Row(
                // crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(width: 8),
                  Text(homeState.appBarTitle,
                      style: const TextStyle(
                          height: 1.3,
                          color: Colors.white,
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

            CWIconButton(
              assetName: homeState.brightnessModeAssetName,
              assetIconSize: appBarIconHeight,
              width: appBarHeight,
              height: appBarHeight,
              radius: appBarHeight / 2,
              onPressed: () async {
                var colorChanged = designConfigNotifier.switchBrightnessMode();
                homeNotifier.setBrightnessMode(
                    designConfigState.brightnessMode!);
                if (colorChanged) {
                  await designConfigNotifier.updateState();
                  await calendarNotifier.updateCalendar(dataExclusion: true);
                } else {
                  await homeNotifier.updateState();
                }
              },
            ),

            CWIconButton(
              assetName: 'images/icon_change_calendar_color@3x.png',
              assetIconSize: appBarIconHeight,
              width: appBarHeight,
              height: appBarHeight,
              radius: appBarHeight / 2,
              onPressed: designConfigNotifier.getColorConfigs().length <= 1
                  ? null : () async {
                if (designConfigNotifier.switchColorConfig()) {
                  await calendarNotifier.updateCalendar(dataExclusion: true);
                  await designConfigNotifier.updateState();
                }
              },
            ),

            CWIconButton(
              assetName: 'images/icon_today_selection@3x.png',
              assetIconSize: appBarIconHeight,
              width: appBarHeight,
              height: appBarHeight,
              radius: appBarHeight / 2,
              onPressed: () async {
                await calendarNotifier.onTapTodayButton();
                await calendarNotifier.updateState();
              },
            ),

            CWIconButton(
              assetName: 'images/icon_drawer@3x.png',
              assetIconSize: appBarIconHeight,
              width: appBarHeight,
              height: appBarHeight,
              radius: appBarHeight / 2,
              onPressed: () async {
                homePageScaffoldKey.currentState!
                    .openEndDrawer();
              },
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
          Expanded(child: CalendarPage(unsafeAreaTopHeight: unsafeAreaTopHeight,
              unsafeAreaBottomHeight: unsafeAreaBottomHeight)
          )
        ]
    );

    var floatingActionButton = FloatingActionButton(
        heroTag: 'calendar_hero_tag',
        onPressed: () async {
          var event = await calendarNotifier.getSelectionEvent();
          final calendarState = ref.watch(calendarPageNotifierProvider);
          double prePage = calendarState.calendarSwitchingController
              .page!;
          var selectDay = event != null ? null : prePage.toInt() == 0;
          var selectionDateTime = selectDay == null ? null
              : selectDay ? calendarState.selectionDate
              : calendarState.selectionHour;
          List<CalendarAndAdditionalInfo> calendarAndAddInfos
          = await calendarConfigNotifier.createCalendarAndAddInfoList();

          CalendarAndAdditionalInfo? calendarAndAddInfo;
          if (calendarAndAddInfos.isEmpty) {
            PackageInfo packageInfo = await PackageInfo.fromPlatform();
            if (context.mounted) {
              await UIUtils().showMessageDialog(context, ref,
                  '登録', 'イベントの登録には、OSの${packageInfo.appName}の'
                      '設定でカレンダーへのアクセスを許可する必要があります。\n\n'
                      'また、OS標準のカレンダーアプリでカレンダー設定をする'
                      '必要があります。\n\n'
                      '詳しくは右上のアイコンから初期設定方法を参照ください。');
              return;
            }
          } else {
            calendarAndAddInfo = calendarAndAddInfos.first;
          }

          if (event != null) {
            calendarAndAddInfo = calendarAndAddInfos
                .firstWhere((calendarAndAddInfo) => calendarAndAddInfo
                .calendar.id == event.calendarId);
          } else {
            calendarAndAddInfo = calendarAndAddInfos
                .where((calendarAndAddInfo) => calendarAndAddInfo
                .useMode == CalendarUseMode.use).firstOrNull;

            if (calendarAndAddInfo == null) {
              if (context.mounted) {
                await UIUtils().showMessageDialog(context, ref,
                    '登録', '使用カレンダーが未設定です。');
                return;
              }
            }
          }

          if (calendarAndAddInfo!.editingMode == CalendarEditingMode
              .notEditable) {
            if (context.mounted) {
              await UIUtils().showMessageDialog(context, ref,
                  '登録', '編集するカレンダーが編集不可に設定されています。');
              return;
            }
          }

          await eventDetailNotifier.initState(event == null,
              selectDay: selectDay, selectionDateTime: selectionDateTime,
              calendar: calendarAndAddInfo!.calendar, event: event);

          // 閉じた時のスピードが遅いので保留
          /*
          if (!context.mounted) {
            return;
          }
          await Navigator.push(context,
            PageRouteBuilder(
                pageBuilder: (BuildContext context, Animation<double> animation,
                    Animation<double> secondaryAnimation) {
                    return Scaffold(
                        backgroundColor: Colors.transparent,
                        resizeToAvoidBottomInset: false,
                        body: GestureDetector(
                            onTap: () async {
                              primaryFocus?.unfocus();
                              // ハイライト解除
                              await eventDetailNotifier.updateHighlightItem(
                                  HighlightItem.none);
                            },
                            child: EventDetailPage(
                                unsafeAreaTopHeight: unsafeAreaTopHeight,
                                unsafeAreaBottomHeight: unsafeAreaBottomHeight)
                        )
                    );
                  },
                transitionDuration: const Duration(seconds: 0)
            )
          );
           */

          await homeNotifier.setUICover(true);
          await homeNotifier.setUICoverWidget(
              EventDetailPage(unsafeAreaTopHeight: unsafeAreaTopHeight,
                  unsafeAreaBottomHeight: unsafeAreaBottomHeight));
          await homeNotifier.updateState();
        },
        child: Consumer(
            builder: ((context, ref, child) {
              final calendarState = ref.watch(calendarPageNotifierProvider);
              return ImageIcon(AssetImage(calendarState.cellActive ?
                  'images/icon_add_event@3x.png'
                  : 'images/icon_edit_event@3x.png'),
                  color: Colors.white);
            })
        )
    );

    var stack = Stack(children: [
      Container(color: designConfigState.colorConfig!.backgroundColor),
      // Image.asset('images/icon_change_calendar_color@3x.png'),
      // SizedBox(width: 100, height: 100, child: Container(
      //     color: Colors.blueAccent)),
      // Image.asset('images/IMG_3173_3.jpeg'),
      SizedBox(width: deviceWidth, height: unsafeAreaTopHeight + appBarHeight,
          child: Container(color: theme.primaryColor)
      ),
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
      Column(children: [
        const Spacer(),
        Row(children: [
          const Spacer(),
          floatingActionButton,
          Container(width: 10)
        ]),
        SizedBox(width: deviceWidth, height: unsafeAreaBottomHeight)
      ]),
      if (homeState.uICover)
        Padding(padding: EdgeInsets.fromLTRB(0, unsafeAreaTopHeight,
            0, 0), child: Container(color: uIColorColor)),
      if (homeState.uICoverWidget != null)
        homeState.uICoverWidget!,
    ]);

    Widget? scaffold;
    if (!homeState.uICover) {
      scaffold = Scaffold(
          key: homePageScaffoldKey,
          resizeToAvoidBottomInset: false,
          endDrawer: EndDrawerPage(unsafeAreaTopHeight: unsafeAreaTopHeight,
              unsafeAreaBottomHeight: unsafeAreaBottomHeight),
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
    var popScope = PopScope(
        canPop: false,
        child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: scaffold
        )
    );

    return GestureDetector(
        onTap: () async {
          primaryFocus?.unfocus();
          // ハイライト解除
          await eventDetailNotifier.updateHighlightItem(
              HighlightItem.none);
        },
        child: popScope
    );
  }
}