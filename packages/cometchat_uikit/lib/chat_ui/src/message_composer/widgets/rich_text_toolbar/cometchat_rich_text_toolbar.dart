import 'package:flutter/material.dart';
import '../../../../../../shared_ui/cometchat_uikit_shared.dart';
import '../../../../../../shared_ui/src/rich_text_formatting/domain/entities/format_type.dart';
import '../../../../../../shared_ui/src/rich_text_formatting/domain/entities/format_compatibility.dart';
import 'cometchat_rich_text_toolbar_style.dart';

/// [CometChatRichTextToolbar] is a widget that displays a horizontal row of
/// formatting buttons for rich text editing.
///
/// The toolbar supports various text formatting options including bold, italic,
/// strikethrough, inline code, code block, link, bullet list, ordered list,
/// and blockquote.
///
/// Format compatibility is automatically enforced - when certain formats are
/// active, incompatible formats will be shown as disabled (e.g., code block
/// disables all other formats).
///
/// ```dart
/// CometChatRichTextToolbar(
///   onFormatTap: (formatType) {
///     // Handle format button tap
///   },
///   activeFormats: {FormatType.bold, FormatType.italic},
///   hiddenFormats: {FormatType.codeBlock},
///   style: CometChatRichTextToolbarStyle(
///     backgroundColor: Colors.white,
///     buttonIconColor: Colors.grey,
///     activeButtonIconColor: Colors.blue,
///   ),
/// );
/// ```
class CometChatRichTextToolbar extends StatelessWidget {
  /// Creates a rich text formatting toolbar.
  ///
  /// The [onFormatTap] callback is required and will be invoked when any
  /// format button is tapped.
  const CometChatRichTextToolbar({
    super.key,
    required this.onFormatTap,
    this.activeFormats = const {},
    this.hiddenFormats = const {},
    this.style,
  });

  /// Callback invoked when a format button is tapped.
  ///
  /// The [FormatType] of the tapped button is passed to the callback.
  final void Function(FormatType) onFormatTap;

  /// Set of currently active formats.
  ///
  /// Buttons for active formats will be displayed with active styling
  /// (e.g., highlighted background and icon color).
  final Set<FormatType> activeFormats;

  /// Set of formats to hide from the toolbar.
  ///
  /// Buttons for hidden formats will not be rendered in the toolbar.
  final Set<FormatType> hiddenFormats;

  /// Style configuration for the toolbar appearance.
  ///
  /// If not provided, default theme values will be used.
  final CometChatRichTextToolbarStyle? style;

  @override
  Widget build(BuildContext context) {
    final toolbarStyle = CometChatRichTextToolbarStyle.of(context).merge(style);
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final spacing = CometChatThemeHelper.getSpacing(context);
    
    // Calculate disabled formats based on active formats
    final disabledFormats = FormatCompatibility.getDisabledFormats(activeFormats);

    return Container(
      decoration: BoxDecoration(
        color: toolbarStyle.backgroundColor ?? colorPalette.background2,
        border: toolbarStyle.border,
        borderRadius: toolbarStyle.borderRadius ??
            BorderRadius.circular(spacing.radius2 ?? 8),
      ),
      padding: EdgeInsets.only(
        left: spacing.padding3 ?? 12,
        right: spacing.padding3 ?? 12,
        top: spacing.padding1 ?? 4,
        bottom: spacing.padding1 ?? 4,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: _buildToolbarButtons(
              context, toolbarStyle, colorPalette, spacing, disabledFormats),
        ),
      ),
    );
  }

  /// Builds the list of toolbar buttons with dividers between groups.
  List<Widget> _buildToolbarButtons(
    BuildContext context,
    CometChatRichTextToolbarStyle toolbarStyle,
    CometChatColorPalette colorPalette,
    CometChatSpacing spacing,
    Set<FormatType> disabledFormats,
  ) {
    final List<Widget> buttons = [];

    // Group 1: Text styling (Bold, Italic, Underline, Strikethrough)
    final textStyleButtons = _buildButtonGroup(
      context,
      [
        FormatType.bold,
        FormatType.italic,
        FormatType.underline,
        FormatType.strikethrough
      ],
      toolbarStyle,
      colorPalette,
      spacing,
      disabledFormats,
    );
    if (textStyleButtons.isNotEmpty) {
      buttons.addAll(textStyleButtons);
    }

    // Group 2: Link and Lists (Link, Ordered List, Bullet List)
    final linkAndListButtons = _buildButtonGroup(
      context,
      [FormatType.link, FormatType.orderedList, FormatType.bulletList],
      toolbarStyle,
      colorPalette,
      spacing,
      disabledFormats,
    );
    if (linkAndListButtons.isNotEmpty) {
      if (buttons.isNotEmpty) {
        buttons.add(_buildDivider(toolbarStyle, colorPalette, spacing));
      }
      buttons.addAll(linkAndListButtons);
    }

    // Group 3: Quote and Code (Blockquote, Inline Code, Code Block)
    final quoteAndCodeButtons = _buildButtonGroup(
      context,
      [FormatType.blockquote, FormatType.inlineCode, FormatType.codeBlock],
      toolbarStyle,
      colorPalette,
      spacing,
      disabledFormats,
    );
    if (quoteAndCodeButtons.isNotEmpty) {
      if (buttons.isNotEmpty) {
        buttons.add(_buildDivider(toolbarStyle, colorPalette, spacing));
      }
      buttons.addAll(quoteAndCodeButtons);
    }

    return buttons;
  }

  /// Builds a group of format buttons, filtering out hidden formats.
  List<Widget> _buildButtonGroup(
    BuildContext context,
    List<FormatType> formats,
    CometChatRichTextToolbarStyle toolbarStyle,
    CometChatColorPalette colorPalette,
    CometChatSpacing spacing,
    Set<FormatType> disabledFormats,
  ) {
    final visibleFormats =
        formats.where((format) => !hiddenFormats.contains(format)).toList();

    return visibleFormats
        .asMap()
        .entries
        .map((entry) => _buildFormatButton(
              context,
              entry.value,
              toolbarStyle,
              colorPalette,
              spacing,
              disabledFormats,
              isLast: entry.key == visibleFormats.length - 1,
            ))
        .toList();
  }

  /// Builds a single format button.
  Widget _buildFormatButton(
    BuildContext context,
    FormatType formatType,
    CometChatRichTextToolbarStyle toolbarStyle,
    CometChatColorPalette colorPalette,
    CometChatSpacing spacing,
    Set<FormatType> disabledFormats, {
    bool isLast = false,
  }) {
    final isActive = activeFormats.contains(formatType);
    final isDisabled = disabledFormats.contains(formatType);

    // Determine colors based on state
    Color iconColor;
    Color backgroundColor;
    
    if (isDisabled) {
      iconColor = toolbarStyle.disabledButtonIconColor ?? 
          (colorPalette.iconSecondary?.withOpacity(0.3) ?? Colors.grey.withOpacity(0.3));
      backgroundColor = toolbarStyle.disabledButtonColor ?? Colors.transparent;
    } else if (isActive) {
      iconColor = toolbarStyle.activeButtonIconColor ?? colorPalette.neutral900 ?? Colors.black;
      backgroundColor = toolbarStyle.activeButtonColor ?? colorPalette.neutral300?.withOpacity(0.2) ?? Colors.black.withOpacity(0.08);
    } else {
      iconColor = toolbarStyle.buttonIconColor ?? colorPalette.iconSecondary ?? Colors.grey;
      backgroundColor = toolbarStyle.buttonColor ?? Colors.transparent;
    }

    return Padding(
      padding: EdgeInsets.only(right: isLast ? 0 : (toolbarStyle.buttonSpacing ?? 16)),
      child: Semantics(
        label: formatType.label,
        button: true,
        enabled: !isDisabled,
        child: Tooltip(
          message: isDisabled 
              ? '${formatType.label} (incompatible with current format)'
              : formatType.label,
          child: GestureDetector(
            onTap: isDisabled ? null : () => onFormatTap(formatType),
            behavior: HitTestBehavior.opaque,
            child: Opacity(
              opacity: isDisabled ? 0.4 : 1.0,
              child: Container(
                padding: EdgeInsets.all(spacing.padding1 ?? 4),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(spacing.radius1 ?? 4),
                ),
                child: Icon(
                  formatType.icon,
                  size: toolbarStyle.iconSize ?? 24,
                  color: iconColor,
                  semanticLabel: formatType.label,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a vertical divider between button groups.
  Widget _buildDivider(
    CometChatRichTextToolbarStyle toolbarStyle,
    CometChatColorPalette colorPalette,
    CometChatSpacing spacing,
  ) {
    return Container(
      height: 24,
      width: 1,
      margin: EdgeInsets.symmetric(horizontal: spacing.padding2 ?? 8),
      color: toolbarStyle.dividerColor ??
          colorPalette.borderDefault ??
          colorPalette.iconSecondary,
    );
  }
}
