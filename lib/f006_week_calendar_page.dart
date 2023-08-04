import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'f002_home_view_model.dart';
import 'f007_week_calendar_view_model.dart';

/*
    0:00 1:00 2:00 3:00 4:00 5:00 終日
11/1
(日)

11/2
(月)

11/3
(火)

11/4
(水)

11/5
(木)

11/6
(金)

11/7
(土)
 */

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

class WeekCalendarPage extends StatefulHookConsumerWidget {
  final int pageIndex;

  const WeekCalendarPage({super.key,
    required this.pageIndex});

  @override
  ConsumerState<ConsumerStatefulWidget> createState()
    => _WeekCalendarPageState();
}

class _WeekCalendarPageState extends ConsumerState<WeekCalendarPage>
    with AutomaticKeepAliveClientMixin {

  List<HourTitlesPart> hourTitlesPartList = [];
  List<DaysAndWeekdaysPart> daysAndWeekdaysPartList = [];
  List<List<HoursPart>> weeksPartLists = [];
  double preDeviceWidth = 0;
  double preDeviceHeight = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final homeState = ref.watch(homePageNotifierProvider);
    final weekCalendarState = ref.watch(weekCalendarPageNotifierProvider(
        widget.pageIndex));
    final homeNotifier = ref.watch(homePageNotifierProvider.notifier);
    final weekCalendarNotifier = ref.watch(weekCalendarPageNotifierProvider(
        widget.pageIndex).notifier);

    // Widgetの一番上で取得可能な項目
    // アンセーフエリア上の高さ
    double unSafeAreaTopHeight = MediaQuery.of(context).padding.top;
    // アンセーフエリア下の高さ
    double unSafeAreaBottomHeight = MediaQuery.of(context).padding.bottom;

    // 画面の幅
    double deviceWidth = MediaQuery.of(context).size.width;
    // 画面の高さ
    double deviceHeight = MediaQuery.of(context).size.height;
    // アプリバーの高さ
    //double appBarHeight = AppBar().preferredSize.height;
    double appBarHeight = homeState.appBarHeight;
    // 時間ヘッダー部分の高さ
    double hourHeaderPartHeight = 21;
    // イベント一覧のアスペクト比
    double eventListAspectRate = 1.41421356237;
    // イベント一覧の高さ
    double eventListHeight = deviceWidth / eventListAspectRate;
    double eventListMaxHeight = 320;
    if (eventListHeight > eventListMaxHeight) {
      eventListAspectRate = deviceWidth / eventListMaxHeight;
      eventListHeight = eventListMaxHeight;
    }
    // 週部分の高さ
    double weekPartHeight = deviceHeight - appBarHeight - hourHeaderPartHeight
        - eventListHeight - unSafeAreaTopHeight;

    useEffect(() {
      debugPrint('child useEffect');

      // Pageの初期化処理
      weekCalendarNotifier.initState(() {
        homeNotifier.updateState();
      });

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        debugPrint('child addPostFrameCallback');
      });

      weekCalendarState.hoursCalendarController.addListener(() {
        try {
          weekCalendarState.hourTitlesController.jumpTo(
              weekCalendarState.hoursCalendarController.offset);
        } catch (e) {
          // 横スクロール中に縦スクロールをするとエラーになる。
          // 'package:flutter/src/widgets/scroll_controller.dart':
          // Failed assertion: line 106 pos 12: '_positions.length == 1':
          // ScrollController attached to multiple scroll views.
          debugPrint(e.toString());
        }
      });

      weekCalendarState.weeksCalendarController.addListener(() {
        try {
          weekCalendarState.daysAndWeekdaysController.jumpTo(
              weekCalendarState.weeksCalendarController.offset);
          weekCalendarState.hourTitlesController.jumpTo(
              weekCalendarState.hoursCalendarController.offset);
        } catch (e) {
          // 横スクロール中に縦スクロールをするとエラーになる。
          // 'package:flutter/src/widgets/scroll_controller.dart':
          // Failed assertion: line 106 pos 12: '_positions.length == 1':
          // ScrollController attached to multiple scroll views.
          debugPrint(e.toString());
        }
      });

      return () {
        // Pageの解放処理
      };
    }, const []);

    double daysAndWeekdaysPartWidth = 47;
    double hourPartWidth = (deviceWidth - daysAndWeekdaysPartWidth)
        / (WeekCalendarPageState.timePartColNum + 1);
    double hourPartHeight = weekPartHeight / WeekCalendarPageState
        .weekdayPartRowNum;

    if (preDeviceWidth != deviceWidth || preDeviceHeight != deviceHeight
        || weekCalendarState.calendarReload) {
      weekCalendarState.calendarReload = false;

      // for (int i = 0; i < 3; i++) {
      //   debugPrint('表示月:${calendarState.dayLists[i][0].id}');
      // }

      hourTitlesPartList = weekCalendarState.hourTitleLists
          .map((hourTitleList) =>
              HourTitlesPart(
                  weekPartColNum: WeekCalendarPageState.timePartColNum,
                  pageIndex: widget.pageIndex,
                  hourPartWidth: hourPartWidth,
                  hourPartHeight: hourPartHeight,
                  hourTitleList: hourTitleList,
                  allDayTitle: weekCalendarState.allDayTitle
              )
      ).toList();

      daysAndWeekdaysPartList = weekCalendarState.daysAndWeekdaysList
          .map((daysAndWeekdays) => DaysAndWeekdaysPart(
            weekPartRowNum: WeekCalendarPageState.weekdayPartRowNum,
            pageIndex: widget.pageIndex,
            hourPartWidth: daysAndWeekdaysPartWidth,
            hourPartHeight: hourPartHeight,
            daysAndWeekdays: daysAndWeekdays,
          )
      ).toList();

      weeksPartLists = weekCalendarState.hoursListsList.map((hourLists) {
        return hourLists.map((hourList) {
          return HoursPart(
              weekPartColNum: WeekCalendarPageState.timePartColNum,
              weekPartRowNum: WeekCalendarPageState.weekdayPartRowNum,
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

    var hourTitlePageView = PageView.builder(
      scrollDirection: Axis.horizontal,
      pageSnapping: false,
      controller: weekCalendarState.hourTitlesController,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: (int index) {
        // weekCalendarNotifier.onCalendarPageChanged(
        // index);
      },
      itemBuilder: (context, index) {
        var adjustmentIndex = index
            + weekCalendarState.baseAddingHourPart
            - weekCalendarState.addingHourPart;
        return hourTitlesPartList[adjustmentIndex % 3];
      },
    );

    var daysAndWeekPageView = PageView.builder(
      scrollDirection: Axis.vertical,
      pageSnapping: false,
      controller: weekCalendarState.daysAndWeekdaysController,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: (int index) {
        // weekCalendarNotifier.onCalendarPageChanged(index);
      },
      itemBuilder: (context, index) {
        // var adjustmentIndex = index
        //     + weekCalendarState.baseAddingHourPart
        //     - weekCalendarState.addingHourPart;
        var adjustmentIndex = 1;
        return daysAndWeekdaysPartList[
        adjustmentIndex % 3];
      },
    );

    var hourPageViews = weeksPartLists.map((weeksPartList) {
      return PageView.builder(
        // pageSnapping: false,
        controller: weekCalendarState.hoursCalendarController,
        physics: const CustomScrollPhysics(mass: 75,
            stiffness: 100, damping: 0.85),
        onPageChanged: (int index) {
          weekCalendarNotifier.onHourCalendarPageChanged(index);
        },
        itemBuilder: (context, index) {
          var adjustmentIndex = index
              + weekCalendarState.baseAddingHourPart
              - weekCalendarState.addingHourPart;
          return weeksPartList[adjustmentIndex % 3];
        },
      );
    }).toList();

    var weeksPageView = PageView.builder(
      scrollDirection: Axis.vertical,
      // pageSnapping: false,
      controller: weekCalendarState.weeksCalendarController,
      physics: const CustomScrollPhysics(mass: 75,
          stiffness: 100, damping: 0.85),
      onPageChanged: (int index) {
        //weekCalendarNotifier.onCalendarPageChanged(index);
      },
      itemBuilder: (context, index) {
        var adjustmentIndex = index
            /*+ weekCalendarState.baseAddingHourPart
            - weekCalendarState.addingHourPart*/;
        return hourPageViews[/*adjustmentIndex % 3*/1];
      },
    );

    // 右端スワイプでナビゲーションを戻さない
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(homeState.appBarHeight),
          child: AppBar(
            automaticallyImplyLeading: false,
            title: Consumer(
                builder: ((context, ref, child) {
                  final homeState = ref.watch(homePageNotifierProvider);
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(tag: 'AppBar1TitleText', child:
                        Material(
                          color: Colors.transparent,
                          child: Text(homeState.appBarTitle,
                            style: const TextStyle(
                                height: 1.3,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 21
                            )
                          ),
                        )
                      )
                    ],
                  );
                })
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(0),
                child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop()
                ),
              )
            ],
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
              children: [
                SizedBox(
                  height: hourHeaderPartHeight,
                  child: Row(
                    children: [
                      Container(
                          width: daysAndWeekdaysPartWidth,
                          height: hourHeaderPartHeight,
                          decoration: const BoxDecoration(
                            border: Border.fromBorderSide(
                                BorderSide(
                                    color: borderColor,
                                    width: normalBoarderWidth
                                )
                            ),
                          )
                      ),
                      Expanded(child: hourTitlePageView)
                    ],
                  ),
                ),
                Expanded(
                    child: Row(children: [
                      SizedBox(width: daysAndWeekdaysPartWidth,
                          child: daysAndWeekPageView),
                      Expanded(child: weeksPageView)
                    ])
                ),
                AspectRatio(
                    aspectRatio: eventListAspectRate,
                    child: EventListPart(pageIndex: widget.pageIndex,
                        unSafeAreaBottomHeight: unSafeAreaBottomHeight)
                )
              ]
          )
      )
      )
    );
  }

  @override
  bool get wantKeepAlive => true;
}

// TODO 抽象化クラスへ移動する
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
    final weekCalendarState = ref.watch(weekCalendarPageNotifierProvider(
        pageIndex));
    final weekCalendarNotifier = ref.watch(weekCalendarPageNotifierProvider(
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
                isActive: weekCalendarState.hourPartActive,
                onTapDown: (int i) async {
                  if (weekCalendarState.hourPartIndex != i) {
                    weekCalendarNotifier.selectHour(index: i);
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
    final calendarState = ref.watch(weekCalendarPageNotifierProvider(
        pageIndex));
    final calendarNotifier = ref.watch(weekCalendarPageNotifierProvider(
        pageIndex).notifier);

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
          Expanded(
              child: ListView(
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