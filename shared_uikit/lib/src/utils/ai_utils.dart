import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

class AIUtils {
  static Widget getOnError(BuildContext context,
      {Color? backgroundColor,
      Color? shadowColor,
      String? errorIconUrl,
      String? errorIconPackageName,
      String? errorStateText,
      Color? errorIconTint,
      TextStyle? errorTextStyle}) {
    return Chip(
      backgroundColor: backgroundColor,
      shadowColor: shadowColor,
      label: Row(
        children: [
          Image.asset(
            errorIconUrl ?? AssetConstants.repliesError,
            package: errorIconPackageName ?? UIConstants.packageName,
            color: errorIconTint,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            errorStateText ?? Translations.of(context).somethingWentWrongError,
            style: errorTextStyle,
          ),
        ],
      ),
    );
  }

  static Widget getEmptyView(BuildContext context,
      {Color? backgroundColor,
      Color? shadowColor,
      String? emptyIconUrl,
      String? emptyIconPackageName,
      String? emptyStateText,
      Color? emptyIconTint,
      TextStyle? emptyTextStyle}) {
    return Chip(
      backgroundColor: backgroundColor,
      shadowColor: shadowColor,
      label: Row(
        children: [
          Image.asset(
            emptyIconUrl ?? AssetConstants.repliesEmpty,
            package: emptyIconPackageName ?? UIConstants.packageName,
            color: emptyIconTint,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            emptyStateText ?? Translations.of(context).noMessagesFound,
            style: emptyTextStyle,
          ),
        ],
      ),
    );
  }

  static Widget getLoadingIndicator(BuildContext context,
      {Color? backgroundColor,
      Color? shadowColor,
      String? loadingIconUrl,
      String? loadingIconPackageName,
      String? loadingStateText,
      Color? loadingIconTint,
      TextStyle? loadingTextStyle}) {
    return Chip(
      backgroundColor: backgroundColor ,
      shadowColor: shadowColor,
      label: Row(
        children: [
          Image.asset(
            loadingIconUrl ?? AssetConstants.spinner,
            package: loadingIconPackageName ?? UIConstants.packageName,
            color: loadingIconTint,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            loadingStateText ?? Translations.of(context).generatingIceBreakers,
            style: loadingTextStyle,
          ),
        ],
      ),
    );
  }

  static Widget getErrorText(BuildContext context, CometChatColorPalette colorPalette, CometChatTypography typography, CometChatSpacing spacing,
      {String? errorStateText,
      TextStyle? errorTextStyle,}) {
    return Container(
      height: 116,
      alignment: Alignment.center,
      child: Text(
          errorStateText ??"${Translations.of(context).looksLikeSomethingWrong}\n${Translations.of(context).pleaseTryAgain}.",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: typography.body?.regular?.fontSize,
              fontWeight: typography.body?.regular?.fontWeight,
              fontFamily: typography.body?.regular?.fontFamily,
              color: colorPalette.textSecondary)
              .merge(errorTextStyle)
      ),
    );
  }

  static const String extensionKey = "aiExtension";
}
