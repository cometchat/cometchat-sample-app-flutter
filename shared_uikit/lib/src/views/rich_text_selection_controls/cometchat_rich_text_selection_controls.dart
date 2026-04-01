import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

/// Builds a context menu that adds rich text formatting options as additional
/// items alongside the native text selection options (Cut, Copy, Paste, Select All).
///
/// This function returns a widget that can be used with TextField's contextMenuBuilder
/// to add formatting options like Bold, Italic, Underline, etc. as native menu items.
///
/// Example usage:
/// ```dart
/// TextField(
///   contextMenuBuilder: (context, editableTextState) {
///     return buildRichTextContextMenu(
///       context: context,
///       editableTextState: editableTextState,
///       onFormatTap: (formatType) {
///         // Apply formatting
///       },
///     );
///   },
/// )
/// ```
Widget buildRichTextContextMenu({
  required BuildContext context,
  required EditableTextState editableTextState,
  required void Function(FormatType) onFormatTap,
  Set<FormatType> hiddenFormats = const {},
}) {
  // Get the native context menu button items
  final List<ContextMenuButtonItem> buttonItems =
      List.from(editableTextState.contextMenuButtonItems);

  // Define the formats to add to the menu
  // Only showing inline formats that make sense for selected text
  final formatsToAdd = [
    FormatType.bold,
    FormatType.italic,
    FormatType.underline,
    FormatType.strikethrough,
    FormatType.inlineCode,
    FormatType.link,
  ];

  // Add format options as ContextMenuButtonItems
  for (final formatType in formatsToAdd) {
    if (hiddenFormats.contains(formatType)) continue;

    buttonItems.add(
      ContextMenuButtonItem(
        label: _getLabelForFormat(formatType),
        onPressed: () {
          // Hide the context menu first
          ContextMenuController.removeAny();
          // Apply the format
          onFormatTap(formatType);
        },
      ),
    );
  }

  // Return the adaptive text selection toolbar with all items
  return AdaptiveTextSelectionToolbar.buttonItems(
    anchors: editableTextState.contextMenuAnchors,
    buttonItems: buttonItems,
  );
}

/// Returns the label for each format type.
String _getLabelForFormat(FormatType formatType) {
  switch (formatType) {
    case FormatType.bold:
      return 'Bold';
    case FormatType.italic:
      return 'Italic';
    case FormatType.underline:
      return 'Underline';
    case FormatType.strikethrough:
      return 'Strikethrough';
    case FormatType.inlineCode:
      return 'Code';
    case FormatType.link:
      return 'Link';
    case FormatType.codeBlock:
      return 'Code Block';
    case FormatType.bulletList:
      return 'Bullet List';
    case FormatType.orderedList:
      return 'Numbered List';
    case FormatType.blockquote:
      return 'Quote';
  }
}
