import 'package:flutter/material.dart';
import '../../cometchat_uikit_shared.dart';

class GetMenuView extends StatelessWidget {
  const GetMenuView({
    super.key,
    required this.option,
    this.iconTint,
    this.textStyle,
  });

  final CometChatOption option;
  final Color? iconTint;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final typography = CometChatThemeHelper.getTypography(context);
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final spacing = CometChatThemeHelper.getSpacing(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.padding4 ?? 0,
        vertical: spacing.padding4 ?? 0,
      ),
      decoration: BoxDecoration(
        color: colorPalette.background1,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
              Padding(
                padding: EdgeInsets.only(right: spacing.padding2 ?? 0),
                child: option.iconWidget ?? Image.asset(
                  option.icon ?? "",
                  package: option.packageName ?? UIConstants.packageName,
                  color: iconTint ?? option.iconTint ?? colorPalette.error,
                  height: 24,
                  width: 24,
                ),
              ),
          Expanded(
            child: Text(
              option.title ?? "",
              style: TextStyle(
                color: colorPalette.textPrimary,
                fontSize: typography.body?.regular?.fontSize,
                fontWeight: typography.body?.regular?.fontWeight,
                fontFamily: typography.body?.regular?.fontFamily,
              ).merge(textStyle),
            ),
          ),
        ],
      ),
    );
  }
}
