import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class CalendarPageState {
  // UI
  bool dayPartActive = true;
  int? eventListIndex;
  int? dayPartIndex;

  // Data
  late DateTime now;
  String? appBarTitle;
  List<String> weekTitleList = [];
  List<List<DayDisplay>> dayLists = [];
  String? eventListTitle;
  List<EventDisplay> eventLists = [];

  static CalendarPageState copy(CalendarPageState state) {
    var nState = CalendarPageState();
    nState.dayPartActive = state.dayPartActive; // 日部分の活性
    nState.dayPartIndex = state.dayPartIndex; // 日選択
    nState.eventListIndex = state.eventListIndex; // イベント選択
    return nState;
  }
}

class DayDisplay {
  DateTime id;
  String title;
  List<String> eventList;
  bool inactive; // 非活性(文字を薄くする)

  DayDisplay({
    required this.id,
    required this.title,
    required this.eventList,
    required this.inactive,
  });
}

class EventDisplay {
  String id;
  bool editing;
  String head;
  String title;

  EventDisplay({
    required this.id,
    required this.editing,
    required this.head,
    required this.title,
  });
}

class CalendarPageNotifier extends StateNotifier<CalendarPageState> {
  final Ref ref;

  CalendarPageNotifier(this.ref, CalendarPageState state)
      : super(state);

  initState() async {
    state.now = DateTime.now();
    state.appBarTitle = DateFormat.yMMM('ja')
        .format(DateTime.now()).toString();
    state.weekTitleList = ['日','月','火','水','木','金','土'];
    state.dayLists = createDayLists(state.now);
    state = CalendarPageState.copy(state);
  }

  List<List<DayDisplay>> createDayLists(DateTime now) {
    DateTime prevMonth = DateTime(now.year, now.month - 1, 1);

    // 月部分の先頭の日付
    int subDay = 0;
    for (int weekday = prevMonth.weekday; weekday % 7 != 0; weekday--) {
      subDay--;
    }
    DateTime currentDay = DateTime(prevMonth.year, prevMonth.month,
        prevMonth.day + subDay);

    // 基準月
    List<DateTime> months = [
      // 3ヶ月分
      for (int i=0; i<3; i++) ... {
        DateTime(prevMonth.year, prevMonth.month + i, 1)
      }
    ];

    List<List<DayDisplay>> list = [];
    for (int i=0; i<3; i++) {
      if (i > 0) {
        // 月区切りで1週差し戻す
        currentDay = DateTime(currentDay.year, currentDay.month,
            currentDay.day - 7);
      }

      list.add([
        // 翌月かつ土曜日まで
        for (int j=0; months[i].month == currentDay.month
            || j == 0 || j % 7 != 0; j++, currentDay=DateTime(currentDay.year,
            currentDay.month, currentDay.day + 1)) ... {
          DayDisplay(id: currentDay, title: currentDay.day.toString(),
              eventList: [], inactive: months[i].month != currentDay.month)
        }
      ]);
    }

    return list;
  }

  selectDayPart(int index) {
    state.dayPartActive = true;
    state.dayPartIndex = index;
    state.eventListIndex = null;
    state = CalendarPageState.copy(state);
  }

  selectEventListPart(int index) {
    state.dayPartActive = false;
    state.eventListIndex = index;
    state = CalendarPageState.copy(state);
  }
}

final calendarPageNotifierProvider =
StateNotifierProvider.autoDispose<CalendarPageNotifier,
    CalendarPageState>((ref) {
  return CalendarPageNotifier(ref, CalendarPageState());
});