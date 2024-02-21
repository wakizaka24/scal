import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scal/f016_design.dart';

enum EndDrawerMenuType {
  test1(title: 'テスト1'),
  test2(title: 'テスト2'),
  test3(title: 'テスト3'),
  test4(title: 'テスト4'),
  test5(title: 'テスト5');

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
    final theme = Theme.of(context);
    final normalTextColor = ref.read(designConfigNotifierProvider)
        .colorConfig!.normalTextColor;

    ListView menuList = ListView(
      // physics: const NeverScrollableScrollPhysics(),
      children: [
        for (int i=0; i < EndDrawerMenuType.values.length; i++) ... {
        }
      ],
    );

    const double buttonWidth = 39;
    var drawer = Drawer(
        backgroundColor: theme.colorScheme.background,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
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