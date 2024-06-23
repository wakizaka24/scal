import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'f001_home_page.dart';
import 'f002_home_view_model.dart';
import 'f005_calendar_view_model.dart';
import 'f016_design.dart';
import 'f018_event_detail_view_model.dart';
import 'f021_keyboard_safe_area_view.dart';
import 'f024_keyboard_safe_area_view_model.dart';

enum RepeatingPattern {
  none('なし'),
  daily('毎日'),
  weekly('毎週'),
  biweekly('隔週'),
  monthly('毎月'),
  yearly('毎年');

  const RepeatingPattern(this.name);

  final String name;
}

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
    final theme = Theme.of(context);
    final colorConfigState = ref.watch(designConfigNotifierProvider);
    final colorConfig = colorConfigState.colorConfig!;
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

    final keyboardViewState = ref.watch(keyboardSafeAreaViewNotifierProvider);
    final keyboardViewNotifier = ref.watch(keyboardSafeAreaViewNotifierProvider
        .notifier);

    final eventDetailState = ref.watch(eventDetailPageNotifierProvider);
    final eventDetailNotifier = ref.watch(eventDetailPageNotifierProvider
        .notifier);

    // 画面の幅
    double deviceWidth = MediaQuery.of(context).size.width;
    // 画面の高さ
    double deviceHeight = MediaQuery.of(context).size.height;
    // ページの幅
    double pageWidget = deviceWidth * 0.95;

    // 閉じるボタンの幅
    double closingButtonWidth = 39;

    final allDay = useState(false);
    final formStartYear = useState(2024);
    final formStartMonth = useState(4);
    final formStartDay = useState(30);
    final formStartHour = useState(7);
    final formStartMinute = useState(30);
    final formEndYear = useState(2025);
    final formEndMonth = useState(5);
    final formEndDay = useState(31);
    final formEndHour = useState(08);
    final formEndMinute = useState(31);

    final repeatingPattern = useState<RepeatingPattern>(RepeatingPattern.none);
    final repeatingEnd = useState(false);
    final formRepeatEndYear = useState<int?>(null);
    final formRepeatEndMonth = useState<int?>(null);
    final formRepeatEndDay = useState<int?>(null);
    final calendarId = useState('TEST_ID_1');
    final prevCalendarId = useState('TEST_ID_1');

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
      eventDetailNotifier.setDeviceHeight(deviceHeight);
      keyboardViewState.keyboardScrollController = ScrollController();

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
      startDayList.value = createDayList(formStartYear.value,
          formStartMonth.value);
      return () {
      };
    }, [formStartYear.value, formStartMonth.value]);

    useEffect(() {
      endDayList.value = createDayList(formEndYear.value,
          formEndMonth.value);
      return () {
      };
    }, [formEndYear.value, formEndMonth.value]);

    useEffect(() {
      endDayList.value = createDayList(formEndYear.value,
          formEndMonth.value);
      return () {
      };
    }, [formEndYear.value, formEndMonth.value]);

    useEffect(() {
      if (formRepeatEndYear.value != null && formRepeatEndMonth.value != null) {
        repeatingEndDayList.value = createDayList(formRepeatEndYear.value,
            formRepeatEndMonth.value);
      }
      return () {
      };
    }, [formRepeatEndYear.value, formRepeatEndMonth.value]);

    inputDecorationMaker({String? hintText}) {
      return InputDecoration(
        contentPadding: const EdgeInsets.all(8),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: colorConfig.eventListTitleBgColor, width: 1)
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
            )
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
                        var contentsMode = eventDetailState.contentsMode;
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

              const SizedBox(height: 8),

              Row(children: [
                SizedBox(width: 52,
                  child: Text('タイトル', textAlign: TextAlign.center,
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
                          style: const TextStyle(fontSize: 13),
                          decoration: inputDecorationMaker(hintText: 'タイトル'),
                          // keyboardType: TextInputType.multiline,
                          // maxLines: 2,
                          onTap: () {
                            keyboardViewNotifier.setKeyboardAdjustment(11.5);
                          },
                          onChanged: (text) {
                            debugPrint('Textの変更検知={$text}');
                          }
                      )
                  )
                ),
                const SizedBox(width: 45)
              ]),

              const SizedBox(height: 8),

              Row(children: [
                SizedBox(width: 52,
                    child: Text('場所', textAlign: TextAlign.center,
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
                            style: const TextStyle(fontSize: 13),
                            decoration: inputDecorationMaker(hintText: '場所'),
                            // keyboardType: TextInputType.multiline,
                            // maxLines: 1,
                            onTap: () {
                              keyboardViewNotifier.setKeyboardAdjustment(11.5);
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
                    child: Text('終日', textAlign: TextAlign.center,
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
                      value: allDay.value,
                      onChanged: (value) {
                        allDay.value = value;
                      },
                    )
                ),

                const Spacer(),
              ]),

              const SizedBox(height: 8),

              Row(children: [
                SizedBox(width: 52,
                    child: Text(allDay.value ? '日付' : '開始',
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
                        dropdownColor: theme.cardColor,
                        decoration: inputDecorationMaker(),
                        value: formStartYear.value,
                        items: yearList.value.map((year) {
                          return dropdownMenuItemMaker<int>(int.parse(year),
                              '$year年');
                        }).toList(),
                        onChanged: (value) async {
                          formStartYear.value = value!;
                          startDayList.value = createDayList(formStartYear
                              .value, formStartMonth.value);
                          if (!validateDate(formStartYear.value,
                              formStartMonth.value,
                              formStartDay.value)) {
                            formStartDay.value = 1;
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
                        dropdownColor: theme.cardColor,
                        decoration: inputDecorationMaker(),
                        value: formStartMonth.value,
                        items: monthList.value.map((month) {
                          return dropdownMenuItemMaker<int>(int.parse(month),
                              '$month月');
                        }).toList(),
                        onChanged: (value) async {
                          formStartMonth.value = value!;
                          startDayList.value = createDayList(formStartYear
                              .value, formStartMonth.value);
                          if (!validateDate(formStartYear.value,
                              formStartMonth.value,
                              formStartDay.value)) {
                            formStartDay.value = 1;
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
                        dropdownColor: theme.cardColor,
                        decoration: inputDecorationMaker(),
                        value: formStartDay.value,
                        items: startDayList.value.map((day) {
                          return dropdownMenuItemMaker<int>(int.parse(day),
                              '$day日');
                        }).toList(),
                        onChanged: (value) async {
                          formStartDay.value = value!;
                        },
                      ),
                    )
                ),
                const Spacer()
              ]),

              const SizedBox(height: 8),

              if (!allDay.value)
                Row(children: [
                  Container(width: 52),

                  const SizedBox(width: 8),

                  SizedBox(
                      height: 41,
                      child: IntrinsicWidth(
                        child: DropdownButtonFormField<int>(
                          elevation: 0,
                          dropdownColor: theme.cardColor,
                          decoration: inputDecorationMaker(),
                          value: formStartHour.value,
                          items: hourList.value.map((hour) {
                            return dropdownMenuItemMaker<int>(int.parse(hour),
                                hour);
                          }).toList(),
                          onChanged: (value) async {
                            formStartHour.value = value!;
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
                          dropdownColor: theme.cardColor,
                          decoration: inputDecorationMaker(),
                          value: formStartMinute.value,
                          items: minuteList.value.map((minute) {
                            return dropdownMenuItemMaker<int>(int.parse(minute),
                                minute);
                          }).toList(),
                          onChanged: (value) async {
                            formStartMinute.value = value!;
                          },
                        ),
                      )
                  ),

                  const Spacer()
                ]),

              if (!allDay.value)
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
                            dropdownColor: theme.cardColor,
                            decoration: inputDecorationMaker(),
                            value: formEndYear.value,
                            items: yearList.value.map((year) {
                              return dropdownMenuItemMaker<int>(int.parse(year),
                                  '$year年');
                            }).toList(),
                            onChanged: (value) async {
                              formEndYear.value = value!;
                              endDayList.value = createDayList(formEndYear
                                  .value, formEndMonth.value);
                              if (!validateDate(formEndYear.value,
                                  formEndMonth.value,
                                  formEndDay.value)) {
                                formEndDay.value = 1;
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
                            dropdownColor: theme.cardColor,
                            decoration: inputDecorationMaker(),
                            value: formEndMonth.value,
                            items: monthList.value.map((month) {
                              return dropdownMenuItemMaker<int>(int.parse(month),
                                  '$month月');
                            }).toList(),
                            onChanged: (value) async {
                              formEndMonth.value = value!;
                              endDayList.value = createDayList(formEndYear
                                  .value, formEndMonth.value);
                              if (!validateDate(formEndYear.value,
                                  formEndMonth.value,
                                  formEndDay.value)) {
                                formEndDay.value = 1;
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
                            dropdownColor: theme.cardColor,
                            decoration: inputDecorationMaker(),
                            value: formEndDay.value,
                            items: endDayList.value.map((day) {
                              return dropdownMenuItemMaker<int>(int.parse(day),
                                  '$day日');
                            }).toList(),
                            onChanged: (value) async {
                              formEndDay.value = value!;
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
                            dropdownColor: theme.cardColor,
                            decoration: inputDecorationMaker(),
                            value: formEndHour.value,
                            items: hourList.value.map((hour) {
                              return dropdownMenuItemMaker<int>(int.parse(hour),
                                  hour);
                            }).toList(),
                            onChanged: (value) async {
                              formEndHour.value = value!;
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
                            dropdownColor: theme.cardColor,
                            decoration: inputDecorationMaker(),
                            value: formEndMinute.value,
                            items: minuteList.value.map((minute) {
                              return dropdownMenuItemMaker<int>(
                                  int.parse(minute), minute);
                            }).toList(),
                            onChanged: (value) async {
                              formEndMinute.value = value!;
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
                        dropdownColor: theme.cardColor,
                        decoration: inputDecorationMaker(),
                        value: repeatingPattern.value,
                        items: RepeatingPattern.values.map((pattern) {
                          return dropdownMenuItemMaker<RepeatingPattern>(
                              pattern, pattern.name);
                        }).toList(),
                        onChanged: (value) async {
                          if (value != null) {
                            repeatingPattern.value = value;
                            if (repeatingPattern.value == RepeatingPattern
                                .none) {
                              repeatingEnd.value = false;
                            }
                          }
                        },
                      ),
                    )
                ),

                const Spacer()
              ]),

              if (repeatingPattern.value != RepeatingPattern.none)
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
                          value: repeatingEnd.value,
                          onChanged: (value) {
                            repeatingEnd.value = value;
                            if (repeatingEnd.value) {
                              formRepeatEndYear.value = formEndYear.value;
                              formRepeatEndMonth.value = formEndMonth.value;
                              formRepeatEndDay.value = formEndDay.value;
                            }
                          },
                        )
                    ),

                    const Spacer()
                  ]),

                  if (repeatingEnd.value)
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
                                dropdownColor: theme.cardColor,
                                decoration: inputDecorationMaker(),
                                value: formRepeatEndYear.value,
                                items: yearList.value.map((year) {
                                  return dropdownMenuItemMaker<int>(int
                                      .parse(year), '$year年');
                                }).toList(),
                                onChanged: (value) async {
                                  formRepeatEndYear.value = value!;
                                  repeatingEndDayList.value = createDayList(
                                      formRepeatEndYear.value,
                                      formRepeatEndMonth.value);
                                  if (!validateDate(formRepeatEndYear.value,
                                      formRepeatEndMonth.value,
                                      formRepeatEndDay.value)) {
                                    formRepeatEndDay.value = 1;
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
                                dropdownColor: theme.cardColor,
                                decoration: inputDecorationMaker(),
                                value: formRepeatEndMonth.value,
                                items: monthList.value.map((month) {
                                  return dropdownMenuItemMaker<int>(int
                                      .parse(month), '$month月');
                                }).toList(),
                                onChanged: (value) async {
                                  formRepeatEndMonth.value = value!;
                                  repeatingEndDayList.value = createDayList(
                                      formRepeatEndYear.value,
                                      formRepeatEndMonth.value);
                                  if (!validateDate(formRepeatEndYear.value,
                                      formRepeatEndMonth.value,
                                      formRepeatEndDay.value)) {
                                    formRepeatEndDay.value = 1;
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
                                dropdownColor: theme.cardColor,
                                decoration: inputDecorationMaker(),
                                value: formRepeatEndDay.value,
                                items: repeatingEndDayList.value.map((day) {
                                  return dropdownMenuItemMaker<int>(
                                      int.parse(day), '$day日');
                                }).toList(),
                                onChanged: (value) async {
                                  formRepeatEndDay.value = value!;
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
                              keyboardViewNotifier.setKeyboardAdjustment(9);
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

                Expanded(child:
                  SizedBox(
                      height: 41,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        elevation: 0,
                        dropdownColor: theme.cardColor,
                        decoration: inputDecorationMaker(),
                        value: calendarId.value,
                        items: calendarList.value.map((calendar) {
                          return dropdownMenuItemMaker<String>(
                              calendar[0], calendar[1]);
                        }).toList(),
                        onChanged: (value) async {
                          if (value != null) {
                            calendarId.value = value;
                          }
                        },
                      )
                  )
                ),
              ]),

              if (calendarId.value != prevCalendarId.value)
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
                              enabled: false,
                              controller: TextEditingController(
                                  text: 'カレンダー1あああああああああああああああああ'
                                      'ああああああああああ'),
                              style: TextStyle(fontSize: 13,
                              color: normalTextColor),
                              decoration: inputDecorationMaker()
                            )
                        )
                    )
                  ]),
                ]),
            ]
        )
    );

    var contentHeight = eventDetailState.contentsHeight!
        < eventDetailState.deviceHeight! ? eventDetailState.deviceHeight!
        : eventDetailState.contentsHeight!;

    return KeyboardSafeAreaView(
        keyboardScrollController: keyboardViewState
            .keyboardScrollController!,
        unsafeAreaTopHeight: widget.unsafeAreaTopHeight,
        unsafeAreaBottomHeight: widget.unsafeAreaBottomHeight,
        contentsWidth: deviceWidth,
        contentsHeight: contentHeight,
        child: Column(children: [
          SizedBox(width: deviceWidth, height: widget.unsafeAreaTopHeight),

          const Spacer(),
          Center(
              child: SizedBox(width: pageWidget, height: eventDetailState
                  .contentsHeight! - widget.unsafeAreaTopHeight
                  - widget.unsafeAreaBottomHeight,
                  child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.background,
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