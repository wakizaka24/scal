import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
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

    if (!kIsWeb) {
      // FlutterのエラーをFirebase Crashlyticsに送る
      WidgetsFlutterBinding.ensureInitialized();
      FlutterError.onError = (errorDetails) {
        // 致命的なエラーを送る
        // FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
        // 致命的ではないエラーも送る
        FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      };
    }

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
        .getStringEnum(SharedPreferenceStringKey.lightColorMode,
        ColorConfig.values);

    var darkColorConfig = await SharedPreferencesRepository()
        .getStringEnum(SharedPreferenceStringKey.darkColorMode,
        ColorConfig.values);

    var calendarHolidayList = await SharedPreferencesRepository()
        .getString(SharedPreferenceStringKey.calendarHolidayList);

    var calendarHiddenCalendarIds = await SharedPreferencesRepository()
        .getString(SharedPreferenceStringKey.calendarHiddenCalendarIds);

    var calendarBothCalendarIds = await SharedPreferencesRepository()
        .getString(SharedPreferenceStringKey.calendarBothCalendarIds);

    var calendarInvisibleCalendarIds = await SharedPreferencesRepository()
        .getString(SharedPreferenceStringKey.calendarInvisibleCalendarIds);

    var calendarNotEditableCalendarIds = await SharedPreferencesRepository()
        .getString(SharedPreferenceStringKey.calendarNotEditableCalendarIds);

    var calendarHolidayCalendarIds = await SharedPreferencesRepository()
        .getString(SharedPreferenceStringKey.calendarHolidayCalendarIds);

    runApp(SCalApp(
      brightnessMode: brightnessMode,
      lightColorConfig: lightColorConfig,
      darkColorConfig: darkColorConfig,
      calendarHolidayList: calendarHolidayList,
      calendarHiddenCalendarIds: calendarHiddenCalendarIds,
      calendarBothCalendarIds: calendarBothCalendarIds,
      calendarInvisibleCalendarIds: calendarInvisibleCalendarIds,
      calendarNotEditableCalendarIds: calendarNotEditableCalendarIds,
      calendarHolidayCalendarIds: calendarHolidayCalendarIds,
    ));
  }, (error, stackTrace) {
    var log = 'error={$error} stackTrace={$stackTrace}';
    debugPrint(log);
    if (!kIsWeb) {
      FirebaseCrashlytics.instance.log(log);
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    }
  });
}

var appInit = false;

class SCalApp extends StatelessWidget {
  final BrightnessMode? brightnessMode;
  final ColorConfig? lightColorConfig;
  final ColorConfig? darkColorConfig;
  final String? calendarHolidayList;
  final String? calendarHiddenCalendarIds;
  final String? calendarBothCalendarIds;
  final String? calendarInvisibleCalendarIds;
  final String? calendarNotEditableCalendarIds;
  final String? calendarHolidayCalendarIds;

  const SCalApp({
    super.key,
    required this.brightnessMode,
    required this.lightColorConfig,
    required this.darkColorConfig,
    required this.calendarHolidayList,
    required this.calendarHiddenCalendarIds,
    required this.calendarBothCalendarIds,
    required this.calendarInvisibleCalendarIds,
    required this.calendarNotEditableCalendarIds,
    required this.calendarHolidayCalendarIds
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
                    calendarHolidayList, calendarHiddenCalendarIds,
                    calendarBothCalendarIds, calendarInvisibleCalendarIds,
                    calendarNotEditableCalendarIds, calendarHolidayCalendarIds);
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
