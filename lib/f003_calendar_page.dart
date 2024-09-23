import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'f001_home_page.dart';
import 'f005_calendar_view_model.dart';
import 'f015_ui_utils.dart';
import 'f016_calendar_utils.dart';
import 'f017_design_config.dart';
import 'f025_common_widgets.dart';

class CalendarPage extends StatefulHookConsumerWidget {
  final double unsafeAreaTopHeight;
  final double unsafeAreaBottomHeight;

  const CalendarPage({super.key,
    required this.unsafeAreaTopHeight,
    required this.unsafeAreaBottomHeight});

  @override
  ConsumerState<ConsumerStatefulWidget> createState()
    => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage>
    with AutomaticKeepAliveClientMixin {

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final calendarState = ref.watch(calendarPageNotifierProvider);
    final calendarNotifier = ref.watch(calendarPageNotifierProvider
        .notifier);
    final colorConfig = ref.watch(designConfigNotifierProvider).colorConfig!;

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
    double dayAndWeekdayListPartWidth = 47;
    var hours = calendarState.hours;
    var hoursPartRowNum = CalendarPageState.hoursPartRowNum;
    var hoursPartCowNum = hours.length ~/ hoursPartRowNum;
    double hourPartWidth = (deviceWidth - dayAndWeekdayListPartWidth)
        / hoursPartCowNum;
    double hourPartHeight = weekPartHeight / CalendarPageState
        .hoursPartRowNum;

    useEffect(() {
      debugPrint('child useEffect');

      calendarNotifier.initState();

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
      };
    }, const []);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var scrollEventListIndex = calendarState.scrollEventListIndex;
      if (scrollEventListIndex != null) {
        calendarState.scrollEventListIndex = null;
        var context = calendarState.eventListCellKeyList[scrollEventListIndex]
            .currentContext;
        if (context != null) {
          Scrollable.ensureVisible(
            context,
            alignment: 0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.linear,
          );
        }
      }
    });

    return Stack(children: [
      Column(children: [
        Expanded(
            child: PageView.builder(
                controller: calendarState.calendarSwitchingController,
                physics: const CustomScrollPhysics(mass: 75,
                    stiffness: 100, damping: 0.85),
                //physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                onPageChanged: (int index) {
                },
                itemCount: 2,
                itemBuilder: (context, index) {
                  return [MonthCalendarPage(
                      weekdayPartWidth: weekdayPartWidth,
                      weekdayPartHeight: weekdayPartHeight,
                      monthPartHeight: monthPartHeight
                  ), WeekCalendarPage(
                      hoursPartCowNum: hoursPartCowNum,
                      hoursPartRowNum: hoursPartRowNum,
                      dayAndWeekdayListPartWidth: dayAndWeekdayListPartWidth,
                      hourPartWidth: hourPartWidth,
                      hourPartHeight: hourPartHeight
                  )][index];
                }
            )
        ),
        AspectRatio(
            aspectRatio: eventListAspectRate,
            child: EventListPart(unsafeAreaBottomHeight:
            widget.unsafeAreaBottomHeight)
        )
      ]),
      Column(children: [
        const Spacer(),
        Row(children:[
          const Spacer(),
          CWElevatedButton(
              title: calendarNotifier.getCalendarSwitchingButtonTitle(),
              color: colorConfig.cardTextColor,
              backgroundColor: colorConfig.cardColor,
              onPressed: () async {
                final calendarState = ref.watch(calendarPageNotifierProvider);
                double prePage = calendarState.calendarSwitchingController
                    .page!;

                int page = prePage.toInt();
                if (page.toDouble() == prePage) {
                  page = page == 0 ? 1: 0;
                  await calendarState.calendarSwitchingController
                      .animateToPage(page, duration: const Duration(
                      milliseconds: 150), curve: Curves.easeIn);
                }
              }
          ),
          Container(width: 76)
        ]),
        SizedBox(width: deviceWidth, height: widget.unsafeAreaBottomHeight)
      ])
    ]);
  }

  @override
  bool get wantKeepAlive => true;
}

class MonthCalendarPage extends StatefulHookConsumerWidget {
  final double weekdayPartWidth;
  final double weekdayPartHeight;
  final double monthPartHeight;

  const MonthCalendarPage({super.key,
    required this.weekdayPartWidth,
    required this.weekdayPartHeight,
    required this.monthPartHeight
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState()
  => _MonthCalendarPageState();
}

class _MonthCalendarPageState extends ConsumerState<MonthCalendarPage>
    with AutomaticKeepAliveClientMixin {

  // Month Calendar
  List<MonthPart> monthPartList = [];

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final calendarState = ref.watch(calendarPageNotifierProvider);
    final calendarNotifier = ref.watch(calendarPageNotifierProvider.notifier);

    // Month Calendar
    // for (int i = 0; i < 3; i++) {
    //   debugPrint('表示月:${calendarState.dayLists[i][0].id}');
    // }

    monthPartList = calendarState.dayLists.map((dayList) => MonthPart(
      monthPartHeight: widget.monthPartHeight,
      weekdayPartColumnNum: CalendarPageState.weekdayPartColNum,
      weekdayPartWidth: widget.weekdayPartWidth,
      weekdayPartHeight: widget.weekdayPartHeight,
      onPointerDown: (int pageIndex) async {},
      onPointerUp: (int pageIndex) async {},
      dayList: dayList,
    )).toList();

    return PageView.builder(
      controller: calendarState.monthCalendarController,
      physics: const CustomScrollPhysics(mass: 75, stiffness: 100,
          damping: 0.85),
      onPageChanged: (int index) async {
        await calendarNotifier.onCalendarPageChanged(index);
      },
      itemBuilder: (context, index) {
        var adjustmentIndex = index - calendarState.addingMonth;
        return monthPartList[adjustmentIndex % 3];
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class WeekCalendarPage extends StatefulHookConsumerWidget {
  final int hoursPartCowNum;
  final int hoursPartRowNum;
  final double dayAndWeekdayListPartWidth;
  final double hourPartWidth;
  final double hourPartHeight;

  const WeekCalendarPage({super.key,
    required this.hoursPartCowNum,
    required this.hoursPartRowNum,
    required this.dayAndWeekdayListPartWidth,
    required this.hourPartWidth,
    required this.hourPartHeight
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState()
  => _WeekCalendarPageState();
}

class _WeekCalendarPageState extends ConsumerState<WeekCalendarPage>
    with AutomaticKeepAliveClientMixin {

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final calendarState = ref.watch(calendarPageNotifierProvider);

    // Week Calendar
    var dayAndWeekdayListPart = DayAndWeekdayListPart(
        hoursPartRowNum: CalendarPageState.hoursPartRowNum,
        hourPartWidth: widget.dayAndWeekdayListPartWidth,
        hourPartHeight: widget.hourPartHeight,
        dayAndWeekdayList: calendarState.dayAndWeekdayList);

    var hoursPart = HoursPart(
        hoursPartColNum: widget.hoursPartCowNum,
        hoursPartRowNum: widget.hoursPartRowNum,
        hourPartWidth: widget.hourPartWidth,
        hourPartHeight: widget.hourPartHeight,
        onPointerDown: (int pageIndex) async {},
        onPointerUp: (int pageIndex) async {},
        hourList: calendarState.hours
    );

    var weekCalendar = Column(
        children: [
          // 週と日付部分
          Expanded(
              child: Row(children: [
                SizedBox(width: widget.dayAndWeekdayListPartWidth,
                    child: dayAndWeekdayListPart),
                Expanded(child: hoursPart)
              ])
          ),
        ]
    );

    return weekCalendar;
  }

  @override
  bool get wantKeepAlive => true;
}

// Common
class CustomScrollPhysics extends ClampingScrollPhysics {
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
  final bool topBorderWide;
  final bool rightBorderWide;
  final bool bottomBorderWide;
  final bool leftBorderWide;
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
    required this.topBorderWide,
    required this.rightBorderWide,
    required this.bottomBorderWide,
    required this.leftBorderWide,
    required this.child
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorConfig = ref.watch(designConfigNotifierProvider).colorConfig;

    var borderColor = colorConfig!.borderColor;
    var border1 = BorderSide(
        color: !isHighlighted || !isActive ? borderColor
            : colorConfig.accentColor,
        width: !isHighlighted ? normalBoarderWidth
            : selectedBoarderWidth
    );
    var wideBorder1 = BorderSide(
        color: !isHighlighted || !isActive ? borderColor
            : colorConfig.accentColor,
        width: !isHighlighted ? normalBoarderWidth * 2
            : selectedBoarderWidth
    );

    var border2 = BorderSide(
        color: Colors.transparent,
        width: !isHighlighted ? selectedBoarderWidth
            - normalBoarderWidth : 0
    );
    var wideBorder2 = BorderSide(
        color: Colors.transparent,
        width: !isHighlighted ? selectedBoarderWidth
            - normalBoarderWidth * 2 : 0
    );

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
            border: Border(
                top: !topBorderWide ? border1 : wideBorder1,
                right: !rightBorderWide ? border1 : wideBorder1,
                bottom: !bottomBorderWide ? border1 : wideBorder1,
                left: !leftBorderWide ? border1 : wideBorder1
            ),
          ),
          child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isHighlighted ?
                borderCircular : 0),
                border: Border(
                    top: !topBorderWide ? border2 : wideBorder2,
                    right: !rightBorderWide ? border2 : wideBorder2,
                    bottom: !bottomBorderWide ? border2 : wideBorder2,
                    left: !leftBorderWide ? border2 : wideBorder2
                ),
              ),
              child: child),
        )
    );
  }
}

// Month Calendar

class MonthPart extends HookConsumerWidget {
  final double monthPartHeight;
  final int weekdayPartColumnNum;
  final double weekdayPartWidth;
  final double weekdayPartHeight;
  final void Function(int) onPointerDown;
  final void Function(int) onPointerUp;
  final List<DayDisplay> dayList;

  const MonthPart({
    super.key,
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
    final calendarState = ref.watch(calendarPageNotifierProvider);
    final calendarNotifier = ref.watch(calendarPageNotifierProvider.notifier);

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
                topBorderWide: false,
                rightBorderWide: false,
                bottomBorderWide: false,
                leftBorderWide: false,
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
    final designConfigState = ref.watch(designConfigNotifierProvider);

    var borderColor = designConfigState.colorConfig!.borderColor;
    var border = BorderSide(
        color: borderColor, width: normalBoarderWidth
    );
    var wideBorder = BorderSide(
        color: borderColor, width: normalBoarderWidth * 2
    );
    return Container(
        width: width, height: height,
        decoration: BoxDecoration(
          border: Border(top: wideBorder, right: border, bottom: border,
              left: border),
        ),
        alignment: Alignment.center,
        child: CWText(weekday.title,
          textAlign: TextAlign.center,
          fontSize: calendarFontSize1,
          fontWeight: calendarFontWeight1,
          color: weekday.titleColor,
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
  final bool topBorderWide;
  final bool rightBorderWide;
  final bool bottomBorderWide;
  final bool leftBorderWide;
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
    required this.topBorderWide,
    required this.rightBorderWide,
    required this.bottomBorderWide,
    required this.leftBorderWide,
    required this.day
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorConfig = ref.watch(designConfigNotifierProvider)
        .colorConfig;
    var borderColor = colorConfig!.borderColor;
    var todayAlpha = colorConfig.calendarTodayBgColorAlpha;
    var lineAlpha = colorConfig.calendarLineBgColorAlpha;
    var todayBgColor = borderColor.withAlpha(todayAlpha);
    var highlightedLineAndTodayBgColor = borderColor.withAlpha(todayAlpha
        + lineAlpha);
    var highlightedLineColor = borderColor.withAlpha(lineAlpha);

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
      topBorderWide: topBorderWide,
      rightBorderWide: rightBorderWide,
      bottomBorderWide: bottomBorderWide,
      leftBorderWide: leftBorderWide,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CWText(day.title,
            fontSize: calendarFontSize1,
            fontWeight: calendarFontWeight1,
            color: day.titleColor,
          ),
          SizedBox(width: width, height: 1),
          Expanded(child:
            // Web版のスクロールバー非表示
            ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                    scrollbars: false),
                child: ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (int i = 0; i < day.eventList.length; i++) ... {
                      CWText(CalendarUtils().convertCharWrapString(
                          day.eventList[i].title)!,
                          maxLines: 1,
                          fontSize: calendarFontSize2,
                          fontWeight: calendarFontWeight2,
                          color: day.eventList[i].titleColor
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
  final double unsafeAreaBottomHeight;

  const EventListPart({
    super.key,
    required this.unsafeAreaBottomHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarPageNotifierProvider);
    final calendarNotifier = ref.watch(calendarPageNotifierProvider.notifier);
    final designConfigState = ref.watch(designConfigNotifierProvider);

    return Column(
        children: [
          SizedBox(
              height: 24,
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  color: designConfigState.colorConfig!.borderColor,
                  child: Row(
                    children: [
                      CWText(calendarState.eventListTitle,
                          fontSize: eventListFontSize1,
                          fontWeight: eventListFontWeight1,
                          color: designConfigState.colorConfig!
                              .normalTextColor
                      ),
                    ],
                  )
              )
          ),
          Expanded(child:
            SingleChildScrollView(
              child: Column(
                children: [
                  if (calendarState.eventList.isEmpty)
                    EventPart(
                      height: 45,
                      index: 0,
                      isHighlighted: calendarState.eventListIndex == 0,
                      onTapDown: (int i) async {
                        await calendarNotifier.selectEventListPart(0);
                        await calendarNotifier.updateState();
                      },
                      topBorderWide: true,
                      rightBorderWide: true,
                      bottomBorderWide: true,
                      leftBorderWide: true,
                      emptyMessage: 'イベントがありません',
                    ),
                  for (int i=0; i < calendarState.eventList.length; i++) ... {
                    EventPart(
                      key: calendarState.eventListCellKeyList[i],
                      height: 45,
                      index: i,
                      isHighlighted: calendarState.eventListIndex == i,
                      onTapDown: (int i) async {
                        await calendarNotifier.selectEventListPart(i);

                        await calendarNotifier.updateState();
                      },
                      topBorderWide: i == 0,
                      rightBorderWide: true,
                      bottomBorderWide: i == calendarState.eventList.length - 1,
                      leftBorderWide: true,
                      event: calendarState.eventList[i],
                    ),
                  },
                  SizedBox(height: eventListBottomSafeArea
                      + unsafeAreaBottomHeight)
                ]
              )
            )
          )
        ]
    );
  }
}

class EventPart extends StatefulHookConsumerWidget {
  final double height;
  final int index;
  final bool isHighlighted;
  final void Function(int) onTapDown;
  final bool topBorderWide;
  final bool rightBorderWide;
  final bool bottomBorderWide;
  final bool leftBorderWide;
  final String? emptyMessage;
  final EventDisplay? event;

  const EventPart({super.key,
    required this.height,
    required this.index,
    required this.isHighlighted,
    required this.onTapDown,
    required this.topBorderWide,
    required this.rightBorderWide,
    required this.bottomBorderWide,
    required this.leftBorderWide,
    this.emptyMessage,
    this.event,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState()
  => _EventPartState();
}

class _EventPartState extends ConsumerState<EventPart>
    with AutomaticKeepAliveClientMixin {

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final calendarNotifier = ref.watch(calendarPageNotifierProvider.notifier);
    // final calendarState = ref.watch(calendarPageNotifierProvider);
    final colorConfig = ref.watch(designConfigNotifierProvider)
        .colorConfig!;

    var height = widget.height;
    var index = widget.index;
    var isHighlighted = widget.isHighlighted;
    var onTapDown = widget.onTapDown;
    var topBorderWide = widget.topBorderWide;
    var rightBorderWide = widget.rightBorderWide;
    var bottomBorderWide = widget.bottomBorderWide;
    var leftBorderWide = widget.leftBorderWide;
    var emptyMessage = widget.emptyMessage;
    var event = widget.event;

    return SelectableCalendarCell(
        height: height,
        index: index,
        isHighlighted: isHighlighted,
        isActive: true,
        borderCircular: 10,
        selectedBoarderWidth: eventSelectedBoarderWidth,
        bgColor: Colors.transparent,
        onTapDown: onTapDown,
        onTapUp: (int i) async {
        },
        topBorderWide: topBorderWide,
        rightBorderWide: rightBorderWide,
        bottomBorderWide: bottomBorderWide,
        leftBorderWide: leftBorderWide,
        child: Container(
            padding: const EdgeInsets.all(selectedBoarderWidth),
            child: Row(
              children: [
              if (emptyMessage != null)
                Expanded(child:
                  Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8,
                          vertical: 0),
                      child: CWText(emptyMessage,
                          maxLines: 2,
                          fontSize: eventListFontSize3,
                          fontWeight: eventListFontWeight3,
                          color: colorConfig.normalTextColor
                      )
                  )
                ),
              if (event != null)
                SizedBox(width: 45, child:
                  CWText(event.head,
                      textAlign: TextAlign.center,
                      fontSize: eventListFontSize2,
                      fontWeight: eventListFontWeight2,
                      color: event.fontColor
                  )
                ),
              if (event != null)
                Container(
                    padding: const EdgeInsets
                        .symmetric(horizontal: selectedBoarderWidth,
                        vertical: 0),
                    child: Container(
                        width: normalBoarderWidth * 2,
                        color: event.lineColor
                    )
                ),
              if (event != null)
                Expanded(child:
                  Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4,
                          vertical: 0),
                      child: CWText(CalendarUtils().convertCharWrapString(
                          event.title)!,
                          maxLines: 2,
                          fontSize: eventListFontSize3,
                          fontWeight: eventListFontWeight3,
                          color: event.fontColor
                      )
                  )
                ),
              if (event != null && event.editing && !event.hourChoiceMode)
                CWElevatedButton(
                    title: event.fixedTitle!,
                    height: 32,
                    width: 85,
                    radius: 16,
                    backgroundColor: colorConfig.backgroundColor,
                    disabledBackgroundColor: Colors.transparent,
                    disabledForegroundColor: Colors.transparent,
                    elevation: 0,
                    color: colorConfig.normalTextColor,
                    onPressed: event.sameCell ? null : () async {
                      await calendarNotifier.selectEventListPart(index);
                      await calendarNotifier.moveCalendar(
                      event.fixedDateTime!, allDay: event.event!.allDay!);
                      // await calendarNotifier.selectEventList(
                      //     event!.event!.eventId!);
                      await calendarNotifier.updateState();
                    }
                ),
              // if (event != null && event!.editing)
              //   const SizedBox(width: 8),
              if (event != null && event.editing && event.sameCell
                  && !event.hourChoiceMode)
                CWIconButton(
                  assetName: 'images/icon_copy_event@3x.png',
                  assetIconSize: appBarIconHeight,
                  width: appBarHeight,
                  height: appBarHeight,
                  radius: appBarHeight / 2,
                  foregroundColor: colorConfig.accentColor,
                  onPressed: () async {
                    await calendarNotifier.selectEventListPart(index);

                    if (!await calendarNotifier.copyIndexEvent(index)) {
                      if (context.mounted) {
                        await UIUtils().showMessageDialog(context, ref,
                            'コピー', 'コピーに失敗しました');
                      }
                    }

                    await calendarNotifier.updateCalendar();
                    await calendarNotifier.selectEventList(event.eventId);
                    await calendarNotifier.updateState();
                  },
                ),
              if (event != null && event.editing
                  && (event.hourMoving || !event.sameCell)
                  && !event.hourChoiceMode)
                CWIconButton(
                  assetName: 'images/icon_move_event@3x.png',
                  assetIconSize: appBarIconHeight,
                  width: appBarHeight,
                  height: appBarHeight,
                  radius: appBarHeight / 2,
                  foregroundColor: colorConfig.accentColor,
                  onPressed: () async {
                    await calendarNotifier.selectEventListPart(index);

                    var eventId = await calendarNotifier.moveIndexEvent(
                        index);
                    if (!await calendarNotifier.isHourMove()) {
                      if (eventId == null) {
                        if (context.mounted) {
                          await UIUtils().showMessageDialog(context, ref,
                              '移動', '移動に失敗しました');
                        }
                      } else {
                        await calendarNotifier.updateEditingEvent(eventId);
                        await calendarNotifier.editingCancel(index);
                      }
                    } else {
                      await calendarNotifier.setHourChoiceMode(true);
                    }

                    await calendarNotifier.updateCalendar();
                    if (eventId != null) {
                      await calendarNotifier.selectEventList(eventId);
                    }
                    await calendarNotifier.updateState();
                  },
                ),
              if (event != null && event.editing && !event.hourChoiceMode)
                CWIconButton(
                  assetName: 'images/icon_lock_locking_tool@3x.png',
                  assetIconSize: appBarIconHeight,
                  width: appBarHeight,
                  height: appBarHeight,
                  radius: appBarHeight / 2,
                  foregroundColor: colorConfig.accentColor,
                  onPressed: () async {
                    await calendarNotifier.selectEventListPart(index);
                    var eventId = (await calendarNotifier.getSelectionEvent())!
                        .eventId;
                    await calendarNotifier.editingCancel(index);
                    await calendarNotifier.updateEventList();
                    if (eventId != null) {
                      await calendarNotifier.selectEventList(eventId);
                    }
                    await calendarNotifier.updateState();
                  },
                ),
              if (event != null && event.editing && event.hourChoiceMode)
                for (int i=0; i < event.movingHourChoices.length; i++)
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: CWElevatedButton(
                        title: '${event.movingHourChoices[i]}:00',
                        width: 39,
                        height: 32,
                        radius: 16,
                        fontSize: 11,
                        backgroundColor: colorConfig.backgroundColor,
                        elevation: 0,
                        color: colorConfig.normalTextColor,
                        onPressed: () async {
                          await calendarNotifier.selectEventListPart(index);

                          var eventId = await calendarNotifier.moveIndexEvent(
                              index, hour: event.movingHourChoices[i]);
                          if (eventId == null) {
                            if (context.mounted) {
                              await UIUtils().showMessageDialog(context, ref,
                                  '移動', '移動に失敗しました');
                            }
                          } else {
                            await calendarNotifier.updateEditingEvent(eventId);
                            await calendarNotifier.editingCancel(index);
                          }

                          await calendarNotifier.setHourChoiceMode(false);
                          await calendarNotifier.updateCalendar();
                          if (eventId != null) {
                            await calendarNotifier.selectEventList(eventId);
                          }
                          await calendarNotifier.updateState();
                        }
                    )
                  ),
              if (event != null && event.editing && event.hourChoiceMode)
                CWIconButton(
                  assetName: 'images/icon_close@3x.png',
                  assetIconSize: appBarIconHeight,
                  width: appBarHeight,
                  height: appBarHeight,
                  radius: appBarHeight / 2,
                  foregroundColor: colorConfig.accentColor,
                  onPressed: () async {
                    await calendarNotifier.selectEventListPart(index);
                    await calendarNotifier.setHourChoiceMode(false);
                    await calendarNotifier.updateCalendar();
                    await calendarNotifier.updateState();
                  },
                ),
              if (event != null && !event.editing && !event.readOnly)
                CWIconButton(
                  assetName: 'images/icon_trash@3x.png',
                  assetIconSize: appBarIconHeight,
                  width: appBarHeight,
                  height: appBarHeight,
                  radius: appBarHeight / 2,
                  foregroundColor: colorConfig.accentColor,
                  onPressed: () async {
                    // await Future.delayed(const Duration(
                    // milliseconds: 500));

                    await calendarNotifier.selectEventListPart(index);
                    await calendarNotifier.updateState();

                    if (context.mounted) {
                      var result = await UIUtils().showMessageDialog(
                          context, ref, '削除', 'イベントを削除しますか?', 'はい',
                          'いいえ');
                      if (result != 'positive') {
                        return;
                      }
                    }

                    if (!await calendarNotifier.deleteEvent(event)) {
                      if (context.mounted) {
                        await UIUtils().showMessageDialog(context, ref,
                            '削除', '削除に失敗しました');
                      }
                      return;
                    }

                    await calendarNotifier.updateCalendar();
                    await calendarNotifier.updateState();
                  },
                ),
              if (event != null && !event.editing && !event.readOnly)
                CWIconButton(
                  assetName: 'images/icon_unlock_locking_tool@3x.png',
                  assetIconSize: appBarIconHeight,
                  width: appBarHeight,
                  height: appBarHeight,
                  radius: appBarHeight / 2,
                  foregroundColor: colorConfig.accentColor,
                  onPressed: () async {
                    await calendarNotifier.selectEventListPart(index);
                    await calendarNotifier.fixedEvent(index);
                    await calendarNotifier.updateState();
                  },
                )
            ],
            )
        )
    );
  }

  @override
  bool get wantKeepAlive => true;
}

// Week Calendar

class DayAndWeekdayListPart extends HookConsumerWidget {
  final int hoursPartRowNum;
  final double hourPartWidth;
  final double hourPartHeight;
  final List<DayAndWeekdayDisplay> dayAndWeekdayList;

  const DayAndWeekdayListPart({
    super.key,
    required this.hoursPartRowNum,
    required this.hourPartWidth,
    required this.hourPartHeight,
    required this.dayAndWeekdayList
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarPageNotifierProvider);
    return Column(children: [
      for (int rowIndex = 0; rowIndex < hoursPartRowNum; rowIndex++) ... {
        DayAndWeekdayPart(
            width: hourPartWidth,
            height: hourPartHeight,
            isHighlightedDay: calendarState.hourPartIndex
                ~/ hoursPartRowNum == rowIndex,
            topBorderWide: false,
            rightBorderWide: false,
            bottomBorderWide: false,
            leftBorderWide: false,
            dayAndWeekday: dayAndWeekdayList[rowIndex]
        ),
      }
    ]);
  }
}

class DayAndWeekdayPart extends HookConsumerWidget {
  final double width;
  final double height;
  final bool topBorderWide;
  final bool rightBorderWide;
  final bool bottomBorderWide;
  final bool leftBorderWide;
  final bool isHighlightedDay;
  final DayAndWeekdayDisplay dayAndWeekday;

  const DayAndWeekdayPart({
    super.key,
    required this.width,
    required this.height,
    required this.topBorderWide,
    required this.rightBorderWide,
    required this.bottomBorderWide,
    required this.leftBorderWide,
    required this.isHighlightedDay,
    required this.dayAndWeekday
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorConfig = ref.watch(designConfigNotifierProvider)
        .colorConfig;
    var borderColor = colorConfig!.borderColor;
    var todayAlpha = colorConfig.calendarTodayBgColorAlpha;
    var lineAlpha = colorConfig.calendarLineBgColorAlpha;
    var todayBgColor = borderColor.withAlpha(todayAlpha);
    var highlightedLineAndTodayBgColor = borderColor.withAlpha(todayAlpha
        + lineAlpha);
    var highlightedLineColor = borderColor.withAlpha(lineAlpha);
    var border = BorderSide(
        color: colorConfig.borderColor, width: normalBoarderWidth
    );
    var wideBorder = BorderSide(
        color: colorConfig.borderColor, width: normalBoarderWidth * 2
    );

    return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isHighlightedDay ?
            dayAndWeekday.today ? highlightedLineAndTodayBgColor
                : highlightedLineColor :
            dayAndWeekday.today ? todayBgColor : Colors.transparent,
          border: Border(
              top: !topBorderWide ? border : wideBorder,
              right: !rightBorderWide ? border : wideBorder,
              bottom: !bottomBorderWide ? border : wideBorder,
              left: !leftBorderWide ? border : wideBorder
          ),
        ),
        alignment: Alignment.center,
        child: CWText(dayAndWeekday.dayAndWeekTitle,
          textAlign: TextAlign.center,
          fontSize: calendarFontSize1,
          fontWeight: calendarFontWeight1,
          color: dayAndWeekday.dayAndWeekTitleColor,
        )
    );
  }
}

class HoursPart extends HookConsumerWidget {
  final int hoursPartColNum;
  final int hoursPartRowNum;
  final double hourPartWidth;
  final double hourPartHeight;
  final void Function(int) onPointerDown;
  final void Function(int) onPointerUp;
  final List<HourDisplay> hourList;

  const HoursPart({
    super.key,
    required this.hourPartWidth,
    required this.hourPartHeight,
    required this.hoursPartColNum,
    required this.hoursPartRowNum,
    required this.onPointerDown,
    required this.onPointerUp,
    required this.hourList,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarPageNotifierProvider);
    final calendarNotifier = ref.watch(calendarPageNotifierProvider.notifier);

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
                topBorderWide: false,
                rightBorderWide: false,
                bottomBorderWide: false,
                leftBorderWide: false,
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
  final bool topBorderWide;
  final bool rightBorderWide;
  final bool bottomBorderWide;
  final bool leftBorderWide;
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
    required this.topBorderWide,
    required this.rightBorderWide,
    required this.bottomBorderWide,
    required this.leftBorderWide,
    required this.hour
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorConfig = ref.watch(designConfigNotifierProvider)
        .colorConfig;
    var borderColor = colorConfig!.borderColor;
    var todayAlpha = colorConfig.calendarTodayBgColorAlpha;
    var lineAlpha = colorConfig.calendarLineBgColorAlpha;
    var todayBgColor = borderColor.withAlpha(todayAlpha);
    var highlightedLineAndTodayBgColor = borderColor.withAlpha(todayAlpha
        + lineAlpha);
    var highlightedLineColor = borderColor.withAlpha(lineAlpha);
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
        topBorderWide: topBorderWide,
        rightBorderWide: rightBorderWide,
        bottomBorderWide: bottomBorderWide,
        leftBorderWide: leftBorderWide,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CWText(hour.title,
                fontSize: !hour.allDay ? calendarFontSize1
                    : calendarFontSize1Down1,
                fontWeight: calendarFontWeight1,
                color: hour.titleColor,
              ),
              SizedBox(width: width, height: 1),
              Expanded(child:
                // Web版のスクロールバー非表示
                ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                        scrollbars: false),
                    child: ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        for (int i = 0; i < hour.eventList.length; i++) ... {
                          CWText(CalendarUtils().convertCharWrapString(
                              hour.eventList[i].title)!,
                            maxLines: 1,
                            fontSize: calendarFontSize2,
                            fontWeight: calendarFontWeight2,
                            color: hour.eventList[i].titleColor
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