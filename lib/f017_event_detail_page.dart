import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scal/f013_ui_utils.dart';

import 'f002_home_view_model.dart';
import 'f005_calendar_view_model.dart';
import 'f015_calendar_utils.dart';
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

    final calendarNotifier = ref.watch(calendarPageNotifierProvider
        .notifier);

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

    // 最小年
    int minimumYear = 1800;

    // 最大年
    int maximumYear = DateTime.now().year + 300;

    useEffect(() {

      return () {
      };
    }, const []);

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

    Function (bool hasFocus) createOnTextFocusChange(HighlightItem item) {
      return (bool hasFocus) async {
        reset() async {
          await safeAreaViewNotifier.downBottomSheet();
        }
        if (hasFocus) {
          await reset();
          await eventDetailNotifier.updateHighlightItem(item);
          await safeAreaViewNotifier.setSafeAreaAdjustment(8 + 6);
        } else {
          // 他のテキストにフォーカス時は動かない
          await reset();
        }
      };
    }

    Function (bool hasFocus) createOnBottomPopTextFocusChange(
        HighlightItem item, Widget child) {
      return (bool hasFocus) async {
        reset() async {
          await safeAreaViewNotifier.downBottomSheet();
        }
        if (hasFocus) {
          await reset();
          await eventDetailNotifier.updateHighlightItem(item);
          await safeAreaViewNotifier.setSafeAreaAdjustment(5 + 8);
          await safeAreaViewNotifier.setSafeAreaHeight(215);
          await safeAreaViewNotifier.updateState();
          showBottomArea(child);
        } else {
          // 他のテキストにフォーカス時は動かない
          await reset();
        }
      };
    }

    onCommonPressed() async {
      primaryFocus?.unfocus();

      // ハイライト解除
      await eventDetailNotifier.updateHighlightItem(
          HighlightItem.none);

      await safeAreaViewNotifier.downBottomSheet();
    }

    var startDatePicker = CupertinoDatePicker(
      initialDateTime: eventDetailState.startDate,
      mode: CupertinoDatePickerMode.date,
      minimumYear: minimumYear,
      maximumYear: maximumYear,
      onDateTimeChanged: (DateTime newDate) {
        eventDetailNotifier.setTextFieldController(TextFieldItem.startDate,
            value: CalendarUtils().copyDate(eventDetailState.startDate!,
                newDate));
      },
    );

    var endDatePicker = CupertinoDatePicker(
      initialDateTime: eventDetailState.endDate,
      mode: CupertinoDatePickerMode.date,
      minimumYear: minimumYear,
      maximumYear: maximumYear,
      onDateTimeChanged: (DateTime newDate) {
        eventDetailNotifier.setTextFieldController(TextFieldItem.endDate,
            value: CalendarUtils().copyDate(eventDetailState
                .endDate!, newDate));
      },
    );

    var startTimePicker = CupertinoDatePicker(
      initialDateTime: eventDetailState.startDate,
      mode: CupertinoDatePickerMode.time,
      // 初期値が設定できない値の場合落ちる
      minuteInterval: 1,
      use24hFormat: true,
      onDateTimeChanged: (DateTime newDate) {
        eventDetailNotifier.setTextFieldController(
            TextFieldItem.startTime,
            value: CalendarUtils()
                .copyTime(eventDetailState.startDate!,
                newDate));
      },
    );

    var endTimePicker = CupertinoDatePicker(
      initialDateTime: eventDetailState.endDate,
      mode: CupertinoDatePickerMode.time,
      // 初期値が設定できない値の場合落ちる
      minuteInterval: 1,
      use24hFormat: true,
      onDateTimeChanged: (DateTime newDate) {
        eventDetailNotifier.setTextFieldController(
            TextFieldItem.endTime,
            value: CalendarUtils().copyTime(eventDetailState
                .endDate!, newDate));
      },
    );

    var repeatPicker = CupertinoPicker(
        itemExtent: 32,
        scrollController:
        FixedExtentScrollController(
          initialItem: RepeatingPattern.values.indexOf(eventDetailState
              .repeatingPattern!),
        ),
        onSelectedItemChanged: (int index) {
          var repeatingPattern =
          RepeatingPattern.values[index];
          eventDetailNotifier.setTextFieldController(TextFieldItem.repeat,
              value: repeatingPattern);
          if (repeatingPattern == RepeatingPattern.none) {
            eventDetailNotifier.setRepeatingEnd(false);
          }
          eventDetailNotifier.updateState();
        },
        children: List<Widget>.generate(RepeatingPattern.values.length,
                (int index) {
          return Center(child: Text(RepeatingPattern.values[index].name));
        })
    );

    var repeatingEndDatePicker = CupertinoDatePicker(
      initialDateTime: eventDetailState.repeatingEndDate,
      mode: CupertinoDatePickerMode.date,
      onDateTimeChanged: (DateTime newDate) {
        eventDetailNotifier.setTextFieldController(
            TextFieldItem.repeatingEndDate,
            value: CalendarUtils().copyDate(eventDetailState
                .repeatingEndDate!, newDate));
      },
    );

    var contents = Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        child: Column(
            children: [
              Row(children: [
                CWIconButton(
                  icon: Icons.check,
                  width: closingButtonWidth,
                  height: closingButtonWidth,
                  radius: closingButtonWidth / 2,
                  foregroundColor: normalTextColor,
                  onPressed: () async {
                    await onCommonPressed();

                    // if (context.mounted) {
                    //   Navigator.pop(context);
                    // }

                    homeNotifier.setUICover(false);
                    homeNotifier.setUICoverWidget(null);
                    homeNotifier.updateState();
                  },
                ),

                const Spacer(),

                CWIconButton(
                  icon: Icons.check,
                  width: closingButtonWidth,
                  height: closingButtonWidth,
                  radius: closingButtonWidth / 2,
                  foregroundColor: normalTextColor,
                  onPressed: () async {
                    await onCommonPressed();

                  },
                ),

                CWIconButton(
                  icon: Icons.check,
                  width: closingButtonWidth,
                  height: closingButtonWidth,
                  radius: closingButtonWidth / 2,
                  foregroundColor: normalTextColor,
                  onPressed: () async {
                    await onCommonPressed();

                    await colorConfigNotifier.switchColorConfig();
                    await calendarNotifier.initState();
                    await calendarNotifier.updateCalendar(
                        dataExclusion: true);
                    await colorConfigNotifier.updateState();
                  },
                ),
              ]),

              // const SizedBox(height: 500),

              CWLeftTitle(
                  title: 'タイト\nル',
                  highlight: eventDetailState.highlightItem
                      == HighlightItem.title,
                  child: CWTextField(
                      controller: eventDetailState.textEditingControllers!
                      [TextFieldItem.title]!,
                      hintText: 'タイトル',
                      highlight: eventDetailState.highlightItem
                          == HighlightItem.title,
                      maxLines: 2,
                      onFocusChange: createOnTextFocusChange(HighlightItem
                          .title),
                      // onChanged: (text) {
                      //   debugPrint('Textの変更検知={$text}');
                      // }
                  )
              ),

              CWLeftTitle(
                  title: '場所',
                  highlight: eventDetailState.highlightItem
                      == HighlightItem.place,
                  child: SizedBox(
                      height: 36,
                      child: CWTextField(
                        controller: eventDetailState.textEditingControllers!
                        [TextFieldItem.place]!,
                        hintText: '場所',
                        highlight: eventDetailState.highlightItem
                            == HighlightItem.place,
                        onFocusChange: createOnTextFocusChange(HighlightItem
                            .place),
                        // onChanged: (text) {
                        //   debugPrint('Textの変更検知={$text}');
                        // },
                      )
                  )
              ),

              CWLeftTitle(
                  title: '終日',
                  highlight: eventDetailState.highlightItem
                      == HighlightItem.allDay,
                  verticalPaddingWidth: 5,
                  expanded: false,
                  child: CupertinoSwitch(
                    value: eventDetailState.allDay!,
                    onChanged: (value) {
                      primaryFocus?.unfocus();

                      eventDetailState.highlightItem = HighlightItem.allDay;
                      eventDetailState.allDay = value;
                      if (value) {
                        eventDetailState.startDate = CalendarUtils()
                            .trimDate(eventDetailState.startDate!);
                        eventDetailState.endDate = eventDetailState.startDate!
                            .add(const Duration(days: 1));
                      }
                      eventDetailNotifier.updateState();
                    },
                  )
              ),

              CWLeftTitle(
                  title: eventDetailState.allDay! ? '日付' : '開始',
                  highlight: eventDetailState.highlightItem
                      == HighlightItem.startDate
                    || eventDetailState.highlightItem
                          == HighlightItem.startTime,
                  expanded: false,
                  child: Row(children: [
                    SizedBox(
                        width: 120, height: 36,
                        child: CWTextField(
                          controller: eventDetailState.textEditingControllers!
                          [TextFieldItem.startDate]!,
                          fontSize: 15,
                          textAlign: TextAlign.center,
                          paddingAll: 6,
                          readOnly: true,
                          highlight: eventDetailState.highlightItem
                              == HighlightItem.startDate,
                          onFocusChange: createOnBottomPopTextFocusChange(
                              HighlightItem.startDate, startDatePicker)
                        )
                    ),

                    if (!eventDetailState.allDay!)
                      SizedBox(
                        width: 60, height: 36,
                        child: CWTextField(
                            controller: eventDetailState.textEditingControllers!
                            [TextFieldItem.startTime]!,
                            fontSize: 15,
                            textAlign: TextAlign.center,
                            paddingAll: 6,
                            readOnly: true,
                            highlight: eventDetailState.highlightItem
                                == HighlightItem.startTime,
                            onFocusChange: createOnBottomPopTextFocusChange(
                                HighlightItem.startTime, startTimePicker)
                        )
                    ),
                  ])
              ),

              if (!eventDetailState.allDay!)
                CWLeftTitle(
                    title: '終了',
                    highlight: eventDetailState.highlightItem
                        == HighlightItem.endDate
                        || eventDetailState.highlightItem
                            == HighlightItem.endTime,
                    expanded: false,
                    child: Row(children: [
                      SizedBox(
                          width: 120, height: 36,
                          child: CWTextField(
                              controller: eventDetailState
                                  .textEditingControllers!
                              [TextFieldItem.endDate]!,
                              fontSize: 15,
                              textAlign: TextAlign.center,
                              paddingAll: 6,
                              readOnly: true,
                              highlight: eventDetailState.highlightItem
                                  == HighlightItem.endDate,
                              onFocusChange: createOnBottomPopTextFocusChange(
                                  HighlightItem.endDate, endDatePicker)
                          )
                      ),

                      if (!eventDetailState.allDay!)
                        SizedBox(
                            width: 60, height: 36,
                            child: CWTextField(
                                controller: eventDetailState
                                    .textEditingControllers!
                                [TextFieldItem.endTime]!,
                                fontSize: 15,
                                textAlign: TextAlign.center,
                                paddingAll: 6,
                                readOnly: true,
                                highlight: eventDetailState.highlightItem
                                    == HighlightItem.endTime,
                                onFocusChange: createOnBottomPopTextFocusChange(
                                  HighlightItem.endTime, endTimePicker)
                            )
                        ),
                    ])
                ),

              CWLeftTitle(
                  title: '繰返し',
                  highlight: eventDetailState.highlightItem
                      == HighlightItem.repeat,
                  expanded: false,
                  child: Row(children: [
                    SizedBox(
                        width: 65, height: 36,
                        child: CWTextField(
                            controller: eventDetailState.textEditingControllers!
                            [TextFieldItem.repeat]!,
                            fontSize: 14,
                            textAlign: TextAlign.center,
                            paddingAll: 8,
                            readOnly: true,
                            highlight: eventDetailState.highlightItem
                                == HighlightItem.repeat,
                            onFocusChange: createOnBottomPopTextFocusChange(
                                HighlightItem.repeat, repeatPicker)
                        )
                    )
                  ])
              ),

              if (eventDetailState.repeatingPattern != RepeatingPattern.none)
                CWLeftTitle(
                  title: '繰返し\n終了',
                  fontSize: 13,
                  highlight: eventDetailState.highlightItem
                      == HighlightItem.repeatEnd
                      || eventDetailState.highlightItem
                      == HighlightItem.repeatEndDate,
                  verticalPaddingWidth: 5,
                  expanded: false,
                  child: Row(children: [
                    CupertinoSwitch(
                      value: eventDetailState.repeatingEnd!,
                      onChanged: (value) {
                        primaryFocus?.unfocus();

                        eventDetailState.highlightItem = HighlightItem
                            .repeatEnd;
                        eventDetailState.repeatingEnd = value;

                        DateTime? repeatingEndDate;
                        if (value) {
                          repeatingEndDate = eventDetailState.endDate!;
                          if (repeatingEndDate.hour > 0
                              || repeatingEndDate.minute > 0) {
                            repeatingEndDate = CalendarUtils().trimDate(
                                repeatingEndDate).add(const Duration(days: 1));
                          }
                        }
                        eventDetailNotifier.setTextFieldController(
                            TextFieldItem.repeatingEndDate,
                        value: repeatingEndDate);
                        eventDetailNotifier.updateState();
                      },
                    ),
                    if (eventDetailState.repeatingEnd!)
                      SizedBox(
                          width: 120, height: 36,
                          child: CWTextField(
                              controller: eventDetailState
                                  .textEditingControllers!
                              [TextFieldItem.repeatingEndDate]!,
                              textAlign: TextAlign.center,
                              paddingAll: 6,
                              readOnly: true,
                              highlight: eventDetailState.highlightItem
                                  == HighlightItem.repeatEndDate,
                              onFocusChange: createOnBottomPopTextFocusChange(
                                  HighlightItem.repeatEndDate,
                                  repeatingEndDatePicker)
                          )
                      ),
                  ])
              ),

              CWLeftTitle(
                  title: 'メモ',
                  highlight: eventDetailState.highlightItem
                      == HighlightItem.memo,
                  child: CWTextField(
                      controller: eventDetailState.textEditingControllers!
                      [TextFieldItem.memo]!,
                      highlight: eventDetailState.highlightItem
                          == HighlightItem.memo,
                      maxLines: 6,
                      onFocusChange: createOnTextFocusChange(HighlightItem
                          .memo),
                      // onChanged: (text) {
                      //   debugPrint('Textの変更検知={$text}');
                      // }
                  )
              ),

              // 移動する
              // CWLeftTitle(
              //     title: 'カレン\nダー',
              //     // fontSize: 13,
              //     highlight: eventDetailState.highlightItem
              //         == HighlightItem.destinationCalendar,
              //     expanded: false,
              //     child: Row(children: [
              //       SizedBox(height: 36, width: 100,
              //           child: CWTextField(
              //             controller: eventDetailState.textEditingControllers!
              //             [TextFieldItem.destinationCalendar]!,
              //             fontSize: 13,
              //             textAlign: TextAlign.center,
              //             paddingAll: 8,
              //             readOnly: true,
              //             highlight: eventDetailState.highlightItem
              //                 == HighlightItem.destinationCalendar,
              //             onTap: () async {
              //               await eventDetailNotifier.updateHighlightItem(
              //                   HighlightItem.destinationCalendar);
              //               await safeAreaViewNotifier.setSafeAreaAdjustment(5
              //                   + 8);
              //               await safeAreaViewNotifier.setSafeAreaHeight(215);
              //               await safeAreaViewNotifier.updateState();
              //               showBottomArea(repeatPicker);
              //             },
              //           )
              //       )
              //     ])
              // ),

              const SizedBox(height: 8),

              CWElevatedButton(
                  title: '保存する',
                  fixedWidth: 120,
                  fixedHeight: 48,
                  fontSize: 15,
                  backgroundColor: colorConfig.backgroundColor,
                  onPressed: () async {
                    await onCommonPressed();

                    final calendarState = ref.watch(calendarPageNotifierProvider);
                    double prePage = calendarState.calendarSwitchingController
                        .page!;
                    int page = prePage.toInt();
                    if (page.toDouble() == prePage) {
                      page = page == 0 ? 1: 0;
                      await calendarState.calendarSwitchingController
                          .animateToPage(page, duration: const Duration(
                          milliseconds: 300), curve: Curves.easeIn);
                    }
                  }
              )
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