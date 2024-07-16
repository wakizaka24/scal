import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scal/f016_design.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
          TextButton(
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
            },
            style: TextButton.styleFrom(
              foregroundColor: normalTextColor,
              textStyle: const TextStyle(fontSize: 15),
              padding: const EdgeInsets.all(0),
            ),
            child: const Text('ソフトウェアライセンス'),
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
                  child: SizedBox(width: buttonWidth, height: buttonWidth,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: normalTextColor,
                          textStyle: const TextStyle(fontSize: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                buttonWidth / 2),
                          ),
                          padding: const EdgeInsets.all(0),
                        ),
                        child: Icon(Icons.check,
                            color: normalTextColor),
                      )
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