import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../clean_architecture/core/constants/enums.dart';
import '../../clean_architecture/presentation/formatters/attributed_text.dart';
import '../../clean_architecture/presentation/formatters/cometchat_text_formatter.dart';
import '../../theme/theme/cometchat_theme_helper.dart';
import 'format_result.dart';
import 'rich_text_format_type.dart';

/// Formatter for links using [text](url) syntax
class LinkTextFormatter extends CometChatTextFormatter {
  LinkTextFormatter()
      : super(
          trackingCharacter: '[',
          pattern: RegExp(r'\[([^\]]+)\]\(([^)]+)\)'),
        );

  /// Apply link format with URL
  FormatResult applyLink(
    String text,
    TextSelection selection,
    String displayText,
    String url,
  ) {
    final linkMarkdown = '[$displayText]($url)';
    final newText = text.substring(0, selection.start) +
        linkMarkdown +
        text.substring(selection.end);

    return FormatResult(
      newText: newText,
      newSelection: TextSelection.collapsed(
        offset: selection.start + linkMarkdown.length,
      ),
      formatApplied: RichTextFormatType.link,
    );
  }

  /// Embed a pasted URL into selected text as [selectedText](url) (Bug 1.1)
  ///
  /// If the cursor is inside a code block, inserts raw URL only (Bug 1.2).
  FormatResult applyLinkEmbed(
    String text,
    TextSelection selection,
    String url,
  ) {
    // Bug 1.2: Inside code block, insert raw URL only
    if (_isInsideCodeBlock(text, selection.start)) {
      final newText = text.substring(0, selection.start) +
          url +
          text.substring(selection.end);
      return FormatResult(
        newText: newText,
        newSelection: TextSelection.collapsed(
          offset: selection.start + url.length,
        ),
        formatApplied: RichTextFormatType.link,
      );
    }

    // Bug 1.1: Wrap selected text as markdown link
    if (!selection.isCollapsed) {
      final selectedText = text.substring(selection.start, selection.end);
      final linkMarkdown = '[$selectedText]($url)';
      final newText = text.substring(0, selection.start) +
          linkMarkdown +
          text.substring(selection.end);
      return FormatResult(
        newText: newText,
        newSelection: TextSelection.collapsed(
          offset: selection.start + linkMarkdown.length,
        ),
        formatApplied: RichTextFormatType.link,
      );
    }

    // No selection, just insert the URL
    final newText = text.substring(0, selection.start) +
        url +
        text.substring(selection.end);
    return FormatResult(
      newText: newText,
      newSelection: TextSelection.collapsed(
        offset: selection.start + url.length,
      ),
      formatApplied: RichTextFormatType.link,
    );
  }

  /// Check if position is inside a code block
  bool _isInsideCodeBlock(String text, int position) {
    int i = 0;
    bool insideBlock = false;
    int blockContentStart = 0;

    while (i < text.length) {
      if (i + 3 <= text.length && text.substring(i, i + 3) == '```') {
        if (!insideBlock) {
          insideBlock = true;
          blockContentStart = i + 3;
          if (blockContentStart < text.length &&
              text[blockContentStart] == '\n') {
            blockContentStart++;
          }
        } else {
          if (position >= blockContentStart && position <= i) {
            return true;
          }
          insideBlock = false;
        }
        i += 3;
      } else {
        i++;
      }
    }

    if (insideBlock && position >= blockContentStart) {
      return true;
    }
    return false;
  }

  /// Check if format is active at the given position
  bool isActiveAtPosition(String text, int position) {
    if (pattern == null) return false;

    for (final match in pattern!.allMatches(text)) {
      if (position >= match.start && position <= match.end) {
        return true;
      }
    }
    return false;
  }

  @override
  void init() {
    // Initialize formatter - no-op for link formatter
  }

  @override
  void handlePreMessageSend(BuildContext context, dynamic baseMessage) {
    // Markdown syntax is preserved in message text - no transformation needed
  }

  @override
  void onScrollToBottom(TextEditingController textEditingController) {
    // Not used for link formatter
  }

  @override
  void onChange(
      TextEditingController textEditingController, String previousText) {
    // Can be overridden for auto-formatting behavior
  }

  @override
  TextStyle getMessageInputTextStyle(BuildContext context) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    return TextStyle(
      decoration: TextDecoration.underline,
      color: colorPalette.primary,
    );
  }

  @override
  TextStyle getMessageBubbleTextStyle(
    BuildContext context,
    BubbleAlignment? alignment, {
    bool forConversation = false,
  }) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    return TextStyle(
      decoration: TextDecoration.underline,
      color: colorPalette.primary,
    );
  }

  @override
  List<AttributedText> buildInputFieldText({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
    required String text,
    List<AttributedText>? existingAttributes,
  }) {
    if (pattern == null) {
      return existingAttributes ?? [];
    }

    final List<AttributedText> attributedTexts = [];
    final matches = pattern!.allMatches(text);

    for (final match in matches) {
      // Apply style to the entire match (including markers)
      final start = match.start;
      final end = match.end;

      // Get the style for this format
      final formatStyle = getMessageInputTextStyle(context);

      attributedTexts.add(
        AttributedText(
          start: start,
          end: end,
          // Don't set underlyingText - keep the original text with markers
          style: formatStyle.merge(style),
        ),
      );
    }

    // Merge with existing attributes
    if (existingAttributes != null && existingAttributes.isNotEmpty) {
      return mergeAttributedText(attributedTexts, existingAttributes);
    }

    return attributedTexts;
  }

  @override
  List<AttributedText> getAttributedText(
    String text,
    BuildContext context,
    BubbleAlignment? alignment, {
    List<AttributedText>? existingAttributes,
    Function(String)? onTap,
    bool forConversation = false,
  }) {
    final attributedTexts = <AttributedText>[];
    final matches = pattern!.allMatches(text);

    for (final match in matches) {
      final url = match.group(2) ?? '';
      attributedTexts.add(AttributedText(
        start: match.start,
        end: match.end,
        style: getMessageBubbleTextStyle(context, alignment,
            forConversation: forConversation),
        onTap: (_) => _openUrl(url),
      ));
    }

    if (existingAttributes != null && existingAttributes.isNotEmpty) {
      return mergeAttributedText(attributedTexts, existingAttributes);
    }
    return attributedTexts;
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
