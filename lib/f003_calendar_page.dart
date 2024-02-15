import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'f001_home_page.dart';
import 'f002_home_view_model.dart';
import 'f005_calendar_view_model.dart';
import 'f013_ui_utils.dart';
import 'f016_ui_define.dart';

class CalendarPage extends StatefulHookConsumerWidget {
  final int pageIndex;
  final double unsafeAreaTopHeight;
  final double unsafeAreaBottomHeight;

  const CalendarPage({super.key,
    required this.unsafeAreaTopHeight,
    required this.unsafeAreaBottomHeight,
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
        - eventListHeight - widget.unsafeAreaTopHeight;
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
        - widget.unsafeAreaTopHeight;

    useEffect(() {
      debugPrint('child useEffect');

      // Pageの初期化処理
      calendarNotifier.initState(() {
        homeNotifier.updateState();
      });

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        debugPrint('child addPostFrameCallback');
      });

      calendarState.calendarSwitchingController.addListener(() async {
        double offset = calendarState.calendarSwitchingController.offset;
        var index = calendarState.calendarSwitchingIndex;
        if (offset <= 0) {
          index = 0;
        } else if (offset >= monthPartHeight) {
          index = 1;
        }
        if (index != calendarState.calendarSwitchingIndex) {
          calendarState.calendarSwitchingIndex = index;
          calendarNotifier.setCalendarSwitchingPageIndex(index);
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
      controller: calendarState.monthCalendarController,
      physics: const CustomScrollPhysics(mass: 75, stiffness: 100,
          damping: 0.85),
      onPageChanged: (int index) {
        calendarNotifier.onCalendarPageChanged(index);
      },
      itemBuilder: (context, index) {
        var adjustmentIndex = index + calendarState.indexAddingMonth
            - calendarState.addingMonth;
        return monthPartList[adjustmentIndex % 3];
      },
    );

    // Week Calendar

    double dayAndWeekdayListPartWidth = 47;
    double hourPartHeight = weekPartHeight / CalendarPageState
        .hoursPartRowNum;

    var dayAndWeekdayListPart = DayAndWeekdayListPart(
        hoursPartRowNum: CalendarPageState.hoursPartRowNum,
        pageIndex: widget.pageIndex,
        hourPartWidth: dayAndWeekdayListPartWidth,
        hourPartHeight: hourPartHeight,
        dayAndWeekdayList: calendarState.dayAndWeekdayList);

    var hours = calendarState.hours;
    var hoursPartRowNum = CalendarPageState.hoursPartRowNum;
    var hoursPartCowNum = hours.length ~/ hoursPartRowNum;

    double hourPartWidth = (deviceWidth - dayAndWeekdayListPartWidth)
        / hoursPartCowNum;

    var hoursPart = HoursPart(
        hoursPartColNum: hoursPartCowNum,
        hoursPartRowNum: hoursPartRowNum,
        pageIndex: widget.pageIndex,
        hourPartWidth: hourPartWidth,
        hourPartHeight: hourPartHeight,
        onPointerDown: (int pageIndex) async {},
        onPointerUp: (int pageIndex) async {},
        hourList: calendarState.hours
    );

    var weekCalendar = Column(
        children: [
          // 週と日付部分
          Expanded(
              child: Row(children: [
                SizedBox(width: dayAndWeekdayListPartWidth,
                    child: dayAndWeekdayListPart),
                Expanded(child: hoursPart)
              ])
          ),
        ]
    );

    return SafeArea(
      bottom: false,
      child: Stack(children: [
        Column(children: [
          Expanded(
              child: PageView(
                  scrollDirection: Axis.vertical,
                  controller: calendarState.calendarSwitchingController,
                  physics: const CustomScrollPhysics(mass: 75,
                      stiffness: 100, damping: 0.85),
                  onPageChanged: (int index) {
                  },
                  children: [monthCalendar, weekCalendar]
              )
          ),
          AspectRatio(
              aspectRatio: eventListAspectRate,
              child: EventListPart(pageIndex: widget.pageIndex,
                  unsafeAreaBottomHeight: widget.unsafeAreaBottomHeight)
          )
        ]),
        Column(children: [
          const Spacer(),
          Row(children:[const Spacer(),
            SafeArea(child: ElevatedButton(
                onPressed: () async {
                  final calendarState = ref.watch(
                      calendarPageNotifierProvider(homeState.homePageIndex));
                  double prePage = calendarState.calendarSwitchingController
                      .page!;

                  int page = prePage.toInt();
                  if (page.toDouble() == prePage) {
                    page = page == 0 ? 1: 0;
                    await calendarState.calendarSwitchingController
                        .animateToPage(page, duration: const Duration(
                        milliseconds: 300), curve: Curves.easeIn);
                  }
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(32, 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(fontSize: 13),
                  padding: const EdgeInsets.all(0),
                ),
                child: Text(calendarNotifier
                    .getCalendarSwitchingButtonTitle(),
                    style: TextStyle(color: cardTextColor)
                )
            )),
            Container(width: 76)
          ])
        ])
      ]),
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
    super.parent,
    required this.mass,
    required this.stiffness,
    required this.damping,
  });

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
                isHighlightedWeek: calendarState.dayPartIndex
                    ~/ weekdayPartColumnNum == rowIndex,
                onTapDown: (int i) async {
                  await calendarNotifier.onTapDownCalendarDay(i);
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
  final bool isHighlightedWeek;
  final void Function(int) onTapDown;
  final void Function(int) onTapUp;
  final DayDisplay day;

  const DayPart({super.key,
    required this.width,
    required this.height,
    required this.index,
    required this.isHighlighted,
    required this.isActive,
    required this.isHighlightedWeek,
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
      bgColor: isHighlightedWeek ?
        day.today ? highlightedLineAndTodayBgColor : highlightedLineColor :
        day.today ? todayBgColor : Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(day.title,
              style: TextStyle(
                height: 1,
                fontSize: calendarFontSize1,
                fontWeight: calendarFontWidth1,
                color: day.titleColor,
              )
          ),
          Expanded(child:
            // Web版のスクロールバー非表示
            ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                    scrollbars: false),
                child: ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for(int i = 0; i < day.eventList.length; i++) ... {
                      Text(
                        day.eventList[i].title,
                        maxLines: 1,
                        style: TextStyle(
                            height: 1.2,
                            fontSize: calendarFontSize2,
                            fontWeight: calendarFontWidth2,
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
  final double unsafeAreaBottomHeight;

  const EventListPart({
    super.key,
    required this.pageIndex,
    required this.unsafeAreaBottomHeight,
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
                  color: eventListTitleBgColor,
                  child: Row(
                    children: [
                      Text(calendarState.eventListTitle,
                        style: TextStyle(
                            height: 1.3,
                            fontSize: eventListFontSize1,
                            fontWeight: eventListFontWidth1,
                            color: normalTextColor
                        )
                      ),
                    ],
                  )
              )
          ),
          Expanded(child:
            ListView(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 56
                    + unsafeAreaBottomHeight),
                children: [
                  if (calendarState.eventList.isEmpty)
                    EventPart(
                      pageIndex: pageIndex,
                      height: 45,
                      index: 0,
                      isHighlighted: calendarState.eventListIndex == 0,
                      onTapDown: (int i) async {
                        await calendarNotifier.selectEventListPart(0);

                        await calendarNotifier.updateState();
                      },
                      emptyMessage: 'イベントがありません',
                    ),
                  for (int i=0; i < calendarState.eventList.length; i++) ... {
                    EventPart(
                      pageIndex: pageIndex,
                      height: 45,
                      index: i,
                      isHighlighted: calendarState.eventListIndex == i,
                      onTapDown: (int i) async {
                        await calendarNotifier.selectEventListPart(i);

                        await calendarNotifier.updateState();
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
  final int pageIndex;
  final double height;
  final int index;
  final bool isHighlighted;
  final void Function(int) onTapDown;
  final String? emptyMessage;
  final EventDisplay? event;

  const EventPart({super.key,
    required this.pageIndex,
    required this.height,
    required this.index,
    required this.isHighlighted,
    required this.onTapDown,
    this.emptyMessage,
    this.event,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarNotifier = ref.watch(calendarPageNotifierProvider(pageIndex)
        .notifier);

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
                          style: TextStyle(
                            fontSize: eventListFontSize3,
                            fontWeight: eventListFontWidth3,
                            color: normalTextColor
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
                      padding: const EdgeInsets.symmetric(horizontal: 4,
                          vertical: 0),
                      child: Text(event!.title,
                          maxLines: 2, style: TextStyle(
                              height: 1.3,
                              fontSize: eventListFontSize3,
                              fontWeight: eventListFontWidth3,
                              color: event!.fontColor
                          )
                      )
                  )
                ),
              if (event != null && event!.editing && event!.sameCell)
                SizedBox(width: 41, height: 32,
                    child: TextButton(
                      onPressed: () async {
                        await calendarNotifier.selectEventListPart(index);

                        if (!await calendarNotifier.copyIndexEvent(index)) {
                          if (context.mounted) {
                            await UIUtils().showMessageDialog(context,
                                'コピー', 'コピーに失敗しました');
                          }
                        }

                        await calendarNotifier.updateCalendar();
                        await calendarNotifier.updateEventList();
                        await calendarNotifier.updateState();
                      },
                      style: TextButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 15),
                          padding: const EdgeInsets.all(0)
                      ),
                      child: const Text('コピー',
                          style: TextStyle(
                              fontSize: 13
                          )
                      ),
                    )
                ),
              if (event != null && event!.editing && !event!.sameCell)
                SizedBox(width: 41, height: 32,
                    child: TextButton(
                      onPressed: () async {
                        await calendarNotifier.selectEventListPart(index);

                        if (!await calendarNotifier.moveIndexEvent(index)) {
                          if (context.mounted) {
                            await UIUtils().showMessageDialog(context,
                                '移動', '移動に失敗しました');
                          }
                        } else {
                          await calendarNotifier.editingCancel(index);
                        }

                        await calendarNotifier.updateCalendar();
                        await calendarNotifier.updateEventList();
                        await calendarNotifier.updateState();
                      },
                      style: TextButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 15),
                          padding: const EdgeInsets.all(0)
                      ),
                      child: const Text('移動',
                          style: TextStyle(
                              fontSize: 13
                          )
                      ),
                    )
                ),
              if (event != null && event!.editing)
                SizedBox(width: 41, height: 32,
                    child: TextButton(
                      onPressed: () async {
                        await calendarNotifier.selectEventListPart(index);
                        await calendarNotifier.editingCancel(index);
                        await calendarNotifier.updateEventList();
                        await calendarNotifier.updateState();
                      },
                      style: TextButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 15),
                          padding: const EdgeInsets.all(0)
                      ),
                      child: const Text('取消',
                          style: TextStyle(
                              fontSize: 13
                          )
                      ),
                    )
                ),
              if (event != null && !event!.editing && !event!.readOnly)
                SizedBox(width: 41, height: 32,
                    child: TextButton(
                      onPressed: () async {
                        // await Future.delayed(const Duration(
                        // milliseconds: 500));

                        await calendarNotifier.selectEventListPart(index);
                        await calendarNotifier.updateState();

                        if (context.mounted) {
                          var result = await UIUtils().showMessageDialog(
                              context, '削除', 'イベントを削除しますか?', 'はい',
                              'いいえ');
                          if (result != 'positive') {
                            return;
                          }
                        }

                        if (!await calendarNotifier.deleteEvent(event!)) {
                          if (context.mounted) {
                            await UIUtils().showMessageDialog(context,
                                '削除', '削除に失敗しました');
                          }
                          return;
                        }

                        await calendarNotifier.updateCalendar();
                        await calendarNotifier.updateEventList();
                        await calendarNotifier.updateState();
                      },
                      style: TextButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 15),
                          padding: const EdgeInsets.all(0),
                          // splashFactory: NoSplash.splashFactory
                      ),
                      child: const Text('削除',
                          style: TextStyle(
                              fontSize: 13
                          )
                      ),
                    )
                ),
              if (event != null && !event!.editing && !event!.readOnly)
                SizedBox(width: 41, height: 32,
                    child: TextButton(
                      onPressed: () async {
                        await calendarNotifier.selectEventListPart(index);
                        await calendarNotifier.fixedEvent(
                            index);
                        await calendarNotifier.updateState();
                      },
                      style: TextButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 15),
                          padding: const EdgeInsets.all(0)
                      ),
                      child: const Text('固定',
                          style: TextStyle(
                              fontSize: 13
                          )
                      ),
                    )
              )
            ],
            )
        )
    );
  }
}

// Week Calendar

class DayAndWeekdayListPart extends HookConsumerWidget {
  final int pageIndex;
  final int hoursPartRowNum;
  final double hourPartWidth;
  final double hourPartHeight;
  final List<DayAndWeekdayDisplay> dayAndWeekdayList;

  const DayAndWeekdayListPart({
    super.key,
    required this.pageIndex,
    required this.hoursPartRowNum,
    required this.hourPartWidth,
    required this.hourPartHeight,
    required this.dayAndWeekdayList
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarPageNotifierProvider(pageIndex));
    return Column(children: [
      for (int rowIndex = 0; rowIndex < hoursPartRowNum; rowIndex++) ... {
        DayAndWeekdayPart(
            width: hourPartWidth,
            height: hourPartHeight,
            isHighlightedDay: calendarState.hourPartIndex
                ~/ hoursPartRowNum == rowIndex,
            dayAndWeekday: dayAndWeekdayList[rowIndex]
        ),
      }
    ]);
  }
}

class DayAndWeekdayPart extends HookConsumerWidget {
  final double width;
  final double height;
  final bool isHighlightedDay;
  final DayAndWeekdayDisplay dayAndWeekday;

  const DayAndWeekdayPart({
    super.key,
    required this.width,
    required this.height,
    required this.isHighlightedDay,
    required this.dayAndWeekday
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isHighlightedDay ?
            dayAndWeekday.today ? highlightedLineAndTodayBgColor
                : highlightedLineColor :
            dayAndWeekday.today ? todayBgColor : Colors.transparent,
          border: const Border.fromBorderSide(
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
  final int hoursPartColNum;
  final int hoursPartRowNum;
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
    required this.hoursPartColNum,
    required this.hoursPartRowNum,
    required this.onPointerDown,
    required this.onPointerUp,
    required this.hourList,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarPageNotifierProvider(
        pageIndex));
    final calendarNotifier = ref.watch(calendarPageNotifierProvider(
        pageIndex).notifier);

    return Row(children: [
      for (int colIndex = 0; colIndex < hoursPartColNum; colIndex++) ... {
        Column(
          children: [
            for (int rowIndex = 0; rowIndex < hoursPartRowNum; rowIndex++) ... {
              HourPart(width: hourPartWidth,
                height: hourPartHeight,
                index: rowIndex * hoursPartColNum + colIndex,
                isHighlighted: calendarState.hourPartIndex
                    == rowIndex * hoursPartColNum + colIndex,
                isActive: calendarState.cellActive,
                isHighlightedDayAndWeek: calendarState.hourPartIndex
                    % hoursPartColNum == colIndex
                  || calendarState.hourPartIndex
                        ~/ hoursPartRowNum == rowIndex,
                onTapDown: (int i) async {
                  await calendarNotifier.onTapDownCalendarHour(i);
                },
                onTapUp: (int i) async {
                },
                hour: hourList[rowIndex * hoursPartColNum + colIndex],
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
  final bool isHighlightedDayAndWeek;
  final void Function(int) onTapDown;
  final void Function(int) onTapUp;
  final HourDisplay hour;

  const HourPart({super.key,
    required this.width,
    required this.height,
    required this.index,
    required this.isHighlighted,
    required this.isActive,
    required this.isHighlightedDayAndWeek,
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
        bgColor: isHighlightedDayAndWeek ?
          hour.today ? highlightedLineAndTodayBgColor : highlightedLineColor :
          hour.today ? todayBgColor : Colors.transparent,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(hour.title,
                  style: TextStyle(
                  height: 1,
                  fontSize: !hour.allDay ? calendarFontSize1
                    : calendarFontSize1Down1,
                  fontWeight: calendarFontWidth1,
                  color: hour.titleColor,
                )
              ),
              Expanded(child:
                // Web版のスクロールバー非表示
                ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                        scrollbars: false),
                    child: ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        for(int i = 0; i < hour.eventList.length; i++) ... {
                          Text(hour.eventList[i].title,
                            maxLines: 1,
                            style: TextStyle(
                                height: 1.2,
                                fontSize: calendarFontSize2,
                                fontWeight: calendarFontWidth2,
                                color: hour.eventList[i].titleColor
                            ),
                          ),
                        }
                      ]
                    )
                ),
              )
            ]
        )
    );
  }
}