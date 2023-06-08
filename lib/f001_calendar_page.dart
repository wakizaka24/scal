import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'f002_end_drawer.dart';

const borderColor = Color(0xCCDED2BF);

class CalendarPage extends HookConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Widgetの一番上で取得可能な項目
    // アンセーフエリア上の高さ
    double unSafeAreaTopHeight = MediaQuery.of(context).padding.top;
    // アンセーフエリア下の高さ
    double unSafeAreaBottomHeight = 0;

    // 画面の幅
    double deviceWidth = MediaQuery.of(context).size.width;
    // 画面の高さ
    double deviceHeight = MediaQuery.of(context).size.height;
    // アプリバーの高さ
    double appBarHeight = AppBar().preferredSize.height;
    // 週部分の高さ
    double weekPartHeight = 32;
    // イベント一覧のアスペクト比
    double eventListAspectRate = 1.4;
    // 月部分の高さ
    double monthPartHeight = deviceHeight - deviceWidth
        / eventListAspectRate - appBarHeight - weekPartHeight
        - unSafeAreaTopHeight - unSafeAreaBottomHeight;
    // 週部分の列数
    int weekPartColumnNum = 7;
    // 週部分の幅
    double weekPartWidth = deviceWidth / weekPartColumnNum;
    // 週部分のアスペクト比
    double weekPartAspectRate = weekPartWidth / weekPartHeight;
    // 日部分の行数
    int dayPartRowNum = 6;
    // 日部分の高さ
    double dayPartHeight = monthPartHeight / dayPartRowNum;
    // 日部分のアスペクト比
    double dayPartAspectRate = weekPartWidth / dayPartHeight;

    return Scaffold(
        appBar: AppBar(
          title: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('2023年6月'),
            ],
          ),
        ),
        endDrawer: const EndDrawer(),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                  child: PageView(
                      children: [
                        for (int i=0; i < 3; i++) ... {
                          MonthPart(
                              weekPartColumnNum: weekPartColumnNum,
                              weekPartAspectRate: weekPartAspectRate,
                              weekPartHeight: weekPartHeight,
                              dayPartRowNum: dayPartRowNum,
                              dayPartAspectRate: dayPartAspectRate,
                              dayPartHeight: dayPartHeight
                          ),
                        }
                      ]
                  )
              ),
              AspectRatio(
                  aspectRatio: 1.4,
                  child: Container(color: const Color(0xCCDED2BF))
              )
            ],
          ),
        )
    );
  }
}

class MonthPart extends HookConsumerWidget {
  const MonthPart({
    super.key,
    required this.weekPartColumnNum,
    required this.weekPartAspectRate,
    required this.weekPartHeight,
    required this.dayPartRowNum,
    required this.dayPartAspectRate,
    required this.dayPartHeight,
  });

  final int weekPartColumnNum;
  final double weekPartAspectRate;
  final double weekPartHeight;
  final int dayPartRowNum;
  final double dayPartAspectRate;
  final double dayPartHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(children: [
      GridView.count(
        shrinkWrap: true,
        // physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero, // セーフエリア下非表示を無効にすると下に余白ができる
        crossAxisCount: weekPartColumnNum, // 列の数
        childAspectRatio: weekPartAspectRate, // アスペクト比
        children: [
          for (int i=0; i < weekPartColumnNum; i++) ... {
            WeekPart(height: weekPartHeight),
          }
        ],
      ),
      GridView.count(
        shrinkWrap: true,
        // physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero, // セーフエリア下非表示を無効にすると下に余白ができる
        crossAxisCount: weekPartColumnNum, // 列の数
        childAspectRatio: dayPartAspectRate, // アスペクト比
        children: [
          for (int i=0; i < weekPartColumnNum * dayPartRowNum; i++) ... {
            DayPart(height: dayPartHeight),
          }
        ],
      )
    ],);
  }
}

class WeekPart extends HookConsumerWidget {
  const WeekPart({super.key, required this.height});
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        border: Border.fromBorderSide(
            BorderSide(
                color: borderColor,
                width: 0.5
            )
        ),
      ),
    );
  }
}

class DayPart extends HookConsumerWidget {
  const DayPart({super.key, required this.height});
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        border: Border.fromBorderSide(
            BorderSide(
                color: borderColor,
                width: 0.5
            )
        ),
      ),
    );
  }
}