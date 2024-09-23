import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scal/f017_design_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'f005_calendar_view_model.dart';
import 'f008_calendar_config.dart';
import 'f013_end_drawer_view_model.dart';
import 'f016_calendar_utils.dart';
import 'f025_common_widgets.dart';

enum EndDrawerMenuType {
  softwareLicense(title: 'ソフトウェアライセンス'),
  privacyPolicyAndTermsOfUse(title: 'プライバシーポリシー/利用規約'),
  initialSettingsMethod(title: '初期設定方法'),
  ;
  final String title;
  const EndDrawerMenuType({required this.title});
}

class EndDrawerPage extends HookConsumerWidget {
  final double unsafeAreaTopHeight;
  final double unsafeAreaBottomHeight;

  const EndDrawerPage({super.key,
    required this.unsafeAreaTopHeight,
    required this.unsafeAreaBottomHeight
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final endDrawerState = ref.watch(endDrawerPageNotifierProvider);
    final endDrawerNotifier = ref.watch(endDrawerPageNotifierProvider.notifier);
    final colorConfig = ref.watch(designConfigNotifierProvider).colorConfig!;
    // final calendarConfigState = ref.watch(calendarConfigNotifierProvider);
    final calendarConfigNotifier = ref.watch(calendarConfigNotifierProvider
        .notifier);
    final calendarNotifier = ref.watch(calendarPageNotifierProvider.notifier);

    useEffect(() {
      endDrawerNotifier.initState();
      return () {
      };
    }, const []);

    softwareLicenseOnPress() async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      if (!context.mounted) return;
      await Navigator.push(context, MaterialPageRoute(
          builder: (context) => LicensePage(
              applicationName: packageInfo.appName,
              applicationVersion: packageInfo.version
          )
      ));

      await Future.delayed(const Duration(milliseconds: 100));

      // ステータスバーの設定
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        // iOSの文字を白にする。
        statusBarBrightness: Brightness.dark,
        // Androidの文字を白にする。
        statusBarIconBrightness: Brightness.light,
        // Androidの背景色を透明にする。
        statusBarColor: Colors.transparent,
      ));
    }

    double cellHeaderHeight = 24;
    double cellSettingWidth = 62;
    final createCell = useCallback(({String? title, double? width,
      double? height = 80, Widget? child}) {
      Widget? widget = child;
      widget ??= Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: CWText(CalendarUtils().convertCharWrapString(title) ?? ' ',
              structHeight: 1.3,
              fontSize: drawerSettingItemFontSize,
              color: colorConfig.normalTextColor
          )
      );
      return SizedBox(
          width: width, height: height,
          child: CWCell(
              borderColor: colorConfig.borderColor,
              child: widget
          )
      );
    });

    final createDisplayButtonColumn = useCallback((int i) {
      return ListView(physics: const NeverScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 3),
            CWTextButton(
                title: '両方表示', // 表示 or 隠し表示 or 両方表示 or 非表示
                fontSize: drawerSettingItemFontSize,
                color: colorConfig.normalTextColor,
                padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                textPadding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
                onPressed: () async {
                }),
            CWTextButton(
                title: '編集不可',
                fontSize: drawerSettingItemFontSize,
                color: colorConfig.normalTextColor,
                padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                textPadding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
                onPressed: null),
            CWTextButton(
                title: '使用',
                fontSize: drawerSettingItemFontSize,
                color: colorConfig.normalTextColor,
                padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                textPadding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
                onPressed: () async {
                }),
            const SizedBox(height: 3),
          ]);
    });

    final createHolidayButtonColumn = useCallback((int i) {
      return ListView(physics: const NeverScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 3),
            CWTextButton(
                title: '非祝日表示',
                fontSize: drawerSettingItemFontSize,
                color: colorConfig.normalTextColor,
                padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                textPadding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
                onPressed: () async {
                }),
            const SizedBox(height: 3),
          ]);
    });

    const double weekButtonWidth = 35;
    var weekdayList = endDrawerState.weekdayList;
    var calendarList = endDrawerState.calendarList;
    ListView menuList = ListView(
      // physics: const NeverScrollableScrollPhysics(),
      children: [
        for (int i=0; i < EndDrawerMenuType.values.length; i++) ... {
          CWTextButton(
              title: EndDrawerMenuType.values[i].title,
              fontSize: drawerMenuFontSize,
              color: colorConfig.normalTextColor,
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              textPadding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
              onPressed: () async {
                switch (EndDrawerMenuType.values[i]) {
                  case EndDrawerMenuType.softwareLicense:
                    await softwareLicenseOnPress();
                  case EndDrawerMenuType.privacyPolicyAndTermsOfUse:
                    break;
                  case EndDrawerMenuType.initialSettingsMethod:
                    break;
                }
              }),
        },

        Padding(padding: const EdgeInsets.all(8),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CWText('祝日曜日設定',
                    fontSize: drawerSettingTitleFontSize,
                    fontWeight: eventListFontWeight1,
                    color: colorConfig.normalTextColor
                ),
                const SizedBox(height: 8),
                Row(children: [
                  for (int i=0; i < weekdayList.length; i++) ... {
                    if (i>0)
                      const SizedBox(width: 3),
                    CWElevatedButton(
                        title: weekdayList[i].title,
                        fontSize: drawerWeekButtonFontSize,
                        width: weekButtonWidth,
                        height: weekButtonWidth,
                        radius: weekButtonWidth / 2,
                        elevation: 0,
                        color: weekdayList[i].titleColor,
                        backgroundColor: colorConfig.cardColor,
                        onPressed: () async {
                          await calendarConfigNotifier
                              .switchCalendarHolidaySunday(i);
                          await endDrawerNotifier.updateWeekdayList();
                          await endDrawerNotifier.updateState();
                          await calendarNotifier.updateCalendar(
                              dataExclusion: true);
                          await calendarNotifier.updateState();
                        }
                    ),
                  }
                ]),
                const SizedBox(height: 15),
                CWText('カレンダー表示設定',
                    fontSize: drawerSettingTitleFontSize,
                    fontWeight: eventListFontWeight1,
                    color: colorConfig.normalTextColor
                ),
                const SizedBox(height: 8),

                CWCell(
                    borderColor: colorConfig.borderColor,
                    child: Column(children: [
                      Row(children: [
                        Expanded(child: createCell(title: 'アカウント',
                            height: cellHeaderHeight)),
                        Expanded(child: createCell(title: 'カレンダー',
                            height: cellHeaderHeight)),
                        createCell(title: '設定', width: cellSettingWidth,
                            height: cellHeaderHeight),
                        createCell(title: '祝日', width: cellSettingWidth,
                            height: cellHeaderHeight),
                      ]),

                      for (int i=0; i < calendarList.length; i++) ... {
                        Row(children: [
                          Expanded(child: createCell(
                              title: calendarList[i].accountName)),
                          Expanded(child: createCell(
                              title: calendarList[i].calendarName)),
                          createCell(width: cellSettingWidth,
                              child: createDisplayButtonColumn(0)),
                          createCell(width: cellSettingWidth,
                              child: createHolidayButtonColumn(0)),
                        ]),
                      }
                    ])
                ),
              ]
          ),

        ),
        SizedBox(height: eventListBottomSafeArea
            + unsafeAreaBottomHeight)
      ],
    );

    const double closingButtonWidth = 39;
    var drawer = Drawer(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: CWIconButton(
                    assetName: 'images/icon_close@3x.png',
                    width: closingButtonWidth,
                    height: closingButtonWidth,
                    radius: closingButtonWidth / 2,
                    foregroundColor: colorConfig.normalTextColor,
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                  )
              ),
              Expanded(child: menuList),
            ]
        )
    );

    return Column(children: [
      SizedBox(height: unsafeAreaTopHeight),
      Expanded(child: drawer)
    ]);
  }
}