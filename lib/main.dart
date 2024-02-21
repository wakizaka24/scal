import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'f001_home_page.dart';
import 'f016_design.dart';

void main() {
  // 縦向き
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp
  ]);

  // ステータスバーのフォントカラーを白にする。
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark, // iOS
      statusBarIconBrightness: Brightness.dark, // Android
    )
  );

  // // MediaQuery.removePadding removeTopと
  // // 併用でセーフエリアのボタンを有効にする。
  // SystemChrome.setEnabledSystemUIMode(
  //     SystemUiMode.immersiveSticky);

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
                    )
                ),
                title: 'Alpha',
                home: const HomePage(),
              );
            })
        )
    );
  }
}
