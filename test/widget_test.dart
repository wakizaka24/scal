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
import 'package:scal/f017_design_config.dart';

import 'package:scal/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await initCalendarConfig();

    final (
      brightnessMode, lightColorConfig, darkColorConfig, calendarHolidayList,
      calendarHiddenMode, calendarHiddenCalendarIds, calendarBothCalendarIds,
      calendarInvisibleCalendarIds, calendarNotEditableCalendarIds,
      calendarUseCalendarId, calendarHolidayCalendarIds
    ) = await getCalendarConfigs();

    // Build our app and trigger a frame.
    await tester.pumpWidget(SCalApp(
      brightnessMode: brightnessMode,
      lightColorConfig: lightColorConfig,
      darkColorConfig: darkColorConfig,
      calendarHolidayList: calendarHolidayList,
      calendarHiddenMode: calendarHiddenMode,
      calendarHiddenCalendarIds: calendarHiddenCalendarIds,
      calendarBothCalendarIds: calendarBothCalendarIds,
      calendarInvisibleCalendarIds: calendarInvisibleCalendarIds,
      calendarNotEditableCalendarIds: calendarNotEditableCalendarIds,
      calendarUseCalendarId: calendarUseCalendarId,
      calendarHolidayCalendarIds: calendarHolidayCalendarIds,
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
