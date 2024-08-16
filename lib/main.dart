import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'f001_home_page.dart';
import 'f016_design_config.dart';

void main() {
  // 縦向き
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp
  ]);

  // ステータスバーの設定
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    // iOSの文字を白にする。
    statusBarBrightness: Brightness.dark,
    // Androidの文字を白にする。
    statusBarIconBrightness: Brightness.light,
    // Androidの背景色を透明にする。
    statusBarColor: Colors.transparent,
  ));

  // // Androidのジェスチャーナビゲーションを透明にする。
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
  //     overlays: [SystemUiOverlay.top]).then((_) {
  //   SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
  //     systemNavigationBarColor: Colors.transparent,
  //     systemNavigationBarDividerColor: Colors.transparent,
  //   ));
  // });

  // // MediaQuery.removePadding removeTopと
  // // 併用でセーフエリアのボタンを有効にする。
  // SystemChrome.setEnabledSystemUIMode(
  //     SystemUiMode.immersiveSticky);

//   // ライセンス表記を追加する
//   LicenseRegistry.addLicense(() {
//     return Stream<LicenseEntry>.fromIterable(<LicenseEntry>[
//       const LicenseEntryWithLineBreaks(<String>[''],
// '''
// ''')]);
//   });

  runApp(const SCalApp());
}

var colorConfigInitialized = false;

class SCalApp extends StatelessWidget {
  const SCalApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
        child: Consumer(
            builder: ((context, ref, child) {
              final colorConfigState = ref.watch(designConfigNotifierProvider);
              final colorConfigNotifier = ref.watch(designConfigNotifierProvider
                  .notifier);

              if (!colorConfigInitialized) {
                colorConfigInitialized = true;
                final Brightness brightness = MediaQuery.platformBrightnessOf(
                    context);
                colorConfigNotifier.applyColorConfig(brightness);
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
                    useMaterial3: colorConfigState.colorConfig!.useMaterial3,
                    colorScheme: ColorScheme.fromSwatch(
                      brightness: colorConfigState.colorConfig!.brightness,
                      primarySwatch: colorConfigState.colorConfig!
                          .primarySwatch,
                      accentColor: colorConfigState.colorConfig!.accentColor,
                      cardColor: colorConfigState.colorConfig!.cardColor,
                      backgroundColor: colorConfigState.colorConfig!
                          .backgroundColor
                    ),
                    // appBarTheme: const AppBarTheme(
                    //   systemOverlayStyle: SystemUiOverlayStyle(
                    //     // iOSの文字を白にする。
                    //     statusBarBrightness: Brightness.light,
                    //     // Androidの文字を白にする。
                    //     statusBarIconBrightness: Brightness.light,
                    //     // Androidの背景色を透明にする。
                    //     statusBarColor: Colors.transparent,
                    //   )
                    // )
                ),
                home: const HomePage(),
              );
            })
        )
    );
  }
}
