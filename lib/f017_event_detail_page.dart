import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scal/f013_ui_utils.dart';

import 'f001_home_page.dart';
import 'f002_home_view_model.dart';
import 'f005_calendar_view_model.dart';
import 'f016_design.dart';
import 'f018_event_detail_view_model.dart';
import 'f021_bottom_safe_area_view.dart';
import 'f024_bottom_safe_area_view_model.dart';
import 'f025_common_widgets.dart';

class EventDetailPage extends StatefulHookConsumerWidget {
  final double unsafeAreaTopHeight;
  final double unsafeAreaBottomHeight;

  const EventDetailPage({super.key,
    required this.unsafeAreaTopHeight,
    required this.unsafeAreaBottomHeight
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState()
  => _EventDetailPage();
}

class _EventDetailPage extends ConsumerState<EventDetailPage> {
  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    final colorConfig = ref.watch(designConfigNotifierProvider).colorConfig!;
    var normalTextColor = colorConfig.normalTextColor;
    // final homeState = ref.watch(homePageNotifierProvider);
    final homeNotifier = ref.watch(homePageNotifierProvider.notifier);

    final colorConfigNotifier = ref.watch(designConfigNotifierProvider
        .notifier);
    List<CalendarPageNotifier> calendarNotifiers = [];
    for (int i=0; i < calendarWidgetNum; i++) {
      calendarNotifiers.add(ref.watch(calendarPageNotifierProvider(i)
          .notifier));
    }

    final safeAreaViewNotifier = ref.watch(bottomSafeAreaViewNotifierProvider
        .notifier);

    final eventDetailState = ref.watch(eventDetailPageNotifierProvider);
    final eventDetailNotifier = ref.watch(eventDetailPageNotifierProvider
        .notifier);

    final showBottomArea = UIUtils().useShowBottomArea(ref);

    // 画面の幅
    double deviceWidth = MediaQuery.of(context).size.width;
    // 画面の高さ
    double deviceHeight = MediaQuery.of(context).size.height;
    // ページの幅
    double pageWidget = deviceWidth * 0.95;

    // 閉じるボタンの幅
    double closingButtonWidth = 39;

    final yearList = useState<List<String>>([]);
    final monthList = useState<List<String>>([]);
    final startDayList = useState<List<String>>([]);
    final endDayList = useState<List<String>>([]);
    final hourList = useState<List<String>>([]);
    final minuteList = useState<List<String>>([]);
    final repeatingEndDayList = useState<List<String>>([]);
    final calendarList = useState<List<List<String>>>([]);

    bool validateDate(year, month, day) {
      var dateTime = DateTime(year, month, day);
      return dateTime.year == year && dateTime.day == day
          && dateTime.day == day;
    }

    List<String> createDayList(year, month) {
      var list = [];
      for (int i = 1; i <= 31; i++) {
        list.add(i);
      }
      return list.where((day) {
        return validateDate(year, month, day);
      }).map((day) => day.toString().padLeft(2, '0'))
          .toList();
    }

    useEffect(() {
      yearList.value = (() {
        List<String> list = [];
        for (int i = 1800; i <= DateTime.now().year + 300; i++) {
          list.add(i.toString());
        }
        return list;
      })();
      monthList.value = (() {
        List<String> list = [];
        for (int i = 1; i <= 12; i++) {
          list.add(i.toString().padLeft(2, '0'));
        }
        return list;
      })();
      hourList.value = (() {
        List<String> list = [];
        for (int i = 0; i <= 24; i++) {
          list.add(i.toString().padLeft(2, '0'));
        }
        return list;
      })();
      minuteList.value = (() {
        List<String> list = [];
        for (int i = 0; i <= 59; i++) {
          list.add(i.toString().padLeft(2, '0'));
        }
        return list;
      })();
      calendarList.value = [
        ['TEST_ID_1', 'カレンダー1あああああああああああああああああああああああああああ'],
        ['TEST_ID_2', 'カレンダー2'],
        ['TEST_ID_3', 'カレンダー3'],
      ];

      return () {
      };
    }, const []);

    useEffect(() {
      startDayList.value = createDayList(eventDetailState.formStartYear,
          eventDetailState.formStartMonth);
      return () {
      };
    }, [eventDetailState.formStartYear, eventDetailState.formStartMonth]);

    useEffect(() {
      endDayList.value = createDayList(eventDetailState.formEndYear,
          eventDetailState.formEndMonth);
      return () {
      };
    }, [eventDetailState.formEndYear, eventDetailState.formEndMonth]);

    useEffect(() {
      endDayList.value = createDayList(eventDetailState.formEndYear,
          eventDetailState.formEndMonth);
      return () {
      };
    }, [eventDetailState.formEndYear, eventDetailState.formEndMonth]);

    useEffect(() {
      if (eventDetailState.formRepeatEndYear != null
          && eventDetailState.formRepeatEndMonth != null) {
        repeatingEndDayList.value = createDayList(
            eventDetailState.formRepeatEndYear,
            eventDetailState.formRepeatEndMonth);
      }
      return () {
      };
    }, [eventDetailState.formRepeatEndYear,
      eventDetailState.formRepeatEndMonth]);

    final preContentsHeight = useState<double?>(null);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      BuildContext? context = eventDetailState.contentsKey?.currentContext;
      RenderBox? renderBox;
      if (context != null) {
        renderBox = context.findRenderObject() as RenderBox?;
      }
      if (renderBox != null) {
        var contentsHeight = renderBox.size.height;
        if (preContentsHeight.value != contentsHeight)  {
          preContentsHeight.value = contentsHeight;
          debugPrint('contentsHeight=$contentsHeight');
        }
      }
    });

    inputDecorationMaker({String? hintText}) {
      return InputDecoration(
        contentPadding: const EdgeInsets.all(8),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: colorConfig.eventListTitleBgColor, width: 1.5)
        ),
        disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: colorConfig.eventListTitleBgColor, width: 2)
        ),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: colorConfig.accentColor, width: 2)
        ),
        hintText: hintText,
      );
    }

    dropdownMenuItemMaker<T>(value, title) {
      return DropdownMenuItem<T>(
        value: value,
        child: Text(title, textAlign: TextAlign.center,
          style: TextStyle(
              height: 1.7,
              fontSize: 13,
              color: normalTextColor
          ),
          maxLines: 1,
        ),
      );
    }

    var contents = Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        child: Column(
            children: [
              Row(children: [
                SizedBox(width: closingButtonWidth,
                    height: closingButtonWidth,
                    child: TextButton(
                      onPressed: () async {
                        // Navigator.pop(context);

                        homeNotifier.setUICover(false);
                        homeNotifier.setUICoverWidget(null);
                        homeNotifier.updateState();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: normalTextColor,
                        textStyle: const TextStyle(fontSize: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              closingButtonWidth / 2),
                        ),
                        padding: const EdgeInsets.all(0),
                      ),
                      child: Icon(Icons.check,
                          color: normalTextColor),
                    )
                ),
                const Spacer(),
                SizedBox(width: closingButtonWidth,
                    height: closingButtonWidth,
                    child: TextButton(
                      onPressed: () async {
                        var contentsMode = eventDetailState.contentsMode!;
                        switch (contentsMode) {
                          case EventDetailPageContentsMode.simpleInput:
                            contentsMode = EventDetailPageContentsMode
                                .detailInput;
                          case EventDetailPageContentsMode.detailInput:
                            contentsMode = EventDetailPageContentsMode
                                .simpleInput;
                        }

                        await eventDetailNotifier.setContentsMode(contentsMode);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: normalTextColor,
                        textStyle: const TextStyle(fontSize: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              closingButtonWidth / 2),
                        ),
                        padding: const EdgeInsets.all(0),
                      ),
                      child: Icon(Icons.check,
                          color: normalTextColor),
                    )
                ),
                SizedBox(width: closingButtonWidth,
                    height: closingButtonWidth,
                    child: TextButton(
                      onPressed: () async {
                        await colorConfigNotifier.switchColorConfig();
                        for (var i=0; i < calendarWidgetNum; i++) {
                          await calendarNotifiers[i].initState();
                          await calendarNotifiers[i].updateCalendar(
                              dataExclusion: true);
                        }
                        await colorConfigNotifier.updateState();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: normalTextColor,
                        textStyle: const TextStyle(fontSize: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              closingButtonWidth / 2),
                        ),
                        padding: const EdgeInsets.all(0),
                      ),
                      child: Icon(Icons.check,
                          color: normalTextColor),
                    )
                ),
              ]),


              const SizedBox(height: 500),

              CWLeftTitle(
                  title: 'タイトル',
                  highlight: eventDetailState.highlightItem
                      == HighlightItem.title,
                  rightPaddingWidth: 8,
                  child: Padding(padding: const EdgeInsets.symmetric(
                      vertical: 4),
                      child: CWTextField(
                        controller: eventDetailState.textEditingControllers!
                        [TextFieldItem.title]!,
                        hintText: 'タイトル',
                        highlight: eventDetailState.highlightItem
                            == HighlightItem.title,
                        maxLines: 2,
                        onTap: () {
                          eventDetailNotifier.updateHighlightItem(
                              HighlightItem.title);
                          safeAreaViewNotifier.setSafeAreaAdjustment(8);
                        },
                        onChanged: (text) {
                          debugPrint('Textの変更検知={$text}');
                        }
                      )
                  )
              ),

              CWLeftTitle(
                  title: '場所',
                  highlight: eventDetailState.highlightItem
                      == HighlightItem.place,
                  rightPaddingWidth: 8,
                  child: CWPadding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      height: 38,
                      child: CWTextField(
                        controller: eventDetailState.textEditingControllers!
                        [TextFieldItem.place]!,
                        hintText: '場所',
                        highlight: eventDetailState.highlightItem
                            == HighlightItem.place,
                        onTap: () {
                          eventDetailNotifier.updateHighlightItem(
                              HighlightItem.place);
                          safeAreaViewNotifier.setSafeAreaAdjustment(8);
                        },
                        onChanged: (text) {
                          debugPrint('Textの変更検知={$text}');
                        },
                      )
                  )
              ),

              CWLeftTitle(
                  title: '終日',
                  highlight: eventDetailState.highlightItem
                      == HighlightItem.allDay,
                  expanded: false,
                  child: Padding(padding: const EdgeInsets.symmetric(
                      vertical: 2),
                      child: CupertinoSwitch(
                        value: eventDetailState.allDay!,
                        onChanged: (value) {
                          eventDetailState.highlightItem = HighlightItem.allDay;
                          eventDetailState.allDay = value;
                          if (!eventDetailState.allDay!) {
                            eventDetailNotifier.setContentsMode(
                                EventDetailPageContentsMode.detailInput);
                          } else {
                            eventDetailNotifier.setContentsMode(
                                EventDetailPageContentsMode.simpleInput);
                          }
                        },
                      )
                  )
              ),

              CWLeftTitle(
                  title: eventDetailState.allDay! ? '日付' : '開始',
                  highlight: eventDetailState.highlightItem
                      == HighlightItem.startDate
                    || eventDetailState.highlightItem
                          == HighlightItem.startHour,
                  expanded: false,
                  child: Row(children: [
                    CWPadding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        width: 120, height: 38,
                        child: CWTextField(
                          controller: eventDetailState.textEditingControllers!
                          [TextFieldItem.startDate]!,
                          fontSize: 17,
                          textAlign: TextAlign.center,
                          paddingAll: 6,
                          readOnly: true,
                          highlight: eventDetailState.highlightItem
                              == HighlightItem.startDate,
                          onTap: () async {
                            await eventDetailNotifier.updateHighlightItem(
                                HighlightItem.startDate);
                            await safeAreaViewNotifier.setSafeAreaAdjustment(5);
                            await safeAreaViewNotifier.setSafeAreaHeight(216);
                            await safeAreaViewNotifier.updateState();
                            await showBottomArea(Container());
                            await eventDetailNotifier.updateHighlightItem(
                                HighlightItem.none);
                          },
                          onChanged: (text) {
                            debugPrint('Textの変更検知={$text}');
                          },
                        )
                    ),

                    if (!eventDetailState.allDay!)
                      CWPadding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        width: 60, height: 38,
                        child: CWTextField(
                          controller: eventDetailState.textEditingControllers!
                          [TextFieldItem.startHour]!,
                          fontSize: 17,
                          textAlign: TextAlign.center,
                          paddingAll: 6,
                          readOnly: true,
                          highlight: eventDetailState.highlightItem
                              == HighlightItem.startHour,
                          onTap: () async {
                            await eventDetailNotifier.updateHighlightItem(
                                HighlightItem.startHour);
                            await safeAreaViewNotifier.setSafeAreaAdjustment(5);
                            await safeAreaViewNotifier.setSafeAreaHeight(216);
                            await safeAreaViewNotifier.updateState();
                            await showBottomArea(Container());
                            await eventDetailNotifier.updateHighlightItem(
                                HighlightItem.none);
                          },
                          onChanged: (text) {
                            debugPrint('Textの変更検知={$text}');
                          },
                        )
                    ),
                  ])
              ),





              const SizedBox(height: 8),

              Row(children: [
                SizedBox(width: 52,
                    child: Text(eventDetailState.allDay! ? '日付' : '開始',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            color: normalTextColor
                        )
                    )
                ),

                const SizedBox(width: 8),

                SizedBox(
                    height: 41,
                    child: IntrinsicWidth(
                      child: DropdownButtonFormField<int>(
                        elevation: 0,
                        dropdownColor: colorConfig.cardColor,
                        decoration: inputDecorationMaker(),
                        value: eventDetailState.formStartYear,
                        items: yearList.value.map((year) {
                          return dropdownMenuItemMaker<int>(int.parse(year),
                              '$year年');
                        }).toList(),
                        onChanged: (value) async {
                          eventDetailState.formStartYear = value!;
                          startDayList.value = createDayList(
                              eventDetailState.formStartYear,
                              eventDetailState.formStartMonth);
                          if (!validateDate(eventDetailState.formStartYear,
                              eventDetailState.formStartMonth,
                              eventDetailState.formStartDay)) {
                            eventDetailState.formStartDay = 1;
                          }
                        },
                      ),
                    )
                ),

                const SizedBox(width: 6),

                SizedBox(
                    height: 41,
                    child: IntrinsicWidth(
                      child: DropdownButtonFormField<int>(
                        elevation: 0,
                        dropdownColor: colorConfig.cardColor,
                        decoration: inputDecorationMaker(),
                        value: eventDetailState.formStartMonth,
                        items: monthList.value.map((month) {
                          return dropdownMenuItemMaker<int>(int.parse(month),
                              '$month月');
                        }).toList(),
                        onChanged: (value) async {
                          eventDetailState.formStartMonth = value!;
                          startDayList.value = createDayList(
                              eventDetailState.formStartYear,
                              eventDetailState.formStartMonth);
                          if (!validateDate(
                              eventDetailState.formStartYear,
                              eventDetailState.formStartMonth,
                              eventDetailState.formStartDay)) {
                            eventDetailState.formStartDay = 1;
                          }
                        },
                      ),
                    )
                ),

                const SizedBox(width: 6),

                SizedBox(
                    height: 41,
                    child: IntrinsicWidth(
                      child: DropdownButtonFormField<int>(
                        elevation: 0,
                        dropdownColor: colorConfig.cardColor,
                        decoration: inputDecorationMaker(),
                        value: eventDetailState.formStartDay,
                        items: startDayList.value.map((day) {
                          return dropdownMenuItemMaker<int>(int.parse(day),
                              '$day日');
                        }).toList(),
                        onChanged: (value) async {
                          eventDetailState.formStartDay = value!;
                        },
                      ),
                    )
                ),
                const Spacer()
              ]),

              const SizedBox(height: 8),

              if (!eventDetailState.allDay!)
                Row(children: [
                  Container(width: 52),

                  const SizedBox(width: 8),

                  SizedBox(
                      height: 41,
                      child: IntrinsicWidth(
                        child: DropdownButtonFormField<int>(
                          elevation: 0,
                          dropdownColor: colorConfig.cardColor,
                          decoration: inputDecorationMaker(),
                          value: eventDetailState.formStartHour,
                          items: hourList.value.map((hour) {
                            return dropdownMenuItemMaker<int>(int.parse(hour),
                                hour);
                          }).toList(),
                          onChanged: (value) async {
                            eventDetailState.formStartHour = value!;
                          },
                        ),
                      )
                  ),

                  const SizedBox(width: 6),

                  Text(':', textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 21,
                          color: normalTextColor
                      )
                  ),

                  const SizedBox(width: 6),

                  SizedBox(
                      height: 41,
                      child: IntrinsicWidth(
                        child: DropdownButtonFormField<int>(
                          elevation: 0,
                          dropdownColor: colorConfig.cardColor,
                          decoration: inputDecorationMaker(),
                          value: eventDetailState.formStartMinute,
                          items: minuteList.value.map((minute) {
                            return dropdownMenuItemMaker<int>(int.parse(minute),
                                minute);
                          }).toList(),
                          onChanged: (value) async {
                            eventDetailState.formStartMinute = value!;
                          },
                        ),
                      )
                  ),

                  const Spacer()
                ]),

              if (!eventDetailState.allDay!)
                Column(children: [
                  const SizedBox(height: 8),

                  Row(children: [
                    SizedBox(width: 52,
                        child: Text('終了',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 13,
                                color: normalTextColor
                            )
                        )
                    ),

                    const SizedBox(width: 8),

                    SizedBox(
                        height: 41,
                        child: IntrinsicWidth(
                          child: DropdownButtonFormField<int>(
                            elevation: 0,
                            dropdownColor: colorConfig.cardColor,
                            decoration: inputDecorationMaker(),
                            value: eventDetailState.formEndYear,
                            items: yearList.value.map((year) {
                              return dropdownMenuItemMaker<int>(int.parse(year),
                                  '$year年');
                            }).toList(),
                            onChanged: (value) async {
                              eventDetailState.formEndYear = value!;
                              endDayList.value = createDayList(
                                  eventDetailState.formEndYear,
                                  eventDetailState.formEndMonth);
                              if (!validateDate(eventDetailState.formEndYear,
                                  eventDetailState.formEndMonth,
                                  eventDetailState.formEndDay)) {
                                eventDetailState.formEndDay = 1;
                              }
                            },
                          ),
                        )
                    ),

                    const SizedBox(width: 6),

                    SizedBox(
                        height: 41,
                        child: IntrinsicWidth(
                          child: DropdownButtonFormField<int>(
                            elevation: 0,
                            dropdownColor: colorConfig.cardColor,
                            decoration: inputDecorationMaker(),
                            value: eventDetailState.formEndMonth,
                            items: monthList.value.map((month) {
                              return dropdownMenuItemMaker<int>(int.parse(month),
                                  '$month月');
                            }).toList(),
                            onChanged: (value) async {
                              eventDetailState.formEndMonth = value!;
                              endDayList.value = createDayList(
                                  eventDetailState.formEndYear,
                                  eventDetailState.formEndMonth);
                              if (!validateDate(eventDetailState.formEndYear,
                                  eventDetailState.formEndMonth,
                                  eventDetailState.formEndDay)) {
                                eventDetailState.formEndDay = 1;
                              }
                            },
                          ),
                        )
                    ),

                    const SizedBox(width: 6),

                    SizedBox(
                        height: 41,
                        child: IntrinsicWidth(
                          child: DropdownButtonFormField<int>(
                            elevation: 0,
                            dropdownColor: colorConfig.cardColor,
                            decoration: inputDecorationMaker(),
                            value: eventDetailState.formEndDay,
                            items: endDayList.value.map((day) {
                              return dropdownMenuItemMaker<int>(int.parse(day),
                                  '$day日');
                            }).toList(),
                            onChanged: (value) async {
                              eventDetailState.formEndDay = value!;
                            },
                          ),
                        )
                    ),


                    const Spacer()
                  ]),

                  const SizedBox(height: 8),

                  Row(children: [
                    Container(width: 52),

                    const SizedBox(width: 8),

                    SizedBox(
                        height: 41,
                        child: IntrinsicWidth(
                          child: DropdownButtonFormField<int>(
                            elevation: 0,
                            dropdownColor: colorConfig.cardColor,
                            decoration: inputDecorationMaker(),
                            value: eventDetailState.formEndHour,
                            items: hourList.value.map((hour) {
                              return dropdownMenuItemMaker<int>(int.parse(hour),
                                  hour);
                            }).toList(),
                            onChanged: (value) async {
                              eventDetailState.formEndHour = value!;
                            },
                          ),
                        )
                    ),

                    const SizedBox(width: 6),

                    Text(':', textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 21,
                            color: normalTextColor
                        )
                    ),

                    const SizedBox(width: 6),

                    SizedBox(
                        height: 41,
                        child: IntrinsicWidth(
                          child: DropdownButtonFormField<int>(
                            elevation: 0,
                            dropdownColor: colorConfig.cardColor,
                            decoration: inputDecorationMaker(),
                            value: eventDetailState.formEndMinute,
                            items: minuteList.value.map((minute) {
                              return dropdownMenuItemMaker<int>(
                                  int.parse(minute), minute);
                            }).toList(),
                            onChanged: (value) async {
                              eventDetailState.formEndMinute = value!;
                            },
                          ),
                        )
                    ),

                    const Spacer()
                  ]),
              ]),

              const SizedBox(height: 8),

              Row(children: [
                SizedBox(width: 52,
                    child: Text('繰返し',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            color: normalTextColor
                        )
                    )
                ),

                const SizedBox(width: 8),

                SizedBox(
                    height: 41,
                    child: IntrinsicWidth(
                      child: DropdownButtonFormField<RepeatingPattern>(
                        elevation: 0,
                        dropdownColor: colorConfig.cardColor,
                        decoration: inputDecorationMaker(),
                        value: eventDetailState.repeatingPattern,
                        items: RepeatingPattern.values.map((pattern) {
                          return dropdownMenuItemMaker<RepeatingPattern>(
                              pattern, pattern.name);
                        }).toList(),
                        onChanged: (value) async {
                          if (value != null) {
                            eventDetailState.repeatingPattern = value;
                            if (eventDetailState.repeatingPattern
                                == RepeatingPattern.none) {
                              eventDetailState.repeatingEnd = false;
                            }
                          }
                        },
                      ),
                    )
                ),

                const Spacer()
              ]),

              if (eventDetailState.repeatingPattern != RepeatingPattern.none)
                Column(children: [
                  const SizedBox(height: 8),

                  Row(children: [
                    SizedBox(width: 52,
                        child: Text('繰返し終了',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 13,
                                color: normalTextColor
                            )
                        )
                    ),

                    const SizedBox(width: 8),

                    SizedBox(
                        height: 41,
                        child: CupertinoSwitch(
                          value: eventDetailState.repeatingEnd!,
                          onChanged: (value) {
                            eventDetailState.repeatingEnd = value;
                            if (eventDetailState.repeatingEnd!) {
                              eventDetailState.formRepeatEndYear
                                = eventDetailState.formEndYear;
                              eventDetailState.formRepeatEndMonth
                                = eventDetailState.formEndMonth;
                              eventDetailState.formRepeatEndDay
                                = eventDetailState.formEndDay;
                            }
                          },
                        )
                    ),

                    const Spacer()
                  ]),

                  if (eventDetailState.repeatingEnd!)
                    Column(children: [
                      const SizedBox(height: 8),

                      Row(children: [
                        SizedBox(width: 52,
                            child: Text('繰返し終了日',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: normalTextColor
                                )
                            )
                        ),

                        const SizedBox(width: 8),

                        SizedBox(
                            height: 41,
                            child: IntrinsicWidth(
                              child: DropdownButtonFormField<int>(
                                elevation: 0,
                                dropdownColor: colorConfig.cardColor,
                                decoration: inputDecorationMaker(),
                                value: eventDetailState.formRepeatEndYear,
                                items: yearList.value.map((year) {
                                  return dropdownMenuItemMaker<int>(int
                                      .parse(year), '$year年');
                                }).toList(),
                                onChanged: (value) async {
                                  eventDetailState.formRepeatEndYear = value!;
                                  repeatingEndDayList.value = createDayList(
                                      eventDetailState.formRepeatEndYear,
                                      eventDetailState.formRepeatEndMonth);
                                  if (!validateDate(eventDetailState
                                      .formRepeatEndYear,
                                      eventDetailState.formRepeatEndMonth,
                                      eventDetailState.formRepeatEndDay)) {
                                    eventDetailState.formRepeatEndDay = 1;
                                  }
                                },
                              ),
                            )
                        ),

                        const SizedBox(width: 6),

                        SizedBox(
                            height: 41,
                            child: IntrinsicWidth(
                              child: DropdownButtonFormField<int>(
                                elevation: 0,
                                dropdownColor: colorConfig.cardColor,
                                decoration: inputDecorationMaker(),
                                value: eventDetailState.formRepeatEndMonth,
                                items: monthList.value.map((month) {
                                  return dropdownMenuItemMaker<int>(int
                                      .parse(month), '$month月');
                                }).toList(),
                                onChanged: (value) async {
                                  eventDetailState.formRepeatEndMonth = value!;
                                  repeatingEndDayList.value = createDayList(
                                      eventDetailState.formRepeatEndYear,
                                      eventDetailState.formRepeatEndMonth);
                                  if (!validateDate(eventDetailState
                                      .formRepeatEndYear,
                                      eventDetailState.formRepeatEndMonth,
                                      eventDetailState.formRepeatEndDay)) {
                                    eventDetailState.formRepeatEndDay = 1;
                                  }
                                },
                              ),
                            )
                        ),

                        const SizedBox(width: 6),

                        SizedBox(
                            height: 41,
                            child: IntrinsicWidth(
                              child: DropdownButtonFormField<int>(
                                elevation: 0,
                                dropdownColor: colorConfig.cardColor,
                                decoration: inputDecorationMaker(),
                                value: eventDetailState.formRepeatEndDay,
                                items: repeatingEndDayList.value.map((day) {
                                  return dropdownMenuItemMaker<int>(
                                      int.parse(day), '$day日');
                                }).toList(),
                                onChanged: (value) async {
                                  eventDetailState.formRepeatEndDay = value!;
                                },
                              ),
                            )
                        ),

                        const Spacer()
                      ]),
                    ])
              ]),

              const SizedBox(height: 8),

              Row(children: [
                SizedBox(width: 52,
                    child: Text('メモ', textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            color: normalTextColor
                        )
                    )
                ),

                const SizedBox(width: 8),

                Expanded(
                    child: SizedBox(
                        height: 210,
                        child: TextField(
                            style: const TextStyle(fontSize: 13),
                            decoration: inputDecorationMaker(hintText: 'メモ'),
                            // keyboardType: TextInputType.multiline,
                            maxLines: 40,

                            onTap: () {
                              safeAreaViewNotifier.setSafeAreaAdjustment(9);
                            },
                            onChanged: (text) {
                              debugPrint('Textの変更検知={$text}');
                            }
                        )
                    )
                ),
              ]),

              const SizedBox(height: 8),

              Row(children: [
                SizedBox(width: 52,
                    child: Text('保存先カレンダー',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            color: normalTextColor
                        )
                    )
                ),

                const SizedBox(width: 8),

                Expanded(
                    child: SizedBox(
                        height: 41,
                        child: TextField(
                          enabled: true,
                          readOnly: true,
                          scrollPhysics: const
                          NeverScrollableScrollPhysics(),
                          controller: TextEditingController(
                              text: 'カレンダー1あああああああああああああああああ'
                                  'ああああああああああ'),
                          style: TextStyle(fontSize: 13,
                              color: normalTextColor),
                          decoration: inputDecorationMaker(),
                          maxLines: 1,
                          onTap: () async {
                            await safeAreaViewNotifier
                                .setSafeAreaAdjustment(11);
                            await safeAreaViewNotifier.setSafeAreaHeight(216);
                            await safeAreaViewNotifier.updateState();
                            await showBottomArea(Container());
                          },
                        )
                    )
                ),
              ]),

              // if (calendarId.value != prevCalendarId.value)
                Column(children: [
                  const SizedBox(height: 8),

                  Row(children: [
                    SizedBox(width: 52,
                        child: Text('移動元カレンダー',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 13,
                                color: normalTextColor
                            )
                        )
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                        child: SizedBox(
                            height: 41,
                            child: TextField(
                              enabled: true,
                              readOnly: true,
                              scrollPhysics: const
                                NeverScrollableScrollPhysics(),
                              controller: TextEditingController(
                                  text: 'カレンダー1あああああああああああああああああ'
                                      'ああああああああああ'),
                              style: TextStyle(fontSize: 13,
                              color: normalTextColor),
                              decoration: inputDecorationMaker(),
                              maxLines: 1,
                              onTap: () async {
                                await safeAreaViewNotifier
                                    .setSafeAreaAdjustment(11);
                                await safeAreaViewNotifier.setSafeAreaHeight(216);
                                await safeAreaViewNotifier.updateState();
                                await showBottomArea(Container());
                              },
                            )
                        )
                    )
                  ]),
                ]),
            ]
        )
    );

    var baseContentsHeight = eventDetailState.contentsHeight!
      + widget.unsafeAreaTopHeight + widget.unsafeAreaBottomHeight;
    var contentHeight = baseContentsHeight
        < deviceHeight ? deviceHeight : baseContentsHeight;

    return BottomSafeAreaView(
        unsafeAreaTopHeight: widget.unsafeAreaTopHeight,
        unsafeAreaBottomHeight: widget.unsafeAreaBottomHeight,
        contentsWidth: deviceWidth,
        contentsHeight: contentHeight,
        child: Column(children: [
          SizedBox(width: deviceWidth, height: widget.unsafeAreaTopHeight),

          const Spacer(),

          Center(
              child: SizedBox(width: pageWidget,
                  child: Container(
                      key: eventDetailState.contentsKey,
                      decoration: BoxDecoration(
                        color: colorConfig.backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: contents)
              )
          ),

          const Spacer(),

          SizedBox(width: deviceWidth, height: widget.unsafeAreaBottomHeight),
        ])
    );
  }
}