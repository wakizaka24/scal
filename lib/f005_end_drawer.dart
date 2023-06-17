import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
    final theme = Theme.of(context);
    final highlightedIndex = useState(-1);

    ListView menuList = ListView(
      // physics: const NeverScrollableScrollPhysics(),
      children: [
        for (int i=0; i < EndDrawerMenuType.values.length; i++) ... {
          HighlightAbleButton(
            index: i,
            isHighlighted: highlightedIndex.value == i,
            onPointerDown: (int i) async {
              highlightedIndex.value = i;
            },
            onPointerUp: (int i) async {
              highlightedIndex.value = -1;
              Navigator.pop(context);

              final snackBar = SnackBar(
                content: const Text('クリックしました!'),
                action: SnackBarAction(
                  label: '取消',
                  onPressed: () {
                  },
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
            onPointerCancel: (int i) async {
              highlightedIndex.value = -1;
            },
            title: EndDrawerMenuType.values[i].title,
            fontSize: 18,
          )
        }
      ],
    );

    return SafeArea(
        bottom: false,
        child: ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16)),
            child: Drawer(
                backgroundColor: theme.colorScheme.background,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          child: IconButton(icon: const Icon(Icons.add),
                              onPressed: () {})
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

class HighlightAbleButton extends HookConsumerWidget {
  const HighlightAbleButton({super.key,
    required this.index,
    required this.isHighlighted,
    required this.onPointerDown,
    required this.onPointerUp,
    required this.onPointerCancel,
    required this.title,
    required this.fontSize,
  });

  final int index;
  final bool isHighlighted;
  final void Function(int) onPointerDown;
  final void Function(int) onPointerUp;
  final void Function(int) onPointerCancel;

  final String title;
  final double fontSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Listener(
      onPointerDown: (PointerDownEvent event) => onPointerDown(index),
      onPointerUp: (PointerUpEvent event) => onPointerUp(index),
      onPointerCancel: (PointerCancelEvent event) => onPointerCancel(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isHighlighted
              ? theme.colorScheme.secondaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          title: Text(
            title,
            style: TextStyle(
              color: isHighlighted
                  ? theme.colorScheme.onSecondaryContainer
                  : theme.colorScheme.onSurfaceVariant,
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}