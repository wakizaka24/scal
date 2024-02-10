import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'f001_home_page.dart';

void main() {
  // 横向き無効
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    // 縦向き
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const SCalApp());
  });
}

class SCalApp extends StatelessWidget {
  const SCalApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var baseThemeData = ThemeData(
      useMaterial3: false,
      primarySwatch: Colors.grey,
        colorScheme: ColorScheme.fromSwatch(
          // brightness: Brightness.dark,
          primarySwatch: Colors.purple,
          accentColor: Colors.blue,
          cardColor: Colors.white,
          backgroundColor: Colors.white
        )
    );

    // var darkThemeData = ThemeData(
    //     useMaterial3: false,
    //     primarySwatch: Colors.grey,
    //     colorScheme: ColorScheme.fromSwatch(
    //         brightness: Brightness.dark,
    //         primarySwatch: Colors.purple,
    //         accentColor: Colors.blue,
    //         cardColor: Colors.white,
    //         backgroundColor: Colors.white
    //     )
    // );

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
          title: 'SCal',
          home: const HomePage(),
      )
    );
  }
}
