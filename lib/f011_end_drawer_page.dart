import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scal/f017_design_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'f013_end_drawer_view_model.dart';
import 'f025_common_widgets.dart';

enum EndDrawerMenuType {
  softwareLicense(title: 'ソフトウェアライセンス');
  final String title;
  const EndDrawerMenuType({required this.title});
}

class EndDrawerPage extends HookConsumerWidget {
  final double unsafeAreaTopHeight;

  const EndDrawerPage({super.key,
    required this.unsafeAreaTopHeight
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final endDrawerState = ref.watch(endDrawerPageNotifierProvider);
    final endDrawerNotifier = ref.watch(endDrawerPageNotifierProvider.notifier);
    final normalTextColor = ref.read(designConfigNotifierProvider)
        .colorConfig!.normalTextColor;

    useEffect(() {
      endDrawerNotifier.initState();
      return () {
      };
    }, const []);

    softwareLicenseOnPress() async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      if (!context.mounted) return;
      await Navigator.push(context, MaterialPageRoute(
          builder: (context) => LicensePage(
              applicationName: packageInfo.appName,
              applicationVersion: packageInfo.version
          )
      )
      );

      await Future.delayed(const Duration(milliseconds: 100));

      // ステータスバーの設定
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        // iOSの文字を白にする。
        statusBarBrightness: Brightness.dark,
        // Androidの文字を白にする。
        statusBarIconBrightness: Brightness.light,
        // Androidの背景色を透明にする。
        statusBarColor: Colors.transparent,
      ));
    }

    ListView menuList = ListView(
      // physics: const NeverScrollableScrollPhysics(),
      children: [
        for (int i=0; i < EndDrawerMenuType.values.length; i++) ... {
          Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: CWTextButton(
              title: EndDrawerMenuType.values[i].title,
              onPressed: () async {
                switch (EndDrawerMenuType.values[i]) {
                  case EndDrawerMenuType.softwareLicense:
                    await softwareLicenseOnPress();
                }
              }
            )
          )
        }
      ],
    );

    const double buttonWidth = 39;
    var drawer = Drawer(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: CWIconButton(
                    assetName: 'images/icon_close@3x.png',
                    width: buttonWidth,
                    height: buttonWidth,
                    radius: buttonWidth / 2,
                    foregroundColor: normalTextColor,
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                  )
              ),

              Expanded(
                  child: menuList
              ),
            ]
        )
    );

    return Column(children: [
      SizedBox(height: unsafeAreaTopHeight),
      Expanded(child: drawer)
    ]);
  }
}