import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scal/f016_design.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'f025_common_widgets.dart';

enum EndDrawerMenuType {
  softwareLicense(title: 'ソフトウェアライセンス');

  const EndDrawerMenuType({required this.title});
  final String title;
}

class EndDrawer extends HookConsumerWidget {
  final double unsafeAreaTopHeight;

  const EndDrawer({super.key,
    required this.unsafeAreaTopHeight
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final normalTextColor = ref.read(designConfigNotifierProvider)
        .colorConfig!.normalTextColor;

    ListView menuList = ListView(
      // physics: const NeverScrollableScrollPhysics(),
      children: [
        for (int i=0; i < EndDrawerMenuType.values.length; i++) ... {
          CWTextButton(
            title: 'ソフトウェアライセンス',
            onPressed: () async {
              PackageInfo packageInfo = await PackageInfo.fromPlatform();
              if (!context.mounted) return;
              await Navigator.push(context, MaterialPageRoute(
                  builder: (context) => LicensePage(
                    applicationName: packageInfo.appName,
                    applicationVersion: packageInfo.version
                  )
                )
              );

              await Future.delayed(const Duration(milliseconds: 500));

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
                    assetName: 'images/icon_closing.png',
                    assetIconSize: 15,
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