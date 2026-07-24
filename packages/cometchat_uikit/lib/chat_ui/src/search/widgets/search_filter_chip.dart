import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

/// A filter chip with optional icon, toggling between selected/unselected states.
class SearchFilterChip extends StatelessWidget {
  const SearchFilterChip({
    super.key,
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
    required this.colorPalette,
    required this.spacing,
    required this.typography,
    this.selectedColor,
    this.unselectedColor,
    this.selectedIconColor,
    this.unselectedIconColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.selectedBorder,
    this.unSelectedBorder,
    this.borderRadius,
    this.selectedTextStyle,
    this.textStyle,
  });

  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final CometChatColorPalette colorPalette;
  final CometChatSpacing spacing;
  final CometChatTypography typography;

  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedIconColor;
  final Color? unselectedIconColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final BoxBorder? selectedBorder;
  final BoxBorder? unSelectedBorder;
  final BorderRadius? borderRadius;
  final TextStyle? selectedTextStyle;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? (selectedColor ??
              colorPalette.secondaryButtonBackground ??
              Colors.transparent)
        : (unselectedColor ?? colorPalette.background3 ?? Colors.transparent);

    final txtColor = isSelected
        ? (selectedTextColor ?? colorPalette.textWhite)
        : (unselectedTextColor ??
              colorPalette.textSecondary ??
              Colors.transparent);

    final icnColor = isSelected
        ? (selectedIconColor ?? colorPalette.iconWhite ?? Colors.transparent)
        : (unselectedIconColor ??
              colorPalette.iconSecondary ??
              Colors.transparent);

    final border = isSelected
        ? (selectedBorder ??
              Border.all(
                color: colorPalette.neutral800 ?? Colors.transparent,
                width: 1,
              ))
        : (unSelectedBorder ??
              Border.all(
                color: colorPalette.borderLight ?? Colors.transparent,
                width: 1,
              ));

    final radius =
        borderRadius ?? BorderRadius.circular(spacing.radiusMax ?? 20);

    return Semantics(
      button: true,
      label: '$label filter${isSelected ? ', selected' : ''}',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.padding3 ?? 12,
            vertical: spacing.padding1 ?? 4,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            border: border,
            borderRadius: radius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: icnColor),
                SizedBox(width: spacing.padding1 ?? 4),
              ],
              Text(
                label,
                style: TextStyle(
                  color: txtColor,
                  fontSize: typography.body?.medium?.fontSize,
                  fontWeight: typography.body?.medium?.fontWeight,
                  fontFamily: typography.body?.medium?.fontFamily,
                ).merge(isSelected ? selectedTextStyle : textStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
