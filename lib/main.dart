import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'f001_home_page.dart';
import 'f006_shared_preferences_repository.dart';
import 'f008_calendar_config.dart';
import 'f017_design_config.dart';

void main() async {
  await runZonedGuarded(() async {
    // 縦向き
    WidgetsFlutterBinding.ensureInitialized();
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);

    // Androidのジェスチャーナビゲーションを透明にする。
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
        overlays: [SystemUiOverlay.top]).then((_) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        // Androidのステータスバーの背景色を透明にする。
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ));
    });

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // FlutterのエラーをFirebase Crashlyticsに送る
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (errorDetails) {
      // 致命的なエラーを送る
      // FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      // 致命的ではないエラーも送る
      FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
    };

//   // ライセンス表記を追加する
//   LicenseRegistry.addLicense(() {
//     return Stream<LicenseEntry>.fromIterable(<LicenseEntry>[
//       const LicenseEntryWithLineBreaks(<String>[''],
// '''
// ''')]);
//   });

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

    var calendarDisplayMode = await SharedPreferencesRepository()
        .getStringEnum(SharedPreferenceStringKey.calendarDisplayMode,
        CalendarDisplayMode.values);

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

    runApp(SCalApp(
      brightnessMode: brightnessMode,
      lightColorConfig: lightColorConfig,
      darkColorConfig: darkColorConfig,
      calendarHolidaySundayConfig: calendarHolidaySundayConfig,
      calendarDisplayMode: calendarDisplayMode,
      calendar1EditingCalendarId: calendar1EditingCalendarId,
      calendar1NonDisplayCalendarIds: calendar1NonDisplayCalendarIds,
      calendar1NotEditableCalendarIds: calendar1NotEditableCalendarIds,
      calendar1HolidayCalendarIds: calendar1HolidayCalendarIds,
      calendar2EditingCalendarId: calendar2EditingCalendarId,
      calendar2NonDisplayCalendarIds: calendar2NonDisplayCalendarIds,
      calendar2NotEditableCalendarIds: calendar2NotEditableCalendarIds,
      calendar2HolidayCalendarIds: calendar2HolidayCalendarIds,
    ));
  }, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
    // FirebaseCrashlytics.instance.crash();
  });
}

var appInit = false;

class SCalApp extends StatelessWidget {
  final BrightnessMode? brightnessMode;
  final ColorConfig? lightColorConfig;
  final ColorConfig? darkColorConfig;
  final String? calendarHolidaySundayConfig;
  final CalendarDisplayMode? calendarDisplayMode;
  final String? calendar1EditingCalendarId;
  final String? calendar1NonDisplayCalendarIds;
  final String? calendar1NotEditableCalendarIds;
  final String? calendar1HolidayCalendarIds;
  final String? calendar2EditingCalendarId;
  final String? calendar2NonDisplayCalendarIds;
  final String? calendar2NotEditableCalendarIds;
  final String? calendar2HolidayCalendarIds;

  const SCalApp({
    super.key,
    required this.brightnessMode,
    required this.lightColorConfig,
    required this.darkColorConfig,
    required this.calendarHolidaySundayConfig,
    required this.calendarDisplayMode,
    required this.calendar1EditingCalendarId,
    required this.calendar1NonDisplayCalendarIds,
    required this.calendar1NotEditableCalendarIds,
    required this.calendar1HolidayCalendarIds,
    required this.calendar2EditingCalendarId,
    required this.calendar2NonDisplayCalendarIds,
    required this.calendar2NotEditableCalendarIds,
    required this.calendar2HolidayCalendarIds,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
        child: Consumer(
            builder: ((context, ref, child) {
              final Brightness brightness = MediaQuery.platformBrightnessOf(
                  context);
              var designConfigState = ref.watch(designConfigNotifierProvider);
              final designConfigNotifier = ref.watch(
                  designConfigNotifierProvider.notifier);
              // var calendarConfigState = ref.watch(
              //     calendarConfigNotifierProvider);
              var calendarConfigNotifier = ref.watch(
                  calendarConfigNotifierProvider.notifier);
              var colorConfig = designConfigState.colorConfig;
              if (!appInit) {
                appInit = true;
                var editingBrightnessMode = brightnessMode
                    ?? BrightnessMode.values.first;
                var editingLightColorConfig = lightColorConfig
                    ?? ColorConfig.values.where((config) {
                  return config.brightness == Brightness.light;
                }).toList().first;
                var editingDarkColorConfig = darkColorConfig
                    ?? ColorConfig.values.where((config) {
                  return config.brightness == Brightness.dark;
                }).toList().first;
                colorConfig = designConfigNotifier.initState(
                    editingBrightnessMode, brightness, editingLightColorConfig,
                    editingDarkColorConfig);
                calendarConfigNotifier.initState(
                    calendarHolidaySundayConfig, calendarDisplayMode,
                    calendar1EditingCalendarId, calendar1NonDisplayCalendarIds,
                    calendar1NotEditableCalendarIds,
                    calendar1HolidayCalendarIds, calendar2EditingCalendarId,
                    calendar2NonDisplayCalendarIds,
                    calendar2NotEditableCalendarIds,
                    calendar2HolidayCalendarIds);
              }

              return MaterialApp(
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en'),
                  Locale('ja'),
                ],
                theme: ThemeData(
                    useMaterial3: colorConfig!.useMaterial3,
                    colorScheme: ColorScheme.fromSwatch(
                        brightness: colorConfig.brightness,
                        primarySwatch: colorConfig.primarySwatch,
                        accentColor: colorConfig.accentColor,
                        cardColor: colorConfig.cardColor,
                        backgroundColor: colorConfig.backgroundColor
                    )
                ),
                home: const HomePage(),
              );
            })
        )
    );
  }
}
