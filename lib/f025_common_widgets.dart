import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'f017_design_config.dart';

// class CWx extends HookConsumerWidget {
//   final String title;
//
//   const CWx({
//     super.key,
//     required this.title,
//   });
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Container();
//   }
// }

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
    final colorConfig = ref.watch(designConfigNotifierProvider).colorConfig;
    var borderColor = colorConfig!.borderColor;
    var highlightAlpha = colorConfig.highlightBgColorAlpha;

    return Container(
      decoration: BoxDecoration(
        color: !highlight ? Colors.transparent : borderColor.withAlpha(
            highlightAlpha), borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(padding: EdgeInsets.symmetric(
          vertical: verticalPaddingWidth),
          child: Row(children: [
            SizedBox(
                width: 65,
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
  final FocusNode? focusNode;
  final String? hintText;
  final double fontSize;
  final TextAlign textAlign;
  final TextAlignVertical textAlignVertical;
  final double paddingAll;
  final bool? enabled;
  final bool readOnly;
  final bool focus;
  final bool highlight;
  final TextInputType? keyboardType;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<bool>? onFocusChange;

  const CWTextField({
    super.key,
    required this.controller,
    this.focusNode,
    this.hintText,
    this.fontSize = 15,
    this.textAlign = TextAlign.left,
    this.textAlignVertical = TextAlignVertical.center,
    this.paddingAll = 8,
    this.enabled,
    this.readOnly = false,
    this.focus = true,
    required this.highlight,
    this.keyboardType,
    this.maxLines = 1,
    this.inputFormatters,
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

    var textField = TextField(
        controller: controller,
        focusNode: focusNode,
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
        inputFormatters: inputFormatters,
        readOnly: readOnly,
        enabled: enabled,
        onChanged: onChanged
    );

    if (focus) {
      return Focus(
          onFocusChange: onFocusChange,
          child: textField
      );
    } else {
      return textField;
    }
  }
}

class CWIconButton extends HookConsumerWidget {
  final String? assetName;
  final double? assetIconSize;
  final IconData? icon;
  final double width;
  final double height;
  final double radius;
  final Color foregroundColor;
  final VoidCallback? onPressed;

  const CWIconButton({
    super.key,
    this.assetName,
    this.assetIconSize = 21,
    this.icon,
    this.width = 32,
    this.height = 32,
    this.radius = 16,
    this.foregroundColor = Colors.white,
    required this.onPressed
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var child = assetName != null ? ImageIcon(AssetImage(assetName!),
        size: assetIconSize) : Icon(icon);
    
    return SizedBox(width: width, height: height,
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: foregroundColor,
            textStyle: const TextStyle(fontSize: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
            padding: const EdgeInsets.all(0),
          ), child: child,
        )
    );
  }
}

class CWElevatedButton extends HookConsumerWidget {
  final String title;
  final double width;
  final double height;
  final double radius;
  final double fontSize;
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;
  final Color? disabledForegroundColor;
  final double? elevation;
  final Color? color;
  final VoidCallback? onPressed;

  const CWElevatedButton({
    super.key,
    required this.title,
    this.width = 70,
    this.height = 39,
    this.radius = 18,
    this.fontSize = 13,
    this.backgroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.elevation,
    this.color,
    this.onPressed
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(width: width, height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          // fixedSize: Size(width, height),
          backgroundColor: backgroundColor,
          disabledBackgroundColor: disabledBackgroundColor,
          disabledForegroundColor: disabledForegroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          elevation: elevation,
          textStyle: TextStyle(fontSize: fontSize),
          minimumSize: Size.zero,
          padding: EdgeInsets.zero,
        ),
        child: Text(title,
            style: TextStyle(
                fontWeight: buttonFontWeight,
                color: color
            )
        )
      )
    );
  }
}

class CWTextButton extends HookConsumerWidget {
  final String title;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final VoidCallback onPressed;

  const CWTextButton({
    super.key,
    required this.title,
    this.fontSize = 15,
    this.padding = EdgeInsets.zero,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final normalTextColor = ref.read(designConfigNotifierProvider)
        .colorConfig!.normalTextColor;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: normalTextColor,
        textStyle: TextStyle(fontSize: fontSize),
        minimumSize: Size.zero,
        padding: padding,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(title),
    );
  }
}

class CWCell extends HookConsumerWidget {
  final String? title;
  final Widget? child;

  const CWCell({
    super.key,
    this.title,
    this.child
  });



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container();
  }
}