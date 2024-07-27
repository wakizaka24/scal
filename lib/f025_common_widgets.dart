import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'f016_design.dart';

// class CWPadding extends HookConsumerWidget {
//   final Widget child;
//   final EdgeInsetsGeometry padding;
//   final double? width;
//   final double? height;
//
//   const CWPadding({
//     super.key,
//     required this.padding,
//     this.width,
//     this.height,
//     required this.child
//   });
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Padding(padding: padding, child:
//       SizedBox(width: width, height: height, child: child)
//     );
//   }
// }

class CWLeftTitle extends HookConsumerWidget {
  final String title;
  final double fontSize;
  final bool highlight;
  final double verticalPaddingWidth;
  final double rightPaddingWidth;
  final bool expanded;
  final Widget child;

  const CWLeftTitle({
    super.key,
    required this.title,
    this.fontSize = 15,
    required this.highlight,
    this.verticalPaddingWidth = 6,
    this.rightPaddingWidth = 6,
    this.expanded = true,
    required this.child
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final theme = Theme.of(context);
    final colorConfig = ref.watch(designConfigNotifierProvider).colorConfig!;
    return Container(
      decoration: BoxDecoration(
        color: !highlight ? Colors.transparent : colorConfig.eventListTitleBgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(padding: EdgeInsets.symmetric(
          vertical: verticalPaddingWidth),
          child: Row(children: [
            SizedBox(
                width: 52,
                child: Text(title, textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w300,
                        color: !highlight ? colorConfig.normalTextColor
                            : colorConfig.disabledTextColor
                    )
                )
            ),
            Visibility(visible: !expanded, child: child),
            Visibility(visible: expanded, child: Expanded(child: child)),
            Visibility(visible: expanded && rightPaddingWidth > 0,
                child: SizedBox(width: rightPaddingWidth))
          ])
      ),
    );
  }
}

class CWTextField extends HookConsumerWidget {
  final TextEditingController controller;
  final String? hintText;
  final double fontSize;
  final TextAlign textAlign;
  final TextAlignVertical textAlignVertical;
  final double paddingAll;
  final bool? enabled;
  final bool readOnly;
  final bool highlight;
  final TextInputType? keyboardType;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<bool>? onFocusChange;

  const CWTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.fontSize = 15,
    this.textAlign = TextAlign.left,
    this.textAlignVertical = TextAlignVertical.center,
    this.paddingAll = 8,
    this.enabled,
    this.readOnly = false,
    required this.highlight,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
    this.onFocusChange
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorConfig = ref.watch(designConfigNotifierProvider).colorConfig!;
    var border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(
          color: Colors.transparent,
          width: 0),
    );
    return
      Focus(
          onFocusChange: onFocusChange,
          child: TextField(
              controller: controller,
              style: TextStyle(
                fontSize: fontSize, color: colorConfig.normalTextColor,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.all(paddingAll),
                enabledBorder: border,
                disabledBorder: border,
                focusedBorder: border,
                filled: true,
                fillColor: !highlight ? Colors.transparent
                    : Colors.white38,
                hintStyle: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w300,
                  color: colorConfig.disabledTextColor,
                ),
                hintText: hintText,
              ),
              textAlign: textAlign,
              textAlignVertical: textAlignVertical,
              keyboardType: keyboardType,
              maxLines: maxLines,
              readOnly: readOnly,
              enabled: enabled,
              onChanged: onChanged
          )
    );
  }
}