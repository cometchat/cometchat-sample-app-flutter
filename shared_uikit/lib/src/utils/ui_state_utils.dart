import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';
import 'package:flutter/material.dart';

class UIStateUtils {
  static getDefaultErrorStateView(
    BuildContext context,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatSpacing spacing,
    VoidCallback? retryCallBack, {
    String? errorStateText,
    Color? errorStateTextColor,
    TextStyle? errorStateTextStyle,
    String? errorStateSubtitle,
    Color? errorStateSubtitleColor,
    TextStyle? errorStateSubtitleStyle,
    TextStyle? buttonTextStyle,
    Color? buttonTextColor,
    Color? buttonBackgroundColor,
    BorderSide? buttonBorderSide,
    BorderRadiusGeometry? buttonBorderRadius,
        User? user,
        Group? group,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AssetConstants(CometChatThemeHelper.getBrightness(context))
                .messagesError,
            package: UIConstants.packageName,
            height: 120,
            width: 120,
          ),

          const SizedBox(height: 20), // Space between the icon and title

          // Title Text
          Text(
            errorStateText ?? Translations.of(context).oops,
            style: TextStyle(
                fontSize: typography.heading3?.bold?.fontSize,
                fontWeight: typography.heading3?.bold?.fontWeight,
                color: errorStateTextColor ??
                    colorPalette.textPrimary)
                .merge(errorStateTextStyle)
            .copyWith(color: errorStateTextColor)
          ),

          const SizedBox(height: 4), // Space between the title and subtitle

          // Subtitle Text
          Text(
    errorStateSubtitle ??"${Translations.of(context).looksLikeSomethingWrong}\n${Translations.of(context).pleaseTryAgain}.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: typography.body?.regular?.fontSize,
                  fontWeight: typography.body?.regular?.fontWeight,
                  color: errorStateSubtitleColor ??
                      colorPalette.textSecondary)
                  .merge(errorStateSubtitleStyle)
          .copyWith(color: errorStateSubtitleColor)
          ),

          (user?.role != AIConstants.aiRole) ?
          Padding(
            padding: EdgeInsets.only(
              top: spacing.padding5 ?? 20,
            ),
            child: ElevatedButton(
              onPressed: retryCallBack,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    buttonBackgroundColor ?? colorPalette.buttonBackground,
                fixedSize: const Size(120, 24),
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.padding5 ?? 20,
                  vertical: spacing.padding2 ?? 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: buttonBorderRadius ??
                      BorderRadius.circular(spacing.radius2 ?? 8),
                  side: buttonBorderSide ?? BorderSide.none,
                ),
              ),
              child: Center(
                child: Text(
                  Translations.of(context).retry,
                  style: TextStyle(
                    fontSize: typography.button?.medium?.fontSize,
                    fontWeight: typography.button?.medium?.fontWeight,
                    fontFamily: typography.button?.medium?.fontFamily,
                    color: buttonTextColor ?? colorPalette.white,
                  )
                      .merge(
                        buttonTextStyle,
                      )
                      .copyWith(
                        color: buttonTextColor,
                      ),
                ),
              ),
            ),
          ) : const SizedBox(),
        ],
      ),
    );
  }

  static getDefaultEmptyStateView(
      BuildContext context,
      CometChatColorPalette colorPalette,
      CometChatTypography typography,
      CometChatSpacing spacing,
      {
        String? emptyStateText,
        Color? emptyStateTextColor,
        TextStyle? emptyStateTextStyle,
        String? emptyStateSubtitle,
        Color? emptyStateSubtitleColor,
        TextStyle? emptyStateSubtitleStyle,
        Widget? icon,
      }
      ){
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.padding10 ?? 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon ?? const SizedBox(),
            const SizedBox(height: 30),
            Text(
              emptyStateText ?? "",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: emptyStateTextColor ?? colorPalette.textPrimary,
                fontSize: typography.heading3?.bold?.fontSize,
                fontWeight: typography.heading3?.bold?.fontWeight,
                fontFamily: typography.heading3?.bold?.fontFamily,
              )
                  .merge(emptyStateTextStyle)
                  .copyWith(color: emptyStateTextColor),
            ),
            Text(
              emptyStateSubtitle ?? "",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: emptyStateSubtitleColor ??
                    colorPalette.textSecondary,
                fontSize: typography.body?.regular?.fontSize,
                fontWeight: typography.body?.regular?.fontWeight,
                fontFamily: typography.body?.regular?.fontFamily,
              )
                  .merge(
                emptyStateSubtitleStyle,
              )
                  .copyWith(
                color: emptyStateSubtitleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
