import 'package:flutter/foundation.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class CalendarRepository {
  static final CalendarRepository _instance = CalendarRepository._internal();
  final DeviceCalendarPlugin _plugin = DeviceCalendarPlugin();
  Location _location = local;

  factory CalendarRepository() {
    return _instance;
  }

  CalendarRepository._internal() {
    setNativeLocation();
  }

  Future setNativeLocation() async {
    try {
      String timezone = await FlutterNativeTimezone.getLocalTimezone();
      _location = getLocation(timezone);
      setLocalLocation(_location);
    } catch (e) {
      debugPrint('ネイティブのロケーションを取得できませんでした');
    }
  }

  Future<bool> hasPermissions() async {
    var permissions = await _plugin.hasPermissions();

    // カレンダーアクセスの未リクエスト
    if (permissions.isSuccess && !permissions.data!) {
      // カレンダーアクセスをリクエスト
      permissions = await _plugin.requestPermissions();
      // アクセス権を得られなかった
      if (!permissions.isSuccess || !permissions.data!) {
      }
    }

    return permissions.isSuccess;
  }

  Future<List<Calendar>> getCalendars() async {
    var result = await _plugin.retrieveCalendars();
    List<Calendar> calendars = result.data ?? [];

    // for (int i = 0; i < calendars.length; i++) {
    //   if (i == 0) {
    //     debugPrint('カレンダー一覧');
    //   }
    //   var calendar = calendars[i];
    //   var id = calendar.id;
    //   var name = calendar.name;
    //   var isReadOnly = calendar.isReadOnly;
    //   var isDefault = calendar.isDefault;
    //   var color = calendar.color;
    //   var accountName = calendar.accountName;
    //   var accountType = calendar.accountType;
    //   debugPrint('id=$id name=$name isReadOnly=$isReadOnly '
    //       'isDefault=$isDefault color=$color accountName=$accountName '
    //       'accountType=$accountType');
    // }

    return calendars;
  }

  Future<List<Event>> getEvents(String calendarId,
      DateTime startDate, DateTime endDate) async {
    var params = RetrieveEventsParams(startDate: startDate, endDate: endDate);
    var result = await _plugin.retrieveEvents(calendarId, params);
    List<Event> events = [...result.data ?? []];

    for (int i = 0; i < events.length; i++) {
      var event = events[i];

      // ロケーションを日時に適用する。
      if (event.start != null) {
        event.start = convertTZDateTime(event.start!);
      }
      if (events[i].end != null) {
        event.end = convertTZDateTime(event.end!);
      }

      // if (i == 0) {
      //   debugPrint('イベント一覧');
      // }
      //
      // var eventId = event.eventId;
      // var calendarId = event.calendarId;
      // var title = event.title;
      // var description = event.description;
      // var start = event.start;
      // var end = event.end;
      // var allDay = event.allDay;
      // var location = event.location;
      // var url = event.url;
      // debugPrint('eventId=$eventId calendarId=$calendarId title=$title '
      //     'description=$description start=$start end=$end '
      //     'allDay=$allDay location=$location url=$url');
    }

    return events;
  }

  // Future<Event?> getEvent(String calendarId, String eventId) async {
  //   var params = RetrieveEventsParams(eventIds: [eventId]);
  //   var result = await _plugin.retrieveEvents(calendarId, params);
  //   List<Event> events = [...result.data ?? []];
  //   return events.firstOrNull;
  // }

  TZDateTime convertTZDateTime(DateTime date) {
    return TZDateTime.from(date, _location);
  }

  Future<bool> createOrUpdateEvent(Event event) async {
    var result = await _plugin.createOrUpdateEvent(event);
    return result?.isSuccess ?? false;
  }

  Future<bool> deleteEvent(String calendarId, String eventId) async {
    var result =  await _plugin.deleteEvent(calendarId, eventId);
    return result.isSuccess;
  }
}
