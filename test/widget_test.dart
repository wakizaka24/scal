// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scal/f006_shared_preferences_repository.dart';
import 'package:scal/f008_calendar_config.dart';
import 'package:scal/f016_design_config.dart';

import 'package:scal/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    var brightnessMode = await SharedPreferencesRepository()
        .getStringEnum(SharedPreferenceStringKey.brightnessMode,
        BrightnessMode.values);

    var lightColorConfig = await SharedPreferencesRepository()
        .getStringEnum(SharedPreferenceStringKey.lightColorConfig,
        ColorConfig.values);

    var darkColorConfig = await SharedPreferencesRepository()
        .getStringEnum(SharedPreferenceStringKey.darkColorConfig,
        ColorConfig.values);

    var calendarHolidaySundayConfig = await SharedPreferencesRepository()
        .getString(SharedPreferenceStringKey.calendarHolidaySundayConfig);

    var calendarSwitchMode = await SharedPreferencesRepository()
        .getStringEnum(SharedPreferenceStringKey.calendarSwitchMode,
        CalendarSwitchMode.values);

    var calendar1EditingCalendarId = await SharedPreferencesRepository()
        .getString(SharedPreferenceStringKey.calendar1EditingCalendarId);

    var calendar1NonDisplayCalendarIds = await SharedPreferencesRepository()
        .getString(SharedPreferenceStringKey.calendar1NonDisplayCalendarIds);

    var calendar1NotEditableCalendarIds = await SharedPreferencesRepository()
        .getString(SharedPreferenceStringKey.calendar1NotEditableCalendarIds);

    var calendar1HolidayCalendarIds = await SharedPreferencesRepository()
        .getString(SharedPreferenceStringKey.calendar1HolidayCalendarIds);

    var calendar2EditingCalendarId = await SharedPreferencesRepository()
        .getString(SharedPreferenceStringKey.calendar2EditingCalendarId);

    var calendar2NonDisplayCalendarIds = await SharedPreferencesRepository()
        .getString(SharedPreferenceStringKey.calendar2NonDisplayCalendarIds);

    var calendar2NotEditableCalendarIds = await SharedPreferencesRepository()
        .getString(SharedPreferenceStringKey.calendar2NotEditableCalendarIds);

    var calendar2HolidayCalendarIds = await SharedPreferencesRepository()
        .getString(SharedPreferenceStringKey.calendar2HolidayCalendarIds);

    // Build our app and trigger a frame.
    await tester.pumpWidget(SCalApp(
      brightnessMode: brightnessMode,
      lightColorConfig: lightColorConfig,
      darkColorConfig: darkColorConfig,
      calendarHolidaySundayConfig: calendarHolidaySundayConfig,
      calendarSwitchMode: calendarSwitchMode,
      calendar1EditingCalendarId: calendar1EditingCalendarId,
      calendar1NonDisplayCalendarIds: calendar1NonDisplayCalendarIds,
      calendar1NotEditableCalendarIds: calendar1NotEditableCalendarIds,
      calendar1HolidayCalendarIds: calendar1HolidayCalendarIds,
      calendar2EditingCalendarId: calendar2EditingCalendarId,
      calendar2NonDisplayCalendarIds: calendar2NonDisplayCalendarIds,
      calendar2NotEditableCalendarIds: calendar2NotEditableCalendarIds,
      calendar2HolidayCalendarIds: calendar2HolidayCalendarIds,
    ));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
