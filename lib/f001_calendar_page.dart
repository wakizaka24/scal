import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'f002_end_drawer.dart';

class CalendarPage extends HookConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('2023年6月'),
            ],
          ),
        ),
        endDrawer: const EndDrawer(),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                height: 52,
                color: const Color(0xCCDED2BF),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
              )

            ],
          ),
        )
    );
  }
}