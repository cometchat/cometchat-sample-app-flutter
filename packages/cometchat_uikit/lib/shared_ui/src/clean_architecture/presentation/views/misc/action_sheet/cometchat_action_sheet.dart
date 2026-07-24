import 'package:flutter/material.dart';
import '../../../../../../cometchat_uikit_shared.dart';

///[CometChatAttachmentOptionSheet] is a widget that displays a list of options to choose from in a bottom sheet.
/// ```dart
/// CometChatAttachmentOptionSheet(
///  actionItems: [
///  CometChatMessageComposerAction(
///  id: "example",
///  title: "Example Action",
///  icon: Icon(Icons.example),
///  style: CometChatAttachmentOptionSheetStyle(
///  backgroundColor: Colors.white,
///  ),
///  onItemClick: () {
///  // Do something when this message composer action is selected
///  },
///  ),
///  ],
///  style: CometChatAttachmentOptionSheetStyle(
///  backgroundColor: Colors.white,
///  ),
///  );
///  ```
class CometChatAttachmentOptionSheet extends StatefulWidget {
  const CometChatAttachmentOptionSheet({
    super.key,
    required this.actionItems,
    this.style,
  });

  final List<ActionItem> actionItems;
  final CometChatAttachmentOptionSheetStyle? style;

  @override
  State<CometChatAttachmentOptionSheet> createState() =>
      _CometChatAttachmentOptionSheetState();
}

class _CometChatAttachmentOptionSheetState
    extends State<CometChatAttachmentOptionSheet> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final actionSheetStyle =
        CometChatThemeHelper.getTheme<CometChatAttachmentOptionSheetStyle>(
          context: context,
          defaultTheme: CometChatAttachmentOptionSheetStyle.of,
        ).merge(widget.style);
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final spacing = CometChatThemeHelper.getSpacing(context);
    final typography = CometChatThemeHelper.getTypography(context);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.5,
          ),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            border: actionSheetStyle.border,
            borderRadius:
                actionSheetStyle.borderRadius ??
                BorderRadius.vertical(
                  top: Radius.circular(spacing.radius6 ?? 0),
                ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Min size based on content
            children: [
              Container(
                padding: EdgeInsets.only(top: spacing.padding3 ?? 0),
                decoration: BoxDecoration(
                  color:
                      actionSheetStyle.backgroundColor ??
                      colorPalette.background1,
                  borderRadius:
                      actionSheetStyle.borderRadius ??
                      BorderRadius.vertical(
                        top: Radius.circular(spacing.radius6 ?? 0),
                      ),
                ),
                child: Center(
                  child: Container(
                    height: 4,
                    width: 32,
                    decoration: BoxDecoration(
                      color: colorPalette.neutral500,
                      borderRadius: BorderRadius.circular(
                        spacing.radiusMax ?? 0,
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.actionItems.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      minTileHeight: 0,
                      minVerticalPadding: 0,
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        setState(() {
                          selectedIndex = index;
                        });
                        Navigator.of(context).pop(widget.actionItems[index]);
                      },
                      contentPadding: EdgeInsets.symmetric(
                        vertical: spacing.padding3 ?? 0,
                        horizontal: spacing.padding4 ?? 0,
                      ),
                      dense: true,
                      selected: selectedIndex == index,
                      selectedTileColor:
                          widget.actionItems[index].style?.backgroundColor ??
                          actionSheetStyle.backgroundColor ??
                          colorPalette.background4,
                      minLeadingWidth: 0,
                      leading: widget.actionItems[index].icon,
                      iconColor:
                          widget.actionItems[index].style?.iconColor ??
                          actionSheetStyle.iconColor ??
                          colorPalette.iconSecondary,
                      tileColor:
                          widget.actionItems[index].style?.backgroundColor ??
                          actionSheetStyle.backgroundColor ??
                          colorPalette.background1,
                      title: Text(
                        widget.actionItems[index].title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            TextStyle(
                                  color:
                                      widget
                                          .actionItems[index]
                                          .style
                                          ?.titleColor ??
                                      actionSheetStyle.titleColor ??
                                      colorPalette.textPrimary,
                                  fontSize:
                                      typography.heading4?.regular?.fontSize,
                                  fontWeight:
                                      typography.heading4?.regular?.fontWeight,
                                  fontFamily:
                                      typography.heading4?.regular?.fontFamily,
                                )
                                .merge(
                                  widget
                                          .actionItems[index]
                                          .style
                                          ?.titleTextStyle ??
                                      actionSheetStyle.titleTextStyle,
                                )
                                .copyWith(
                                  color:
                                      widget
                                          .actionItems[index]
                                          .style
                                          ?.titleColor ??
                                      actionSheetStyle.titleColor,
                                ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Shows a bottom sheet with a list of options to choose from.
/// Returns the selected [ActionItem] when an option is selected.
/// ```dart
/// showCometChatAttachmentOptionSheet(
///  context: context,
///  actionItems: [
///  CometChatMessageComposerAction(
///  id: "example",
///  title: "Example Action",
///  icon: Icon(Icons.example),
///  style: CometChatAttachmentOptionSheetStyle(
///  backgroundColor: Colors.white,
///  ),
///  onItemClick: () {
///  // Do something when this message composer action is selected
///  },
///  ),
///  ],
///  style: CometChatAttachmentOptionSheetStyle(
///  backgroundColor: Colors.white,
/// ),
/// );
/// ```
Future<ActionItem?>? showCometChatAttachmentOptionSheet({
  required BuildContext context,
  required List<ActionItem> actionItems,
  required CometChatColorPalette colorPalette,
  final CometChatAttachmentOptionSheetStyle? style,
}) {
  return showModalBottomSheet<ActionItem>(
    backgroundColor: colorPalette.background1,
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    builder: (BuildContext context) =>
        CometChatAttachmentOptionSheet(actionItems: actionItems, style: style),
  );
}
