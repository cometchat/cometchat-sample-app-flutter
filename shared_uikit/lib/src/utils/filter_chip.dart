import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';
import 'package:flutter/material.dart';

class FilterChip extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final bool? isSelected;
  final VoidCallback? onTap;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final Color? selectedIconColor;
  final Color? unselectedIconColor;
  final Border? selectedBorder;
  final Border? unSelectedBorder;
  final BorderRadius? borderRadius;
  final CometChatTypography typography;
  final CometChatSpacing spacing;
  final CometChatColorPalette colorPalette;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? selectedTextStyle;

  const FilterChip({
    super.key,
    this.label,
    this.icon,
    this.isSelected = false,
    this.onTap,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.selectedBorder,
    this.unSelectedBorder,
    this.borderRadius,
    required this.typography,
    required this.spacing,
    required this.colorPalette,
    this.textStyle,
    this.contentPadding,
    this.selectedIconColor,
    this.unselectedIconColor,
    this.selectedTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: contentPadding ??
            EdgeInsets.symmetric(
              vertical: spacing.padding2 ?? 6,
              horizontal: spacing.padding3 ?? 12,
            ),
        decoration: BoxDecoration(
          color: (isSelected != null && isSelected == true)
              ? selectedColor
              : unselectedColor,
          border: (isSelected != null && isSelected == true)
              ? selectedBorder
              : unSelectedBorder,
          borderRadius: borderRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(right: spacing.padding1 ?? 0),
              child: Icon(
                icon,
                color: (isSelected != null && isSelected == true)
                    ? selectedIconColor
                    : unselectedIconColor,
                size: 16,
              ),
            ),
            Text(
              label ?? "",
              style: (isSelected != null && isSelected == true)
                  ? TextStyle(
                      color: selectedTextColor ?? colorPalette.textWhite,
                      fontSize: typography.body?.regular?.fontSize,
                      fontWeight: typography.body?.regular?.fontWeight,
                      fontFamily: typography.body?.regular?.fontFamily,
                    )
                      .merge(selectedTextStyle)
                      .copyWith(color: selectedTextColor)
                  : TextStyle(
                      color: unselectedTextColor ?? colorPalette.textSecondary,
                      fontSize: typography.body?.regular?.fontSize,
                      fontWeight: typography.body?.regular?.fontWeight,
                      fontFamily: typography.body?.regular?.fontFamily,
                    ).merge(textStyle).copyWith(color: unselectedTextColor),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterItem {
  final String id;
  final String label;
  final IconData icon;
  const FilterItem(this.id, this.label, this.icon);
}
