import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'f002_home_view_model.dart';
import 'f016_design.dart';
import 'f018_event_detail_view_model.dart';

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
    var normalTextColor = colorConfigState.colorConfig!.normalTextColor;
    var borderColor = colorConfigState.colorConfig!.normalTextColor;
    var backgroundColor = colorConfigState.colorConfig!.backgroundColor;
    final homeNotifier = ref.watch(homePageNotifierProvider.notifier);
    final eventDetailState = ref.watch(eventDetailPageNotifierProvider);
    final eventDetailNotifier = ref.watch(eventDetailPageNotifierProvider
        .notifier);

    // 画面の幅
    double deviceWidth = MediaQuery.of(context).size.width;
    // キーボードの高さ
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    // ページの幅
    double pageWidget = deviceWidth * 0.9;

    // 閉じるボタンの幅
    double closingButtonWidth = 39;


    final formAllDay = useState(false);
    final formStartYear = useState(2024);
    final formStartMonth = useState(4);
    final formStartDay = useState(30);
    final formStartHour = useState(7);
    final formStartMinute = useState(30);

    final formEndYear = useState(2024);
    final formEndMonth = useState(4);
    final formEndDay = useState(30);
    final formEndHour = useState(07);
    final formEndMinute = useState(30);

    final yearList = useState<List<String>>([]);
    final monthList = useState<List<String>>([]);
    final startDayList = useState<List<String>>([]);

    final endDayList = useState<List<String>>([]);

    final hourList = useState<List<String>>([]);
    final minuteList = useState<List<String>>([]);

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

    makerInputDecoration({String? hintText}) {
      return InputDecoration(
        contentPadding: const EdgeInsets.all(8),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: borderColor,
                width: 1)
        ),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: theme.primaryColor,
                width: 2)
        ),
        hintText: hintText,
      );
    }

    itemMaker(value, title) {
      return DropdownMenuItem<int>(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                SizedBox(width: closingButtonWidth,
                    height: closingButtonWidth,
                    child: TextButton(
                      onPressed: () async {
                        // Navigator.pop(context);

                        homeNotifier.setUICover(false);
                        homeNotifier.setUICoverWidget(null);
                        homeNotifier.resetUICoverWidgetHeight();
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
              ]),

              const Spacer(),

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
                        // controller: textField1Controller,
                          style: const TextStyle(fontSize: 13),
                          decoration: makerInputDecoration(hintText: 'タイトル'),
                          // keyboardType: TextInputType.multiline,
                          // maxLines: 2,
                          onTap: () {
                            homeNotifier.setKeyboardAdjustment(15);
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
                          // controller: textField1Controller,
                            style: const TextStyle(fontSize: 13),
                            decoration: makerInputDecoration(hintText: '場所'),
                            // keyboardType: TextInputType.multiline,
                            // maxLines: 1,
                            onTap: () {
                              homeNotifier.setKeyboardAdjustment(15);
                            },
                            onChanged: (text) {
                              debugPrint('Textの変更検知={$text}');
                            }
                        )
                    )
                ),
              ]),

              const SizedBox(height: 16),

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
                      value: formAllDay.value,
                      onChanged: (value) {
                        formAllDay.value = value;
                      },
                    )
                ),
                const Spacer(),
              ]),

              const SizedBox(height: 16),

              Row(children: [
                SizedBox(width: 52,
                    child: Text('開始', textAlign: TextAlign.center,
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
                        decoration: makerInputDecoration(),
                        value: formStartYear.value,
                        items: yearList.value.map((year) {
                          return itemMaker(int.parse(year), '$year年');
                        }).toList(),
                        onChanged: (value) async {
                          formStartYear.value = value!;
                          startDayList.value = createDayList(formStartYear.value,
                              formStartMonth.value);
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
                        decoration: makerInputDecoration(),
                        value: formStartMonth.value,
                        items: monthList.value.map((month) {
                          return itemMaker(int.parse(month), '$month月');
                        }).toList(),
                        onChanged: (value) async {
                          formStartMonth.value = value!;
                          startDayList.value = createDayList(formStartYear.value,
                              formStartMonth.value);
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
                        decoration: makerInputDecoration(),
                        value: formStartDay.value,
                        items: startDayList.value.map((day) {
                          return itemMaker(int.parse(day), '$day日');
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

              Row(children: [
                Container(width: 52),

                const SizedBox(width: 8),

                SizedBox(
                    height: 41,
                    child: IntrinsicWidth(
                      child: DropdownButtonFormField<int>(
                        elevation: 0,
                        dropdownColor: theme.cardColor,
                        decoration: makerInputDecoration(),
                        value: formStartHour.value,
                        items: hourList.value.map((hour) {
                          return itemMaker(int.parse(hour), hour);
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
                        decoration: makerInputDecoration(),
                        value: formStartMinute.value,
                        items: minuteList.value.map((minute) {
                          return itemMaker(int.parse(minute), minute);
                        }).toList(),
                        onChanged: (value) async {
                          formStartMinute.value = value!;
                        },
                      ),
                    )
                ),

                const Spacer()
              ]),

              const SizedBox(height: 16),
/*
              Row(children: [
                SizedBox(width: 52,
                    child: Text('終了', textAlign: TextAlign.center,
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
                        decoration: makerInputDecoration(),
                        value: formEndYear.value,
                        items: yearList.value.map((year) {
                          return itemMaker(int.parse(year), '$year年');
                        }).toList(),
                        onChanged: (value) async {
                          formEndYear.value = value!;
                          startDayList.value = createDayList(formEndYear.value,
                              formEndMonth.value);
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
                        decoration: makerInputDecoration(),
                        value: formEndMonth.value,
                        items: monthList.value.map((month) {
                          return itemMaker(int.parse(month), '$month月');
                        }).toList(),
                        onChanged: (value) async {
                          formEndMonth.value = value!;
                          startDayList.value = createDayList(formEndYear.value,
                              formEndMonth.value);
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
                        decoration: makerInputDecoration(),
                        value: formEndDay.value,
                        items: startDayList.value.map((day) {
                          return itemMaker(int.parse(day), '$day日');
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
                        decoration: makerInputDecoration(),
                        value: formEndHour.value,
                        items: hourList.value.map((hour) {
                          return itemMaker(int.parse(hour), hour);
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
                        decoration: makerInputDecoration(),
                        value: formEndMinute.value,
                        items: minuteList.value.map((minute) {
                          return itemMaker(int.parse(minute), minute);
                        }).toList(),
                        onChanged: (value) async {
                          formEndMinute.value = value!;
                        },
                      ),
                    )
                ),


                const Spacer()
              ]),
              */
              // const Spacer(),

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
                        height: 410 + 200,
                        child: TextField(
                          // controller: textField1Controller,
                            style: const TextStyle(fontSize: 13),
                            decoration: makerInputDecoration(hintText: 'メモ'),
                            // keyboardType: TextInputType.multiline,
                            maxLines: 40,

                            onTap: () {
                              homeNotifier.setKeyboardAdjustment(15);
                            },
                            onChanged: (text) {
                              debugPrint('Textの変更検知={$text}');
                            }
                        )
                    )
                ),
              ]),
            ]
        )
    );

    var center = Center(
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
    );

    return Column(children: [
      SizedBox(width: deviceWidth, height: widget.unsafeAreaTopHeight),

      // const Spacer(),
      // SizedBox(width: pageWidget, height: eventDetailState.contentsHeight!
      //     - widget.unsafeAreaTopHeight
      //     - widget.unsafeAreaBottomHeight,
      //     child: Container(
      //         decoration: BoxDecoration(
      //           color: theme.colorScheme.background,
      //           borderRadius: BorderRadius.circular(16),
      //         ),
      //         child: contents)
      // ),

      const Spacer(),
      center,
      const Spacer(),

      SizedBox(width: deviceWidth, height: widget.unsafeAreaBottomHeight),
    ]);
  }
}