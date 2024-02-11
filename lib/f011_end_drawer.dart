import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scal/f016_ui_define.dart';

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
  const EndDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final theme = Theme.of(context);

    ListView menuList = ListView(
      // physics: const NeverScrollableScrollPhysics(),
      children: [
        for (int i=0; i < EndDrawerMenuType.values.length; i++) ... {
        }
      ],
    );

    return SafeArea(
        bottom: false,
        child: ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16)),
            child: Drawer(
                // backgroundColor: theme.colorScheme.background,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          child: SizedBox(width: 29, height: 29,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  textStyle: const TextStyle(fontSize: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
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
            )
        )
    );
  }
}