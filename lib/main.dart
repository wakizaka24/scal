import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'f001_home_page.dart';
import 'f006_shared_preferences_repository.dart';
import 'f016_design_config.dart';

void main() async {
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

//   // ライセンス表記を追加する
//   LicenseRegistry.addLicense(() {
//     return Stream<LicenseEntry>.fromIterable(<LicenseEntry>[
//       const LicenseEntryWithLineBreaks(<String>[''],
// '''
// ''')]);
//   });

  var brightnessMode = await SharedPreferencesRepository()
      .getStringEnum(SharedPreferenceKey.brightnessMode,
      BrightnessMode.values);
  brightnessMode ??= BrightnessMode.values.first;

  var lightColorConfig = await SharedPreferencesRepository()
      .getStringEnum(SharedPreferenceKey.lightColorConfig,
      ColorConfig.values);
  lightColorConfig ??= ColorConfig.values.where((config) {
    return config.brightness == Brightness.light;
  }).toList().first;

  var darkColorConfig = await SharedPreferencesRepository()
      .getStringEnum(SharedPreferenceKey.darkColorConfig,
      ColorConfig.values);
  darkColorConfig ??= ColorConfig.values.where((config) {
    return config.brightness == Brightness.dark;
  }).toList().first;

  runApp(SCalApp(brightnessMode: brightnessMode,
      lightColorConfig: lightColorConfig,
      darkColorConfig: darkColorConfig));
}

// var colorConfigInitialized = false;

class SCalApp extends StatelessWidget {
  final BrightnessMode brightnessMode;
  final ColorConfig lightColorConfig;
  final ColorConfig darkColorConfig;

  const SCalApp({
    super.key,
    required this.brightnessMode,
    required this.lightColorConfig,
    required this.darkColorConfig
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
              var colorConfig = designConfigState.colorConfig;
              if (colorConfig == null) {
                designConfigNotifier.initState(brightnessMode, brightness,
                    lightColorConfig, darkColorConfig);

                if (brightness == Brightness.light
                    && brightnessMode == BrightnessMode.lightAndDark
                    || brightnessMode == BrightnessMode.light) {
                  colorConfig ??= lightColorConfig;
                }

                if (brightness == Brightness.dark
                    && brightnessMode == BrightnessMode.lightAndDark
                    || brightnessMode == BrightnessMode.dark) {
                  colorConfig ??= darkColorConfig;
                }
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
