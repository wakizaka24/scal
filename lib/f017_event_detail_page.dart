import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scal/f013_ui_utils.dart';

import 'f001_home_page.dart';
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
                        safeAreaViewNotifier.setSafeAreaAdjustment(8 + 6);
                      },
                      onChanged: (text) {
                        debugPrint('Textの変更検知={$text}');
                      }
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
                        onTap: () {
                          eventDetailNotifier.updateHighlightItem(
                              HighlightItem.place);
                          safeAreaViewNotifier.setSafeAreaAdjustment(8 + 6);
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
                  verticalPaddingWidth: 2,
                  expanded: false,
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
              ),

              CWLeftTitle(
                  title: eventDetailState.allDay! ? '日付' : '開始',
                  highlight: eventDetailState.highlightItem
                      == HighlightItem.startDate
                    || eventDetailState.highlightItem
                          == HighlightItem.startHour,
                  expanded: false,
                  child: Row(children: [
                    SizedBox(
                        width: 120, height: 36,
                        child: CWTextField(
                          controller: eventDetailState.textEditingControllers!
                          [TextFieldItem.startDay]!,
                          fontSize: 15,
                          textAlign: TextAlign.center,
                          paddingAll: 6,
                          readOnly: true,
                          highlight: eventDetailState.highlightItem
                              == HighlightItem.startDate,
                          onTap: () async {
                            await eventDetailNotifier.updateHighlightItem(
                                HighlightItem.startDate);
                            await safeAreaViewNotifier.setSafeAreaAdjustment(5
                              + 8);
                            await safeAreaViewNotifier.setSafeAreaHeight(215);
                            await safeAreaViewNotifier.updateState();
                            await showBottomArea(
                                CupertinoDatePicker(
                                  initialDateTime: eventDetailState.startDate,
                                  mode: CupertinoDatePickerMode.date,
                                  minimumYear: minimumYear,
                                  maximumYear: maximumYear,
                                  onDateTimeChanged: (DateTime newDate) {
                                    eventDetailNotifier.setTextFieldController(
                                        TextFieldItem.startDay,
                                        value: CalendarUtils()
                                        .copyDate(eventDetailState.startDate!,
                                        newDate));
                                  },
                                )
                            );
                            await eventDetailNotifier.updateHighlightItem(
                                HighlightItem.none);
                          },
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
                              == HighlightItem.startHour,
                          onTap: () async {
                            await eventDetailNotifier.updateHighlightItem(
                                HighlightItem.startHour);
                            await safeAreaViewNotifier.setSafeAreaAdjustment(5
                              + 8);
                            await safeAreaViewNotifier.setSafeAreaHeight(216);
                            await safeAreaViewNotifier.updateState();
                            await showBottomArea(CupertinoDatePicker(
                              initialDateTime: eventDetailState.startDate,
                              mode: CupertinoDatePickerMode.time,
                              use24hFormat: true,
                              onDateTimeChanged: (DateTime newDate) {
                                eventDetailNotifier.setTextFieldController(
                                    TextFieldItem.startTime,
                                    value: CalendarUtils()
                                        .copyTime(eventDetailState.startDate!,
                                        newDate));
                              },
                            ));
                            await eventDetailNotifier.updateHighlightItem(
                                HighlightItem.none);
                          }
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
                            == HighlightItem.endHour,
                    expanded: false,
                    child: Row(children: [
                      SizedBox(
                          width: 120, height: 36,
                          child: CWTextField(
                            controller: eventDetailState.textEditingControllers!
                            [TextFieldItem.endDay]!,
                            fontSize: 15,
                            textAlign: TextAlign.center,
                            paddingAll: 6,
                            readOnly: true,
                            highlight: eventDetailState.highlightItem
                                == HighlightItem.endDate,
                            onTap: () async {
                              await eventDetailNotifier.updateHighlightItem(
                                  HighlightItem.endDate);
                              await safeAreaViewNotifier.setSafeAreaAdjustment(5
                                  + 8);
                              await safeAreaViewNotifier.setSafeAreaHeight(215);
                              await safeAreaViewNotifier.updateState();
                              await showBottomArea(
                                  CupertinoDatePicker(
                                    initialDateTime: eventDetailState.startDate,
                                    mode: CupertinoDatePickerMode.date,
                                    onDateTimeChanged: (DateTime newDate) {
                                      eventDetailNotifier
                                          .setTextFieldController(
                                          TextFieldItem.endDay,
                                          value: CalendarUtils()
                                              .copyDate(
                                              eventDetailState.endDate!,
                                              newDate));
                                    },
                                  )
                              );
                              await eventDetailNotifier.updateHighlightItem(
                                  HighlightItem.none);
                            },
                          )
                      ),

                      if (!eventDetailState.allDay!)
                        SizedBox(
                            width: 60, height: 36,
                            child: CWTextField(
                                controller: eventDetailState.textEditingControllers!
                                [TextFieldItem.endTime]!,
                                fontSize: 15,
                                textAlign: TextAlign.center,
                                paddingAll: 6,
                                readOnly: true,
                                highlight: eventDetailState.highlightItem
                                    == HighlightItem.endHour,
                                onTap: () async {
                                  await eventDetailNotifier.updateHighlightItem(
                                      HighlightItem.endHour);
                                  await safeAreaViewNotifier
                                      .setSafeAreaAdjustment(5 + 8);
                                  await safeAreaViewNotifier.setSafeAreaHeight(
                                      216);
                                  await safeAreaViewNotifier.updateState();
                                  await showBottomArea(CupertinoDatePicker(
                                    initialDateTime: eventDetailState.endDate,
                                    mode: CupertinoDatePickerMode.time,
                                    minimumYear: minimumYear,
                                    maximumYear: maximumYear,
                                    use24hFormat: true,
                                    onDateTimeChanged: (DateTime newDate) {
                                      eventDetailNotifier
                                          .setTextFieldController(
                                          TextFieldItem.endTime,
                                          value: CalendarUtils()
                                              .copyTime(eventDetailState
                                              .endDate!, newDate));
                                    },
                                  ));
                                  await eventDetailNotifier.updateHighlightItem(
                                      HighlightItem.none);
                                }
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
                          fontSize: 13,
                          textAlign: TextAlign.center,
                          paddingAll: 8,
                          readOnly: true,
                          highlight: eventDetailState.highlightItem
                              == HighlightItem.repeat,
                          onTap: () async {
                            await eventDetailNotifier.updateHighlightItem(
                                HighlightItem.repeat);
                            await safeAreaViewNotifier.setSafeAreaAdjustment(5
                                + 8);
                            await safeAreaViewNotifier.setSafeAreaHeight(215);
                            await safeAreaViewNotifier.updateState();
                            await showBottomArea(
                                CupertinoPicker(
                                    itemExtent: 32,
                                    scrollController:
                                    FixedExtentScrollController(
                                      initialItem: RepeatingPattern
                                          .values.indexOf(eventDetailState
                                          .repeatingPattern!),
                                    ),
                                    onSelectedItemChanged: (int index) {
                                      eventDetailNotifier
                                          .setTextFieldController(
                                          TextFieldItem.repeat,
                                          value: RepeatingPattern
                                              .values[index]);
                                    },
                                    children:
                                    List<Widget>.generate(RepeatingPattern
                                        .values.length, (int index) {
                                      return Center(child: Text(
                                          RepeatingPattern.values[index].name));
                                    })
                                )
                            );
                            await eventDetailNotifier.updateHighlightItem(
                                HighlightItem.none);
                          },
                        )
                    )
                  ])
              ),
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