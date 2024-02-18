import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'f001_home_page.dart';
import 'f016_color_config.dart';

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

class SCalApp extends StatelessWidget {
  const SCalApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
        child: Consumer(
            builder: ((context, ref, child) {
              final colorConfig = ref.watch(designConfigNotifierProvider)
                  .colorConfig;
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
                    useMaterial3: colorConfig.useMaterial3,
                    colorScheme: ColorScheme.fromSwatch(
                      brightness: colorConfig.brightness,
                      primarySwatch: colorConfig.primarySwatch,
                      accentColor: colorConfig.accentColor,
                      cardColor: colorConfig.cardColor,
                      backgroundColor: colorConfig.backgroundColor
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
