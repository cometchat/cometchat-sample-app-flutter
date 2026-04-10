import 'package:flutter/material.dart';
import '../../clean_architecture/core/constants/enums.dart';
import '../../clean_architecture/presentation/formatters/attributed_text.dart';
import '../../theme/theme/cometchat_theme_helper.dart';
import 'format_result.dart';
import 'rich_text_format_type.dart';
import 'rich_text_formatter_base.dart';

/// Formatter for code blocks using ``` syntax (triple backticks)
/// Renders in Slack-style with full-width background container
/// - When you type ``` and press Enter, it starts a code block
/// - Everything after ``` until closing ``` (or end of text) is in the code block
/// Formatted in composer, preview, and message bubbles
class CodeBlockTextFormatter extends RichTextFormatterBase {
  CodeBlockTextFormatter()
      : super(
          trackingCharacter: '`',
          // Pattern matches code blocks - we'll handle matching manually in _findCodeBlocks
          // This pattern is just for basic detection
          pattern: RegExp(r'```[\s\S]*?(?:```|$)'),
          openingMarker: '```',
          closingMarker: '```',
          placeholderText: 'code',
        );

  @override
  RichTextFormatType get formatType => RichTextFormatType.codeBlock;

  /// Handle Enter key inside code block - stay inside the block
  FormatResult? handleEnter(String text, TextSelection selection) {
    // Check if cursor is right after ``` (user just typed ``` and pressed Enter)
    if (selection.start >= 3) {
      final beforeCursor = text.substring(0, selection.start);
      if (beforeCursor.endsWith('```')) {
        // User typed ``` and pressed Enter - start code block mode
        // Insert newline after ```
        final newText = '${text.substring(0, selection.start)}\n${text.substring(selection.start)}';
        return FormatResult(
          newText: newText,
          newSelection: TextSelection.collapsed(
            offset: selection.start + 1,
          ),
          formatApplied: RichTextFormatType.codeBlock,
        );
      }
    }
    
    // Check if cursor is inside a code block (after opening ``` but before closing ```)
    final isInside = _isInsideCodeBlock(text, selection.start);
    if (isInside) {
      // Inside code block - insert newline and stay inside
      final newText = '${text.substring(0, selection.start)}\n${text.substring(selection.start)}';
      return FormatResult(
        newText: newText,
        newSelection: TextSelection.collapsed(
          offset: selection.start + 1,
        ),
        formatApplied: RichTextFormatType.codeBlock,
      );
    }
    
    return null;
  }

  /// Check if position is inside a code block (between opening ``` and closing ```)
  bool _isInsideCodeBlock(String text, int position) {
    // Find all ``` occurrences
    int i = 0;
    bool insideBlock = false;
    int blockStartContentPos = 0;
    
    while (i < text.length) {
      if (i + 3 <= text.length && text.substring(i, i + 3) == '```') {
        if (!insideBlock) {
          // Found opening ```
          insideBlock = true;
          blockStartContentPos = i + 3;
          // Skip newline after opening ``` if present
          if (blockStartContentPos < text.length && text[blockStartContentPos] == '\n') {
            blockStartContentPos++;
          }
        } else {
          // Found closing ```
          // Check if position is between opening and closing
          if (position >= blockStartContentPos && position <= i) {
            return true;
          }
          insideBlock = false;
        }
        i += 3;
      } else {
        i++;
      }
    }
    
    // If we're still inside an unclosed block and position is after the opening
    if (insideBlock && position >= blockStartContentPos) {
      return true;
    }
    
    return false;
  }

  @override
  TextStyle getInputFieldTextStyle(BuildContext context) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    return TextStyle(
      fontFamily: 'monospace',
      backgroundColor: colorPalette.background3,
      color: colorPalette.textPrimary,
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
    // Don't apply code block formatting in the composer input field
    // Just return existing attributes - the raw text with ``` markers will be shown
    return existingAttributes ?? [];
  }

  /// Find all code blocks in text (both complete and open-ended)
  List<_CodeBlock> _findCodeBlocks(String text) {
    final List<_CodeBlock> blocks = [];
    int i = 0;
    
    while (i < text.length) {
      // Look for opening ```
      if (i + 3 <= text.length && text.substring(i, i + 3) == '```') {
        final blockStart = i;
        i += 3;
        
        // Skip optional newline after opening ```
        if (i < text.length && text[i] == '\n') {
          i++;
        }
        
        final contentStart = i;
        
        // Find closing ``` or end of text
        int? closingPos;
        while (i < text.length) {
          if (i + 3 <= text.length && text.substring(i, i + 3) == '```') {
            closingPos = i;
            break;
          }
          i++;
        }
        
        if (closingPos != null) {
          // Complete block
          final content = text.substring(contentStart, closingPos).trim();
          if (content.isNotEmpty) {
            blocks.add(_CodeBlock(
              start: blockStart,
              end: closingPos + 3,
              content: content,
            ));
          }
          i = closingPos + 3;
        } else {
          // Open block (no closing ```)
          final content = text.substring(contentStart).trim();
          if (content.isNotEmpty) {
            blocks.add(_CodeBlock(
              start: blockStart,
              end: text.length,
              content: content,
            ));
          }
          break;
        }
      } else {
        i++;
      }
    }
    
    return blocks;
  }

  @override
  TextStyle getMessageBubbleTextStyle(
    BuildContext context,
    BubbleAlignment? alignment, {
    bool forConversation = false,
  }) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);
    return TextStyle(
      fontFamily: 'monospace',
      fontSize: typography.body?.regular?.fontSize,
      color: alignment == BubbleAlignment.right
          ? colorPalette.white
          : colorPalette.textPrimary,
    );
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
    final List<AttributedText> attributedTexts = [];
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    
    // Determine if dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Light mode: dark background + white text
    // Dark mode: light background + black text
    final backgroundColor = isDarkMode 
        ? (colorPalette.neutral200 ?? const Color(0xFFE0E0E0))
        : (colorPalette.neutral800 ?? const Color(0xFF1E1E1E));
    final textColor = isDarkMode 
        ? (colorPalette.neutral900 ?? Colors.black)
        : (colorPalette.white ?? Colors.white);
    
    // Find all code blocks
    final blocks = _findCodeBlocks(text);

    for (final block in blocks) {
      // Slack-style: contrasting background, no left bar
      attributedTexts.add(
        AttributedText(
          start: block.start,
          end: block.end,
          underlyingText: block.content,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            color: textColor,
          ),
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          borderRadius: 4,
          isBlockElement: true,
          onTap: onTap,
        ),
      );
    }

    if (existingAttributes != null && existingAttributes.isNotEmpty) {
      return mergeAttributedText(attributedTexts, existingAttributes);
    }

    return attributedTexts;
  }
}

/// Helper class to store code block info
class _CodeBlock {
  final int start;
  final int end;
  final String content;
  
  _CodeBlock({
    required this.start,
    required this.end,
    required this.content,
  });
}
