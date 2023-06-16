import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'f002_home_view_model.dart';
import 'f004_calendar_view_model.dart';

const borderColor = Color(0xCCDED2BF);
const todayBgColor = Color(0x33DED2BF);
const double selectedBoarderWidth = 2;
const double eventSelectedBoarderWidth = 2;
const double normalBoarderWidth = 0.5;

class CalendarPage extends StatefulHookConsumerWidget {
  final int pageIndex;
  final double unSafeAreaTopHeight;

  const CalendarPage({super.key, required this.unSafeAreaTopHeight,
    required this.pageIndex});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage>
    with AutomaticKeepAliveClientMixin {

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final homeState = ref.watch(homePageNotifierProvider);
    final calendarState = ref.watch(calendarPageNotifierProvider(
        widget.pageIndex));
    final homeNotifier = ref.watch(homePageNotifierProvider.notifier);
    final calendarNotifier = ref.watch(calendarPageNotifierProvider(
        widget.pageIndex).notifier);

    // 画面の幅
    double deviceWidth = MediaQuery.of(context).size.width;
    // 画面の高さ
    double deviceHeight = MediaQuery.of(context).size.height;
    // アプリバーの高さ
    //double appBarHeight = AppBar().preferredSize.height;
    double appBarHeight = homeState.appBarHeight;
    // 週部分の高さ
    double weekPartHeight = 21;
    // イベント一覧のアスペクト比
    double eventListAspectRate = 1.41421356237;
    // イベント一覧の高さ
    double eventListHeight = deviceWidth / eventListAspectRate;
    double eventListMaxHeight = 320;
    if (eventListHeight > eventListMaxHeight) {
      eventListAspectRate = deviceWidth / eventListMaxHeight;
      eventListHeight = eventListMaxHeight;
    }
    // 月部分の高さ
    double monthPartHeight = deviceHeight - appBarHeight - weekPartHeight
        - eventListHeight
        - widget.unSafeAreaTopHeight;
    // 週部分の列数
    int weekPartColumnNum = 7;
    // 週部分の幅
    double weekPartWidth = deviceWidth / weekPartColumnNum;
    // 週部分のアスペクト比
    double weekPartAspectRate = weekPartWidth / weekPartHeight;

    useEffect(() {
      debugPrint('child useEffect');
      // Pageの初期化処理
      // useEffect終了までにstateの値を設定できれば、
      // 同じ階層のWidgetのStateは反映すると推測する。
      calendarNotifier.initState(false);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        debugPrint('child addPostFrameCallback');
        // 親階層はStateの変更が反映されないので、
        // このタイミングで親階層のStateを更新する。
        homeNotifier.updateState();
      });

      calendarState.calendarController.addListener(() {
        double offset = calendarState.calendarController.offset;

        int index = 1;
        if (offset <= 0) {
          index = 0;
        } else if (offset >= deviceWidth * 2) {
          index = 2;
        }

        if (index != 1) {
          int addIndex = index - 1;
          calendarState.calendarController.jumpTo(
              offset + deviceWidth * addIndex * -1);
          calendarNotifier.onCalendarPageChanged(addIndex);
        }
      });

      return () {
        // Pageの解放処理
      };
    }, const []);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
                child: PageView(
                    controller: calendarState.calendarController,
                    children: [
                      for (int i=0; i < calendarState.dayLists.length; i++
                        ) ... {
                        MonthPart(
                          pageIndex: widget.pageIndex,
                          monthPartHeight: monthPartHeight,
                          weekPartColumnNum: weekPartColumnNum,
                          weekPartAspectRate: weekPartAspectRate,
                          weekPartWidth: weekPartWidth,
                          weekPartHeight: weekPartHeight,
                          dayList: calendarState.dayLists[i],
                        ),
                      }
                    ]
                )
            ),
            AspectRatio(
                aspectRatio: eventListAspectRate,
                child: EventListPart(pageIndex: widget.pageIndex)
            )
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class MonthPart extends HookConsumerWidget {
  final int pageIndex;
  final double monthPartHeight;
  final int weekPartColumnNum;
  final double weekPartAspectRate;
  final double weekPartWidth;
  final double weekPartHeight;
  final List<DayDisplay> dayList;

  const MonthPart({
    super.key,
    required this.pageIndex,
    required this.monthPartHeight,
    required this.weekPartColumnNum,
    required this.weekPartAspectRate,
    required this.weekPartWidth,
    required this.weekPartHeight,
    required this.dayList
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarPageNotifierProvider(pageIndex));
    final notifier = ref.watch(calendarPageNotifierProvider(pageIndex)
        .notifier);

    // 日部分の行数
    int dayPartRowNum = (dayList.length / 7).ceil();
    // 日部分の高さ
    double dayPartHeight = monthPartHeight / dayPartRowNum;
    // 日部分のアスペクト比
    double dayPartAspectRate = weekPartWidth / dayPartHeight;

    return Column(children: [
      GridView.count(
        shrinkWrap: true,
        // physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero, // セーフエリア下を無効にすると下に余白ができる
        crossAxisCount: weekPartColumnNum, // 列の数
        childAspectRatio: weekPartAspectRate, // アスペクト比
        children: [
          for (int i = 0; i < weekPartColumnNum; i++) ... {
            WeekdayPart(height: weekPartHeight, weekday: state.weekdayList[i]),
          }
        ],
      ),
      GridView.count(
        shrinkWrap: true,
        // physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero, // セーフエリア下を無効にすると下に余白ができる
        crossAxisCount: weekPartColumnNum, // 列の数
        childAspectRatio: dayPartAspectRate, // アスペクト比
        children: [
          for (int i = 0; i < weekPartColumnNum * dayPartRowNum; i++) ... {
            DayPart(index: i,
                isHighlighted: state.dayPartIndex == i,
                isActive: state.dayPartActive,
                onTapDown: (int i) async {
                  notifier.selectDayPart(i);
                },
                height: dayPartHeight,
                day: dayList[i]
            ),
          }
        ],
      )
    ],);
  }
}

class WeekdayPart extends HookConsumerWidget {
  final double height;
  final WeekdayDisplay weekday;

  const WeekdayPart({
    super.key,
    required this.height,
    required this.weekday
  });

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
      alignment: Alignment.center,
      child: Text(weekday.title,
          style: TextStyle(
            height: 1.3,
            fontSize: 11,
            color: weekday.titleColor
          )
      )
    );
  }
}

class DayPart extends HookConsumerWidget {
  final int index;
  final bool isHighlighted;
  final bool isActive;
  final void Function(int) onTapDown;
  final double height;
  final DayDisplay day;

  const DayPart({super.key,
    required this.index,
    required this.isHighlighted,
    required this.isActive,
    required this.onTapDown,
    required this.height,
    required this.day
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SelectableCalendarCell(
      index: index,
      isHighlighted: isHighlighted,
      isActive: isActive,
      onTapDown: onTapDown,
      selectedBoarderWidth: selectedBoarderWidth,
      borderCircular: 0,
      bgColor: day.bgColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(day.title,
              style: TextStyle(
                  fontSize: 11,
                  height: 1.2,
                  color: day.titleColor,
              )
          ),
          Expanded(child:
            ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                    scrollbars: false),
                child: ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for(int i = 0; i < day.eventList.length; i++) ... {
                      Text(day.eventList[i],
                        maxLines: 1,
                        style: const TextStyle(
                            fontSize: 8.8,
                            height: 1.2
                        ),
                      ),
                    }
                  ],
                )
            )
          )
        ],
      ),
    );
  }
}

class EventListPart extends HookConsumerWidget {
  final int pageIndex;

  const EventListPart({
    super.key,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarPageNotifierProvider(pageIndex));
    final notifier = ref.watch(calendarPageNotifierProvider(pageIndex)
        .notifier);

    return Column(
        children: [
          SizedBox(
              height: 24,
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  color: borderColor,
                  child: Row(
                    children: [
                      Text(state.eventListTitle,
                        style: const TextStyle(
                            height: 1.3,
                            fontSize: 13
                        )
                      ),
                    ],
                  )
              )
          ),
          Expanded(child:
            ListView(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
                children: [
                  for(int i=0; i < state.eventList.length; i++) ... {
                    EventPart(
                      index: i,
                      isHighlighted: state.eventListIndex == i,
                      onTapDown: (int i) async {
                        notifier.selectEventListPart(i);
                      },
                      event: state.eventList[i],
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
  final EventDisplay event;

  const EventPart({super.key,
    required this.index,
    required this.isHighlighted,
    required this.onTapDown,
    required this.event,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return SelectableCalendarCell(
        index: index,
        isHighlighted: isHighlighted,
        isActive: true,
        borderCircular: 10,
        selectedBoarderWidth: eventSelectedBoarderWidth,
        bgColor: Colors.transparent,
        onTapDown: onTapDown,
        child: Container(
            height: 45,
            padding: const EdgeInsets.all(selectedBoarderWidth),
          child: Row(
            children: [
              SizedBox(width: 45, child:
                Text(event.head,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 13
                    )
                )
              ),
              Container(
                  padding: const EdgeInsets
                      .symmetric(horizontal: selectedBoarderWidth,
                      vertical: 0),
                  child: Container(
                      width: normalBoarderWidth,
                      color: theme.colorScheme.secondaryContainer
                  )
              ),
              Expanded(child:
                Text(event.title,
                    style: const TextStyle(
                        fontSize: 13
                    )
                )
              ),
              if (event.editing)
                TextButton(
                  onPressed: () {
                  },
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 15),
                    padding: const EdgeInsets.all(0),
                    minimumSize: const Size(52, 32),
                  ),
                  child: const Text('移動',
                      style: TextStyle(
                          fontSize: 13
                      )
                  ),
                ),
              if (event.editing)
                TextButton(
                  onPressed: () {
                  },
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 15),
                    padding: const EdgeInsets.all(0),
                    minimumSize: const Size(52, 32),
                  ),
                  child: const Text('取消',
                      style: TextStyle(
                          fontSize: 13
                      )
                  ),
                ),
              if (!event.editing)
                TextButton(
                  onPressed: () {
                  },
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 15),
                    padding: const EdgeInsets.all(0),
                    minimumSize: const Size(52, 32),
                  ),
                  child: const Text('削除',
                      style: TextStyle(
                          fontSize: 13
                      )
                  ),
                ),
              if (!event.editing)
                TextButton(
                  onPressed: () {
                  },
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 15),
                    padding: const EdgeInsets.all(0),
                    minimumSize: const Size(52, 32),
                  ),
                  child: const Text('詳細',
                      style: TextStyle(
                          fontSize: 13
                      )
                  ),
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
  final double borderCircular;
  // 選択時の罫線の幅(通常の罫線の幅以上であること)
  final double selectedBoarderWidth;
  final Color bgColor;
  final Widget child;

  const SelectableCalendarCell({super.key,
    required this.index,
    required this.isHighlighted,
    required this.isActive,
    required this.onTapDown,
    required this.borderCircular,
    required this.selectedBoarderWidth,
    required this.bgColor,
    required this.child
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return GestureDetector(
        onTapDown: (TapDownDetails details) => onTapDown(index),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(isHighlighted
                ? borderCircular : 0),
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
                borderRadius: BorderRadius.circular(isHighlighted ?
                  borderCircular : 0),
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