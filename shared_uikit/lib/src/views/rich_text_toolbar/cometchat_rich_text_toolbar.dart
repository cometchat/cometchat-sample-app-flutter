import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

/// [CometChatRichTextToolbar] is a widget that displays a horizontal row of
/// formatting buttons for rich text editing.
///
/// The toolbar supports various text formatting options including bold, italic,
/// strikethrough, inline code, code block, link, bullet list, ordered list,
/// and blockquote.
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
///     buttonActiveIconColor: Colors.blue,
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
    this.disabledFormats = const {},
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

  /// Set of formats that are disabled (not clickable).
  ///
  /// Buttons for disabled formats will be rendered with disabled styling
  /// (e.g., reduced opacity) and will not respond to taps.
  /// This is used when code block is active to disable inline formatting options.
  final Set<FormatType> disabledFormats;

  /// Style configuration for the toolbar appearance.
  ///
  /// If not provided, default theme values will be used.
  final CometChatRichTextToolbarStyle? style;

  @override
  Widget build(BuildContext context) {
    final toolbarStyle = CometChatThemeHelper.getTheme<CometChatRichTextToolbarStyle>(
      context: context,
      defaultTheme: CometChatRichTextToolbarStyle.of,
    ).merge(style);

    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final spacing = CometChatThemeHelper.getSpacing(context);

    return Container(
      decoration: BoxDecoration(
        color: toolbarStyle.backgroundColor ?? colorPalette.background2,
        border: toolbarStyle.border,
        borderRadius: toolbarStyle.borderRadius ?? BorderRadius.circular(spacing.radius2 ?? 8),
      ),
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: spacing.padding2 ?? 8,
        bottom: spacing.padding2 ?? 8,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: _buildToolbarButtons(context, toolbarStyle, colorPalette, spacing),
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
  ) {
    final List<Widget> buttons = [];

    // Group 1: Text styling (Bold, Italic, Underline, Strikethrough)
    final textStyleButtons = _buildButtonGroup(
      context,
      [FormatType.bold, FormatType.italic, FormatType.underline, FormatType.strikethrough],
      toolbarStyle,
      colorPalette,
      spacing,
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
  ) {
    final visibleFormats = formats.where((format) => !hiddenFormats.contains(format)).toList();
    return visibleFormats
        .asMap()
        .entries
        .map((entry) => _buildFormatButton(
              context,
              entry.value,
              toolbarStyle,
              colorPalette,
              spacing,
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
    CometChatSpacing spacing, {
    bool isLast = false,
  }) {
    final isActive = activeFormats.contains(formatType);
    final isDisabled = disabledFormats.contains(formatType);
    
    // Determine colors based on active and disabled states
    Color iconColor;
    Color backgroundColor;
    
    if (isDisabled) {
      // Disabled state - use reduced opacity colors
      iconColor = (toolbarStyle.buttonIconColor ?? colorPalette.iconSecondary)?.withOpacity(0.4) ?? Colors.grey.withOpacity(0.4);
      backgroundColor = toolbarStyle.buttonBackgroundColor ?? Colors.transparent;
    } else if (isActive) {
      iconColor = toolbarStyle.buttonActiveIconColor ?? colorPalette.textPrimary ?? Colors.black;
      backgroundColor = toolbarStyle.buttonActiveBackgroundColor ?? colorPalette.background4 ?? Colors.grey.withOpacity(0.2);
    } else {
      iconColor = toolbarStyle.buttonIconColor ?? colorPalette.iconSecondary ?? Colors.grey;
      backgroundColor = toolbarStyle.buttonBackgroundColor ?? Colors.transparent;
    }

    return Padding(
      padding: EdgeInsets.only(right: isLast ? 0 : 16),
      child: Semantics(
        label: _getSemanticLabel(formatType),
        button: true,
        enabled: !isDisabled,
        child: Tooltip(
          message: isDisabled ? '${_getTooltipMessage(formatType)} (disabled in code block)' : _getTooltipMessage(formatType),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isDisabled ? null : () => onFormatTap(formatType),
              borderRadius: toolbarStyle.buttonBorderRadius as BorderRadius? ??
                  BorderRadius.circular(spacing.radius1 ?? 4),
              child: Container(
                padding: toolbarStyle.buttonPadding ??
                    EdgeInsets.all(spacing.padding1 ?? 4),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: toolbarStyle.buttonBorderRadius ??
                      BorderRadius.circular(spacing.radius1 ?? 4),
                ),
                child: Icon(
                  _getIconForFormat(formatType),
                  size: 24,
                  color: iconColor,
                  semanticLabel: _getSemanticLabel(formatType),
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
      color: toolbarStyle.dividerColor ?? colorPalette.borderDefault ?? colorPalette.iconSecondary,
    );
  }

  /// Returns the appropriate icon for each format type.
  IconData _getIconForFormat(FormatType formatType) {
    switch (formatType) {
      case FormatType.bold:
        return Icons.format_bold_outlined;
      case FormatType.italic:
        return Icons.format_italic_outlined;
      case FormatType.underline:
        return Icons.format_underline_outlined;
      case FormatType.strikethrough:
        return Icons.strikethrough_s_outlined;
      case FormatType.inlineCode:
        return Icons.code_outlined;
      case FormatType.codeBlock:
        return Icons.integration_instructions_outlined;
      case FormatType.link:
        return Icons.link_outlined;
      case FormatType.bulletList:
        return Icons.format_list_bulleted_outlined;
      case FormatType.orderedList:
        return Icons.format_list_numbered_outlined;
      case FormatType.blockquote:
        return Icons.format_align_left_outlined;
    }
  }

  /// Returns the semantic label for accessibility.
  String _getSemanticLabel(FormatType formatType) {
    switch (formatType) {
      case FormatType.bold:
        return 'Bold formatting';
      case FormatType.italic:
        return 'Italic formatting';
      case FormatType.underline:
        return 'Underline formatting';
      case FormatType.strikethrough:
        return 'Strikethrough formatting';
      case FormatType.inlineCode:
        return 'Inline code formatting';
      case FormatType.codeBlock:
        return 'Code block formatting';
      case FormatType.link:
        return 'Insert link';
      case FormatType.bulletList:
        return 'Bullet list formatting';
      case FormatType.orderedList:
        return 'Numbered list formatting';
      case FormatType.blockquote:
        return 'Blockquote formatting';
    }
  }

  /// Returns the tooltip message for each format type.
  String _getTooltipMessage(FormatType formatType) {
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
        return 'Inline Code';
      case FormatType.codeBlock:
        return 'Code Block';
      case FormatType.link:
        return 'Link';
      case FormatType.bulletList:
        return 'Bullet List';
      case FormatType.orderedList:
        return 'Numbered List';
      case FormatType.blockquote:
        return 'Blockquote';
    }
  }
}
