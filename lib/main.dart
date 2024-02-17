import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'f001_home_page.dart';
import 'f016_ui_define.dart';

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
        child: MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ja'),
          ],
          theme: baseThemeData,
          // darkTheme: darkThemeData,
          title: 'Alpha',
          home: const HomePage(),
      )
    );
  }
}
