import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scal/f005_calendar_view_model.dart';

const borderColor = Color(0xCCDED2BF);
const double selectedBoarderWidth = 3;
const double normalBoarderWidth = 0.5;

class CalendarPage extends HookConsumerWidget {
  final double unSafeAreaTopHeight;

  const CalendarPage({super.key, required this.unSafeAreaTopHeight});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarPageNotifierProvider);
    final notifier = ref.watch(calendarPageNotifierProvider.notifier);

    useEffect(() {
      // Pageの初期化処理
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await notifier.initState();
      });

      return () {
        // Pageの解放処理
      };
    }, const []);

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
    double monthPartHeight = deviceHeight - appBarHeight - weekPartHeight
        - deviceWidth / eventListAspectRate
        - unSafeAreaTopHeight;
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
            const AspectRatio(
                aspectRatio: 1.4,
                child: EventListPart()
            )
          ],
        ),
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

class MonthPart extends HookConsumerWidget {
  final int weekPartColumnNum;
  final double weekPartAspectRate;
  final double weekPartHeight;
  final int dayPartRowNum;
  final double dayPartAspectRate;
  final double dayPartHeight;

  const MonthPart({
    super.key,
    required this.weekPartColumnNum,
    required this.weekPartAspectRate,
    required this.weekPartHeight,
    required this.dayPartRowNum,
    required this.dayPartAspectRate,
    required this.dayPartHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarPageNotifierProvider);
    final notifier = ref.watch(calendarPageNotifierProvider.notifier);

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
            DayPart(index: i,
                isHighlighted: state.dayPartIndex == i,
                isActive: state.dayPartActive,
                onTapDown: (int i) async {
                  notifier.selectDayPart(i);
                },
                height: dayPartHeight
            ),
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
                width: normalBoarderWidth
            )
        ),
      ),
    );
  }
}

class DayPart extends HookConsumerWidget {
  final int index;
  final bool isHighlighted;
  final bool isActive;
  final void Function(int) onTapDown;
  final double height;

  const DayPart({super.key,
    required this.index,
    required this.isHighlighted,
    required this.isActive,
    required this.onTapDown,
    required this.height
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SelectableCalendarCell(
        index: index,
        isHighlighted: isHighlighted,
        isActive: isActive,
        onTapDown: onTapDown,
        child: Container(),
    );
  }
}

class EventListPart extends HookConsumerWidget {
  const EventListPart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarPageNotifierProvider);
    final notifier = ref.watch(calendarPageNotifierProvider.notifier);

    return Column(
        children: [
          SizedBox(
              height: 32,
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  color: borderColor,
                  child: const Row(
                    children: [
                      Text('6月10日(土)'),
                    ],
                  )
              )
          ),
          Expanded(child:
            ListView(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
                children: [
                  for(int i=0; i < 5; i++) ... {
                    EventPart(
                      index: i,
                      isHighlighted: state.eventListIndex == i,
                      onTapDown: (int i) async {
                        notifier.selectEventListPart(i);
                      },
                    )
                  }
                ]
            )
          )
        ]
    );
  }
}

class EventPart extends HookConsumerWidget {
  final int index;
  final bool isHighlighted;
  final void Function(int) onTapDown;

  const EventPart({super.key,
    required this.index,
    required this.isHighlighted,
    required this.onTapDown,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return SelectableCalendarCell(
      index: index,
      isHighlighted: isHighlighted,
      isActive: true,
      onTapDown: onTapDown,
      child: Container(
          height: 52,
          padding: const EdgeInsets.all(selectedBoarderWidth),
        child: Row(
          children: [
            if (index != 0)
              const SizedBox(width: 45, child: Text('09:00\n18:00')),
            if (index == 0)
              const SizedBox(width: 45, child: Text('連日',
                  textAlign: TextAlign.center)),
            Container(
                padding: const EdgeInsets
                    .symmetric(horizontal: selectedBoarderWidth,
                    vertical: 0),
                child: Container(
                    width: normalBoarderWidth,
                    color: theme.colorScheme.secondaryContainer
                )
            ),
            const Expanded(child: Text('コンテムポレリダンスした日')),
            if (index == 0)
              TextButton(
                onPressed: () {
                },
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 15),
                  padding: const EdgeInsets.all(0),
                ),
                child: const Text('移動'),
              ),
            if (index == 0)
            TextButton(
              onPressed: () {
              },
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 15),
                padding: const EdgeInsets.all(0),
              ),
              child: const Text('取消'),
            ),
            if (index != 0)
            TextButton(
              onPressed: () {
              },
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 15),
                padding: const EdgeInsets.all(0),
              ),
              child: const Text('削除'),
            ),
            if (index != 0)
            TextButton(
              onPressed: () {
              },
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 15),
                padding: const EdgeInsets.all(0),
              ),
              child: const Text('詳細'),
            ),
          ],
        )
      )
    );
  }
}

class SelectableCalendarCell extends HookConsumerWidget {
  final int index;
  final bool isHighlighted;
  final bool isActive;
  final void Function(int) onTapDown;
  final Widget child;

  const SelectableCalendarCell({super.key,
    required this.index,
    required this.isHighlighted,
    required this.isActive,
    required this.onTapDown,
    required this.child
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return GestureDetector(
        onTapDown: (TapDownDetails details) => onTapDown(index),
        child:Container(
          decoration: BoxDecoration(
            border: Border.fromBorderSide(
                BorderSide(
                    color: !isHighlighted || !isActive ? borderColor
                        : theme.colorScheme.secondaryContainer,
                    width: !isHighlighted ? normalBoarderWidth
                        : selectedBoarderWidth
                )
            ),
          ),
          child: Container(
              decoration: BoxDecoration(
                border: Border.fromBorderSide(
                    BorderSide(
                        color: Colors.transparent,
                        width: !isHighlighted ? selectedBoarderWidth
                            - normalBoarderWidth : 0
                    )
                ),
              ),
              child: child),
        )
    );
  }
}