import 'package:flutter/material.dart';

enum EndDrawerMenuType {
  test1(title: 'テスト1'),
  test2(title: 'テスト2'),
  test3(title: 'テスト3'),
  test4(title: 'テスト4'),
  test5(title: 'テスト5');

  const EndDrawerMenuType({required this.title});
  final String title;
}

class EndDrawer extends StatefulWidget {
  const EndDrawer({super.key});

  @override
  State<EndDrawer> createState() => _EndDrawerState();
}

class _EndDrawerState extends State<EndDrawer> {
  int? _highlightedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    ListView menuList = ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (int i=0; i < EndDrawerMenuType.values.length; i++) ... {
          HighlightAbleButton(
            title: EndDrawerMenuType.values[i].title,
            fontSize: 18,
            index: i,
            isHighlighted: _highlightedIndex == i,
            onTapDown: (int? i) async {
              setState(() {
                _highlightedIndex = i;
              });
            },
            onTap: (int? i) async {
              setState(() {
                _highlightedIndex = null;
              });
              Navigator.pop(context);

              final snackBar = SnackBar(
                content: Text('${EndDrawerMenuType
                    .values[i!].title}をクリックしました!'),
                action: SnackBarAction(
                  label: '詳細',
                  onPressed: () {
                  },
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
            onTapCancel: (int? i) async {
              setState(() {
                _highlightedIndex = null;
              });
            },
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
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_forward),
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

class HighlightAbleButton extends StatelessWidget {
  const HighlightAbleButton({super.key,
    required this.title,
    this.fontSize,
    this.index,
    required this.isHighlighted,
    required this.onTapDown,
    required this.onTap,
    required this.onTapCancel,
  });

  final String title;
  final double? fontSize;
  final int? index;
  final bool isHighlighted;
  final void Function(int?) onTapDown;
  final void Function(int?) onTap;
  final void Function(int?) onTapCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (TapDownDetails details) => onTapDown(index),
      onTap: () => onTap(index),
      onTapCancel: () => onTapCancel(index),
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