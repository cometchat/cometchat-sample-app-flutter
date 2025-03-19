import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

///Function to show comeChat action sheet
Future<CometChatMessageComposerAction?>? showCometChatAiOptionSheet(
    {required BuildContext context,
    required List<CometChatMessageComposerAction> actionItems,
    final User? user,
    final Group? group,
    final CometChatColorPalette? colorPalette,
    final CometChatTypography? typography,
    final CometChatSpacing? spacing,
      final CometChatAiOptionSheetStyle? style,
      final AIOptionsStyle? aiOptionStyle,
    }) {
  final aiOptionSheetStyle = CometChatThemeHelper.getTheme<CometChatAiOptionSheetStyle>(
    context: context,
    defaultTheme: CometChatAiOptionSheetStyle.of,
  ).merge(style);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    backgroundColor: aiOptionSheetStyle.backgroundColor ?? colorPalette?.background1,
    shape: RoundedRectangleBorder(
      side: aiOptionSheetStyle.border ?? BorderSide.none,
      borderRadius: aiOptionSheetStyle.borderRadius ?? BorderRadius.vertical(
        top: Radius.circular(spacing?.radius6 ?? 0),
      ),
    ),

    builder: (builder) {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: actionItems.length,
        padding: EdgeInsets.only(
          top: spacing?.padding5 ?? 0,
          bottom: spacing?.padding5 ?? 0,
        ),
        itemBuilder: (_, int index) {
          return Container(
            decoration: BoxDecoration(
              border: actionItems[index].style?.border,
              borderRadius: actionItems[index].style?.borderRadius,
              color: actionItems[index].style?.backgroundColor,
            ),
            child: GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                Navigator.of(context).pop();
                if (actionItems[index].onItemClick != null) {
                  actionItems[index].onItemClick!(context, user, group);
                }
              },
              child: ListTile(
                contentPadding: EdgeInsets.all(
                  spacing?.padding4 ?? 0,
                ),
                minVerticalPadding: 0,
                minLeadingWidth: 0,
                minTileHeight: 0,
                leading: actionItems[index].icon,
                iconColor: actionItems[index].style?.iconColor ?? aiOptionSheetStyle.iconColor ??
                    colorPalette?.iconHighlight ?? Colors.transparent,
                title: Text(
                  actionItems[index].title,
                  style: TextStyle(
                      fontSize: typography?.body?.regular?.fontSize,
                      fontWeight: typography?.body?.regular?.fontWeight,
                      color: actionItems[index].style?.titleColor ?? colorPalette?.textPrimary,
                      fontFamily: typography?.body?.regular?.fontFamily)
                      .merge(
                    actionItems[index].style?.titleTextStyle ?? aiOptionSheetStyle.textStyle,
                  ).copyWith(
                    color: actionItems[index].style?.titleColor ?? colorPalette?.textPrimary,
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
  // }
// }
  return null;
}
