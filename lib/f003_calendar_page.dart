import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'f002_home_view_model.dart';
import 'f005_calendar_view_model.dart';

const borderColor = Color(0xCCDED2BF);
const todayBgColor = Color(0x33DED2BF);
const double selectedBoarderWidth = 2;
const double eventSelectedBoarderWidth = 2;
const double normalBoarderWidth = 0.5;
const double calendarFontSize1 = 13;
const FontWeight calendarFontWidth1 = FontWeight.w300;//.w500;
const double calendarFontSize2 = 10.2;
const FontWeight calendarFontWidth2 = FontWeight.w300;//.w600;
const double eventListFontSize1 = 13.5;
const FontWeight eventListFontWidth1 = FontWeight.w300;//.w500;
const double eventListFontSize2 = 13;
const FontWeight eventListFontWidth2 = FontWeight.w300;//.w600;
const double eventListFontSize3 = 14;
const FontWeight eventListFontWidth3 = FontWeight.w300;//.w600;

class CalendarPage extends StatefulHookConsumerWidget {
  final int pageIndex;
  final double unSafeAreaTopHeight;
  final double unSafeAreaBottomHeight;

  const CalendarPage({super.key,
    required this.unSafeAreaTopHeight,
    required this.unSafeAreaBottomHeight,
    required this.pageIndex});

  @override
  ConsumerState<ConsumerStatefulWidget> createState()
    => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage>
    with AutomaticKeepAliveClientMixin {
  // Common
  double preDeviceWidth = 0;
  double preDeviceHeight = 0;

  // Month Calendar
  List<MonthPart> monthPartList = [];

  // Week Calendar
  List<DaysAndWeekdaysPart> daysAndWeekdaysPartList = [];
  List<List<HoursPart>> weeksPartLists = [];

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final homeState = ref.watch(homePageNotifierProvider);
    final calendarState = ref.watch(calendarPageNotifierProvider(
        widget.pageIndex));
    final homeNotifier = ref.watch(homePageNotifierProvider.notifier);
    final calendarNotifier = ref.watch(calendarPageNotifierProvider(
        widget.pageIndex).notifier);

    // Month Calendar/Week Calendar
    // 画面の幅
    double deviceWidth = MediaQuery.of(context).size.width;
    // 画面の高さ
    double deviceHeight = MediaQuery.of(context).size.height;
    // アプリバーの高さ
    //double appBarHeight = AppBar().preferredSize.height;
    double appBarHeight = homeState.appBarHeight;
    // イベント一覧のアスペクト比
    double eventListAspectRate = 1.41421356237;
    // イベント一覧の高さ
    double eventListHeight = deviceWidth / eventListAspectRate;
    double eventListMaxHeight = 320;

    // Month Calendar
    // 週部分の高さ
    double weekdayPartHeight = 21;
    if (eventListHeight > eventListMaxHeight) {
      eventListAspectRate = deviceWidth / eventListMaxHeight;
      eventListHeight = eventListMaxHeight;
    }
    // 月部分の高さ
    double monthPartHeight = deviceHeight - appBarHeight - weekdayPartHeight
        - eventListHeight - widget.unSafeAreaTopHeight;
    // 週部分の幅
    double weekdayPartWidth = deviceWidth / CalendarPageState
        .weekdayPartColNum;

    // Week Calendar
    if (eventListHeight > eventListMaxHeight) {
      eventListAspectRate = deviceWidth / eventListMaxHeight;
      eventListHeight = eventListMaxHeight;
    }
    // 週部分の高さ
    double weekPartHeight = deviceHeight - appBarHeight - eventListHeight
        - widget.unSafeAreaTopHeight;

    useEffect(() {
      debugPrint('child useEffect');

      // Pageの初期化処理
      calendarNotifier.initState(() {
        homeNotifier.updateState();
      });

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        debugPrint('child addPostFrameCallback');
      });

      // Week Calendar
      calendarState.hourCalendarControllers[1].addListener(() {
        try {
          // calendarState.hourCalendarControllers[0].jumpTo(
          //     calendarState.hourCalendarControllers[1].offset);
          // calendarState.hourCalendarControllers[2].jumpTo(
          //     calendarState.hourCalendarControllers[1].offset);
        } catch (e) {
          // 横スクロール中に縦スクロールをするとエラーになる。
          // 横スクロール中に離し、戻る途中で縦スクロールでエラーになる。
          // 'package:flutter/src/widgets/scroll_controller.dart':
          // Failed assertion: line 106 pos 12: '_positions.length == 1':
          // ScrollController attached to multiple scroll views.
          debugPrint('横スクロールの同期でエラー');
          debugPrint(e.toString());
        }
      });

      calendarState.weekCalendarController.addListener(() {
        try {
          calendarState.daysAndWeekdaysController.jumpTo(
              calendarState.weekCalendarController.offset);
        } catch (e) {
          // 横スクロール中に縦スクロールをするとエラーになる。
          // 'package:flutter/src/widgets/scroll_controller.dart':
          // Failed assertion: line 106 pos 12: '_positions.length == 1':
          // ScrollController attached to multiple scroll views.
          // debugPrint(e.toString());
          debugPrint('縦スクロールの同期でエラー');
        }
      });

      return () {
        // Pageの解放処理
      };
    }, const []);

    // Month Calendar
    if (preDeviceWidth != deviceWidth || preDeviceHeight != deviceHeight
      || calendarState.monthCalendarReload) {
      calendarState.monthCalendarReload = false;

      // for (int i = 0; i < 3; i++) {
      //   debugPrint('表示月:${calendarState.dayLists[i][0].id}');
      // }

      monthPartList = calendarState.dayLists.map((dayList) => MonthPart(
          pageIndex: widget.pageIndex,
          monthPartHeight: monthPartHeight,
          weekdayPartColumnNum: CalendarPageState.weekdayPartColNum,
          weekdayPartWidth: weekdayPartWidth,
          weekdayPartHeight: weekdayPartHeight,
          onPointerDown: (int pageIndex) async {},
          onPointerUp: (int pageIndex) async {},
          dayList: dayList,
        )
      ).toList();
    }

    var monthCalendar = PageView.builder(
      // pageSnapping: false,
      controller: calendarState.monthCalendarController,
      physics: const CustomScrollPhysics(mass: 75, stiffness: 100,
          damping: 0.85),
      onPageChanged: (int index) {
        calendarNotifier.onCalendarPageChanged(index);
      },
      itemBuilder: (context, index) {
        var adjustmentIndex = index - calendarState.addingMonth;
        return monthPartList[adjustmentIndex % 3];
      },
    );

    // Week Calendar
    double daysAndWeekdaysPartWidth = 47;
    if (preDeviceWidth != deviceWidth || preDeviceHeight != deviceHeight
        || calendarState.weekCalendarReload) {
      calendarState.weekCalendarReload = false;

      double hourPartWidth = (deviceWidth - daysAndWeekdaysPartWidth)
          / (CalendarPageState.timePartColNum + 1);
      double hourPartHeight = weekPartHeight / CalendarPageState
          .weekdayPartRowNum;

      // for (int i = 0; i < 3; i++) {
      //   debugPrint('表示月:${calendarState.dayLists[i][0].id}');
      // }

      daysAndWeekdaysPartList = calendarState.daysAndWeekdaysList
          .map((daysAndWeekdays) => DaysAndWeekdaysPart(
        weekPartRowNum: CalendarPageState.weekdayPartRowNum,
        pageIndex: widget.pageIndex,
        hourPartWidth: daysAndWeekdaysPartWidth,
        hourPartHeight: hourPartHeight,
        daysAndWeekdays: daysAndWeekdays,
      )
      ).toList();

      weeksPartLists = calendarState.hoursListsList.map((hourLists) {
        return hourLists.map((hourList) {
          return HoursPart(
              weekPartColNum: CalendarPageState.timePartColNum,
              weekPartRowNum: CalendarPageState.weekdayPartRowNum,
              pageIndex: widget.pageIndex,
              hourPartWidth: hourPartWidth,
              hourPartHeight: hourPartHeight,
              onPointerDown: (int pageIndex) async {},
              onPointerUp: (int pageIndex) async {},
              hourList: hourList
          );
        }).toList();
      }).toList();
    }

    var daysAndWeekPageView = PageView.builder(
      scrollDirection: Axis.vertical,
      pageSnapping: false,
      controller: calendarState.daysAndWeekdaysController,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: (int index) {
      },
      itemBuilder: (context, index) {
        var adjustmentIndex = index - calendarState.addingWeek;
        return daysAndWeekdaysPartList[adjustmentIndex % 3];
      },
    );

    var hourPageViews = weeksPartLists.asMap().entries.map((entry) {
      var weeksPartList = entry.value;
      var i = entry.key;
      return NotificationListener(
        child: PageView.builder(
          // pageSnapping: false,
          controller: calendarState.hourCalendarControllers[i],
          physics: const CustomScrollPhysics(mass: 75, stiffness: 100,
              damping: 0.85),
          onPageChanged: (int index) {
            debugPrint('hourPageViews index=$index');
            calendarNotifier.onHourCalendarPageChanged(index);
            //calendarState.weekCalendarController.load
          },
          itemBuilder: (context, index) {
            var adjustmentIndex = index
                + calendarState.baseAddingHourPart
                + calendarState.indexAddingHourPart
                - calendarState.addingHourPart;
            return weeksPartList[adjustmentIndex % 3];
          },
        ),
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollStartNotification) {
            // debugPrint('start1');
            calendarNotifier.updateState();
          } else if (scrollNotification is ScrollUpdateNotification) {
            // debugPrint('update');
          } else if (scrollNotification is ScrollEndNotification) {
            // debugPrint('end');
            calendarNotifier.updateState();
          }
          return false;
        },
      );
    }).toList();

    var weeksPageView = NotificationListener(
      child: PageView.builder(
        scrollDirection: Axis.vertical,
        // pageSnapping: false,
        controller: calendarState.weekCalendarController,
        physics: const CustomScrollPhysics(mass: 75, stiffness: 100,
            damping: 0.85),
        onPageChanged: (int index) {
          calendarNotifier.onWeekCalendarPageChanged(index);
        },
        itemBuilder: (context, index) {
          var adjustmentIndex = index - calendarState.addingWeek;
          return hourPageViews[adjustmentIndex % 3];
        },
      ),
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollStartNotification) {
          // debugPrint('start2');
        } else if (scrollNotification is ScrollUpdateNotification) {
        } else if (scrollNotification is ScrollEndNotification) {
        }
        return false;
      },
    );

    var weekCalendar = Column(
        children: [
          // 週と日付部分
          Expanded(
              child: Row(children: [
                SizedBox(width: daysAndWeekdaysPartWidth,
                    child: daysAndWeekPageView),
                Expanded(child: weeksPageView)
              ])
          ),
        ]
    );

    var calendarWidgets = [monthCalendar, weekCalendar];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
                child: PageView(
                    scrollDirection: Axis.vertical,
                    controller: calendarState.calendarSwitchingController,
                    physics: const CustomScrollPhysics(mass: 75, stiffness: 100,
                        damping: 0.85),
                    onPageChanged: (int index) {
                      // calendarNotifier.onCalendarPageChanged(index);
                    },
                    children: calendarWidgets
                )
            ),
            AspectRatio(
                aspectRatio: eventListAspectRate,
                child: EventListPart(pageIndex: widget.pageIndex,
                    unSafeAreaBottomHeight: widget.unSafeAreaBottomHeight)
            )
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

// Common
class CustomScrollPhysics extends ScrollPhysics {
  final double mass; // 速度(50)
  final double stiffness; // 100
  final double damping; // 0.85

  const CustomScrollPhysics({
    ScrollPhysics? parent,
    required this.mass,
    required this.stiffness,
    required this.damping,
  }) : super(parent: parent);

  @override
  CustomScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomScrollPhysics(parent: buildParent(ancestor)!,
      mass: mass, stiffness: stiffness, damping: damping);
  }

  @override
  SpringDescription get spring => SpringDescription(
    mass: mass,
    stiffness: stiffness,
    damping: damping,
  );
}

class SelectableCalendarCell extends HookConsumerWidget {
  final double? width;
  final double height;
  final int index;
  final bool isHighlighted;
  final bool isActive;
  final void Function(int) onTapDown;
  final void Function(int) onTapUp;
  final double borderCircular;
  // 選択時の罫線の幅(通常の罫線の幅以上であること)
  final double selectedBoarderWidth;
  final Color bgColor;
  final Widget child;

  const SelectableCalendarCell({super.key,
    this.width,
    required this.height,
    required this.index,
    required this.isHighlighted,
    required this.isActive,
    required this.onTapDown,
    required this.onTapUp,
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
        onTapUp: (TapUpDetails event) => onTapUp(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: height,
          width: width,
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

// Month Calendar

class MonthPart extends HookConsumerWidget {
  final int pageIndex;
  final double monthPartHeight;
  final int weekdayPartColumnNum;
  final double weekdayPartWidth;
  final double weekdayPartHeight;
  final void Function(int) onPointerDown;
  final void Function(int) onPointerUp;
  final List<DayDisplay> dayList;

  const MonthPart({
    super.key,
    required this.pageIndex,
    required this.monthPartHeight,
    required this.weekdayPartColumnNum,
    required this.weekdayPartWidth,
    required this.weekdayPartHeight,
    required this.onPointerDown,
    required this.onPointerUp,
    required this.dayList,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarPageNotifierProvider(pageIndex));
    final calendarNotifier = ref.watch(calendarPageNotifierProvider(pageIndex)
        .notifier);

    // 日部分の行数
    int dayPartRowNum = (dayList.length / calendarState.weekdayList
        .length).ceil();
    // 日部分の高さ
    double dayPartHeight = monthPartHeight / dayPartRowNum;

    return Column(children: [
      Row(
        children: [
          for (int colIndex = 0; colIndex < weekdayPartColumnNum;
            colIndex++) ... {
            WeekdayPart(width: weekdayPartWidth, height: weekdayPartHeight,
              weekday: calendarState.weekdayList[colIndex]),
          }
        ],
      ),
      for (int rowIndex = 0; rowIndex < dayPartRowNum; rowIndex++) ... {
        Row(
          children: [
            for (int colIndex = 0; colIndex < weekdayPartColumnNum;
              colIndex++) ... {
              DayPart(width: weekdayPartWidth,
                height: dayPartHeight,
                index: rowIndex * weekdayPartColumnNum + colIndex,
                isHighlighted: calendarState.dayPartIndex
                    == rowIndex * weekdayPartColumnNum + colIndex,
                isActive: calendarState.cellActive,
                onTapDown: (int i) async {
                  if (calendarState.dayPartIndex != i) {
                    calendarNotifier.selectDay(index: i);
                  } else {
                    // Navigator.push(context,
                    //   MaterialPageRoute(builder: (context) =>
                    //       WeekCalendarPage(pageIndex: pageIndex)),
                    // );
                  }
                },
                onTapUp: (int i) async {
                },
                day: dayList[rowIndex * weekdayPartColumnNum + colIndex],
              ),
            }
          ],
        ),
      }
    ],);
  }
}

class WeekdayPart extends HookConsumerWidget {
  final double width;
  final double height;
  final WeekdayDisplay weekday;

  const WeekdayPart({
    super.key,
    required this.width,
    required this.height,
    required this.weekday
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
        width: width,
        height: height,
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
            textAlign: TextAlign.center,
            style: TextStyle(
              height: 1.3,
              fontSize: calendarFontSize1,
              fontWeight: calendarFontWidth1,
              color: weekday.titleColor,
            )
        )
    );
  }
}

class DayPart extends HookConsumerWidget {
  final double width;
  final double height;
  final int index;
  final bool isHighlighted;
  final bool isActive;
  final void Function(int) onTapDown;
  final void Function(int) onTapUp;
  final DayDisplay day;

  const DayPart({super.key,
    required this.width,
    required this.height,
    required this.index,
    required this.isHighlighted,
    required this.isActive,
    required this.onTapDown,
    required this.onTapUp,
    required this.day
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SelectableCalendarCell(
      width: width,
      height: height,
      index: index,
      isHighlighted: isHighlighted,
      isActive: isActive,
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      selectedBoarderWidth: selectedBoarderWidth,
      borderCircular: 0,
      bgColor: day.bgColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(day.title,
              style: TextStyle(
                  fontSize: calendarFontSize1,
                  fontWeight: calendarFontWidth1,
                  height: 1,
                  color: day.titleColor,
              )
          ),
          Expanded(child:
            // Webビューのスクロールバー非表示
            ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                    scrollbars: false),
                child: ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for(int i = 0; i < day.eventList.length; i++) ... {
                      Text(day.eventList[i].title,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: calendarFontSize2,
                            fontWeight: calendarFontWidth2,
                            height: 1.2,
                            color: day.eventList[i].titleColor
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

// Event List

class EventListPart extends HookConsumerWidget {
  final int pageIndex;
  final double unSafeAreaBottomHeight;

  const EventListPart({
    super.key,
    required this.pageIndex,
    required this.unSafeAreaBottomHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarPageNotifierProvider(pageIndex));
    final calendarNotifier = ref.watch(calendarPageNotifierProvider(pageIndex)
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
                      Text(calendarState.eventListTitle,
                        style: const TextStyle(
                            height: 1.3,
                            fontSize: eventListFontSize1,
                            fontWeight: eventListFontWidth1,
                            color: Colors.black
                        )
                      ),
                    ],
                  )
              )
          ),
          Expanded(child:
            ListView(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 56
                    + unSafeAreaBottomHeight),
                children: [
                  if (calendarState.eventList.isEmpty)
                    EventPart(
                      height: 45,
                      index: 0,
                      isHighlighted: calendarState.eventListIndex == 0,
                      onTapDown: (int i) async {
                        calendarNotifier.selectEventListPart(0);
                      },
                      emptyMessage: 'イベントがありません',
                    ),
                  for(int i=0; i < calendarState.eventList.length; i++) ... {
                    EventPart(
                      height: 45,
                      index: i,
                      isHighlighted: calendarState.eventListIndex == i,
                      onTapDown: (int i) async {
                        calendarNotifier.selectEventListPart(i);
                      },
                      event: calendarState.eventList[i],
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
  final double height;
  final int index;
  final bool isHighlighted;
  final void Function(int) onTapDown;
  final String? emptyMessage;
  final EventDisplay? event;

  const EventPart({super.key,
    required this.height,
    required this.index,
    required this.isHighlighted,
    required this.onTapDown,
    this.emptyMessage,
    this.event,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SelectableCalendarCell(
        height: 45,
        index: index,
        isHighlighted: isHighlighted,
        isActive: true,
        borderCircular: 10,
        selectedBoarderWidth: eventSelectedBoarderWidth,
        bgColor: Colors.transparent,
        onTapDown: onTapDown,
        onTapUp: (int i) async {
        },
        child: Container(
            padding: const EdgeInsets.all(selectedBoarderWidth),
          child: Row(
            children: [
              if (emptyMessage != null)
                Expanded(child:
                  Container(
                      padding: const EdgeInsets
                          .symmetric(horizontal: 8,
                          vertical: 0),
                      child: Text(emptyMessage!,
                          maxLines: 2,
                          style: const TextStyle(
                            fontSize: eventListFontSize3,
                            fontWeight: eventListFontWidth3,
                            color: Colors.black
                          )
                      )
                  )
                ),
              if (event != null)
                SizedBox(width: 45, child:
                  Text(event!.head,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: eventListFontSize2,
                          fontWeight: eventListFontWidth2,
                          color: event!.fontColor
                      )
                  )
                ),
              if (event != null)
                Container(
                    padding: const EdgeInsets
                        .symmetric(horizontal: selectedBoarderWidth,
                        vertical: 0),
                    child: Container(
                        width: normalBoarderWidth * 2,
                        color: event!.lineColor
                    )
                ),
              if (event != null)
                Expanded(child:
                  Container(
                      padding: const EdgeInsets
                          .symmetric(horizontal: 4,
                          vertical: 0),
                      child:
                      Text(event!.title, maxLines: 2,
                        style: TextStyle(
                          height: 1.3,
                            fontSize: eventListFontSize3,
                            fontWeight: eventListFontWidth3,
                            color: event!.fontColor
                        )
                    )
                  )
                ),
              if (event != null && event!.editing)
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
              if (event != null && event!.editing)
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
              if (event != null && !event!.editing)
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
              if (event != null && !event!.editing)
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

// Week Calendar

class HourTitlesPart extends HookConsumerWidget {
  final int weekPartColNum;
  final int pageIndex;
  final double hourPartWidth;
  final double hourPartHeight;
  final List<HourTitleDisplay> hourTitleList;
  final HourTitleDisplay allDayTitle;

  const HourTitlesPart({
    super.key,
    required this.weekPartColNum,
    required this.pageIndex,
    required this.hourPartWidth,
    required this.hourPartHeight,
    required this.hourTitleList,
    required this.allDayTitle
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(children: [
      for (int colIndex = 0; colIndex < weekPartColNum; colIndex++) ... {
        HourTitlePart(
            width: hourPartWidth,
            height: hourPartHeight,
            hourTitle: hourTitleList[colIndex]
        ),
      },
      HourTitlePart(
          width: hourPartWidth,
          height: hourPartHeight,
          hourTitle: allDayTitle
      ),
    ]);
  }
}

class HourTitlePart extends HookConsumerWidget {
  final double width;
  final double height;
  final HourTitleDisplay hourTitle;

  const HourTitlePart({
    super.key,
    required this.width,
    required this.height,
    required this.hourTitle
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          border: Border.fromBorderSide(
              BorderSide(
                  color: borderColor,
                  width: normalBoarderWidth
              )
          ),
        ),
        alignment: Alignment.center,
        child: Text(hourTitle.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              height: 1.3,
              fontSize: calendarFontSize1,
              fontWeight: calendarFontWidth1,
              color: hourTitle.titleColor,
            )
        )
    );
  }
}

class DaysAndWeekdaysPart extends HookConsumerWidget {
  final int weekPartRowNum;
  final int pageIndex;
  final double hourPartWidth;
  final double hourPartHeight;
  final List<DayAndWeekdayDisplay> daysAndWeekdays;

  const DaysAndWeekdaysPart({
    super.key,
    required this.weekPartRowNum,
    required this.pageIndex,
    required this.hourPartWidth,
    required this.hourPartHeight,
    required this.daysAndWeekdays
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(children: [
      for (int rowIndex = 0; rowIndex < weekPartRowNum; rowIndex++) ... {
        DayAndWeekdayPart(
            width: hourPartWidth,
            height: hourPartHeight,
            dayAndWeekday: daysAndWeekdays[rowIndex]
        ),
      }
    ]);
  }
}

class DayAndWeekdayPart extends HookConsumerWidget {
  final double width;
  final double height;
  final DayAndWeekdayDisplay dayAndWeekday;

  const DayAndWeekdayPart({
    super.key,
    required this.width,
    required this.height,
    required this.dayAndWeekday
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          border: Border.fromBorderSide(
              BorderSide(
                  color: borderColor,
                  width: normalBoarderWidth
              )
          ),
        ),
        alignment: Alignment.center,
        child: Text(dayAndWeekday.dayAndWeekTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              height: 1.3,
              fontSize: calendarFontSize1,
              fontWeight: calendarFontWidth1,
              color: dayAndWeekday.dayAndWeekTitleColor,
            )
        )
    );
  }
}

class HoursPart extends HookConsumerWidget {
  final int weekPartColNum;
  final int weekPartRowNum;
  final int pageIndex;
  final double hourPartWidth;
  final double hourPartHeight;
  final void Function(int) onPointerDown;
  final void Function(int) onPointerUp;
  final List<HourDisplay> hourList;

  const HoursPart({
    super.key,
    required this.hourPartWidth,
    required this.hourPartHeight,
    required this.pageIndex,
    required this.weekPartColNum,
    required this.weekPartRowNum,
    required this.onPointerDown,
    required this.onPointerUp,
    required this.hourList,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekCalendarState = ref.watch(calendarPageNotifierProvider(
        pageIndex));
    final weekCalendarNotifier = ref.watch(calendarPageNotifierProvider(
        pageIndex).notifier);

    return Row(children: [
      for (int colIndex = 0; colIndex < weekPartColNum + 1; colIndex++) ... {
        Column(
          children: [
            for (int rowIndex = 0; rowIndex < weekPartRowNum; rowIndex++) ... {
              HourPart(width: hourPartWidth,
                height: hourPartHeight,
                index: rowIndex * (weekPartColNum + 1) + colIndex,
                isHighlighted: weekCalendarState.hourPartIndex
                    == rowIndex * (weekPartColNum + 1) + colIndex,
                isActive: weekCalendarState.cellActive,
                onTapDown: (int i) async {
                  if (weekCalendarState.hourPartIndex != i) {
                    weekCalendarNotifier.selectHour(index: i);
                  } else {
                    // Navigator.pop(context);
                  }
                },
                onTapUp: (int i) async {
                },
                hour: hourList[rowIndex * (weekPartColNum + 1) + colIndex],
              ),
            }
          ],
        ),
      }
    ],);
  }
}

class HourPart extends HookConsumerWidget {
  final double width;
  final double height;
  final int index;
  final bool isHighlighted;
  final bool isActive;
  final void Function(int) onTapDown;
  final void Function(int) onTapUp;
  final HourDisplay hour;

  const HourPart({super.key,
    required this.width,
    required this.height,
    required this.index,
    required this.isHighlighted,
    required this.isActive,
    required this.onTapDown,
    required this.onTapUp,
    required this.hour
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SelectableCalendarCell(
      width: width,
      height: height,
      index: index,
      isHighlighted: isHighlighted,
      isActive: isActive,
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      selectedBoarderWidth: selectedBoarderWidth,
      borderCircular: 0,
      bgColor: hour.bgColor,
      // Webビューのスクロールバー非表示
      child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for(int i = 0; i < hour.eventList.length; i++) ... {
                Text(hour.eventList[i].title,
                  maxLines: 1,
                  style: TextStyle(
                      fontSize: calendarFontSize2,
                      fontWeight: calendarFontWidth2,
                      height: 1.2,
                      color: hour.eventList[i].titleColor
                  ),
                ),
              }
            ],
          )
      ),
    );
  }
}