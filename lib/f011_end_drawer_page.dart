import 'package:flutter/cupertino.dart';
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

    const double weekButtonWidth = 35;
    var weekdayList = endDrawerState.weekdayList;
    ListView menuList = ListView(
      // physics: const NeverScrollableScrollPhysics(),
      children: [
        for (int i=0; i < EndDrawerMenuType.values.length; i++) ... {
          Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: CWTextButton(
                  title: EndDrawerMenuType.values[i].title,
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  onPressed: () async {
                    switch (EndDrawerMenuType.values[i]) {
                      case EndDrawerMenuType.softwareLicense:
                        await softwareLicenseOnPress();
                      case EndDrawerMenuType.privacyPolicyAndTermsOfUse:
                        break;
                      case EndDrawerMenuType.initialSettingsMethod:
                        break;
                    }
                  })
          )
        },

        Padding(padding: const EdgeInsets.all(8),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('祝日曜日設定',
                    style: TextStyle(
                        height: 1,
                        fontSize: eventListFontSize1,
                        fontWeight: eventListFontWeight1,
                        color: colorConfig.normalTextColor
                    )
                ),
                const SizedBox(height: 8),
                Row(children: [
                  for (int i=0; i<weekdayList.length; i++) ... {
                    CWElevatedButton(
                        title: weekdayList[i].title,
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
                const SizedBox(height: 16),
                Text('カレンダー表示設定',
                    style: TextStyle(
                        height: 1,
                        fontSize: eventListFontSize1,
                        fontWeight: eventListFontWeight1,
                        color: colorConfig.normalTextColor
                    )
                ),
                const SizedBox(height: 8),
                Text('表示切り替え',
                    style: TextStyle(
                        height: 1,
                        fontSize: eventListFontSize1,
                        fontWeight: eventListFontWeight1,
                        color: colorConfig.normalTextColor
                    )
                ),
                const SizedBox(height: 2),
                CupertinoSwitch(
                  value: false,
                  onChanged: (value) async {
                  },
                ),
                const SizedBox(height: 2),

                Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: colorConfig.borderColor,
                          width: normalBoarderWidth),
                    ),
                    alignment: Alignment.center,
                    child: Row(children: [
                      Expanded(child:
                        Container(
                            // width: 80,
                            decoration: BoxDecoration(
                              border: Border.all(color: colorConfig
                                  .borderColor,
                                  width: normalBoarderWidth),
                            ),
                            alignment: Alignment.center,
                            child: Padding(
                                padding: const EdgeInsets.all(3),
                                child: Text('アカウント',
                                    style: TextStyle(
                                        height: 1,
                                        fontSize: eventListFontSize1,
                                        fontWeight: eventListFontWeight1,
                                        color: colorConfig.normalTextColor
                                    ),
                                    strutStyle: const StrutStyle(
                                        height: 1.5,
                                        fontSize: eventListFontSize1)
                                )
                            )
                        )
                      ),
                      Expanded(child:
                        Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: colorConfig
                                  .borderColor,
                                  width: normalBoarderWidth),
                            ),
                            alignment: Alignment.center,
                            child: Padding(
                                padding: const EdgeInsets.all(3),
                                child: Text('カレンダー',
                                    style: TextStyle(
                                        height: 1,
                                        fontSize: eventListFontSize1,
                                        fontWeight: eventListFontWeight1,
                                        color: colorConfig.normalTextColor
                                    ),
                                    strutStyle: const StrutStyle(
                                        height: 1.5,
                                        fontSize: eventListFontSize1)

                                )
                            )
                        )
                      )
                    ])
                )





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