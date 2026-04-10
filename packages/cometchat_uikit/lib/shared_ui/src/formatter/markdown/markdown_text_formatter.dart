import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../clean_architecture/core/constants/enums.dart';
import '../../clean_architecture/presentation/formatters/cometchat_text_formatter.dart';
import '../../clean_architecture/presentation/formatters/attributed_text.dart';
import '../../clean_architecture/presentation/theme/theme/cometchat_theme_helper.dart';
import '../../clean_architecture/presentation/theme/colors/cometchat_color_palette.dart';

/// A single unified formatter that parses all markdown syntax for message bubble display.
///
/// Replaces the 10+ legacy formatter classes (BoldTextFormatter, ItalicTextFormatter, etc.)
/// with one class that handles: bold, italic, strikethrough, underline, inline code,
/// code blocks, links, bullet lists, ordered lists, and blockquotes.
///
/// Usage:
/// ```dart
/// final formatter = MarkdownTextFormatter();
/// // Pass as a CometChatTextFormatter to FormatterUtils.buildTextSpan()
/// ```
class MarkdownTextFormatter extends CometChatTextFormatter {
  MarkdownTextFormatter({
    this.enableBold = true,
    this.enableItalic = true,
    this.enableStrikethrough = true,
    this.enableUnderline = true,
    this.enableInlineCode = true,
    this.enableCodeBlock = true,
    this.enableLink = true,
    this.enableBulletList = true,
    this.enableOrderedList = true,
    this.enableBlockquote = true,
  }) : super();

  final bool enableBold;
  final bool enableItalic;
  final bool enableStrikethrough;
  final bool enableUnderline;
  final bool enableInlineCode;
  final bool enableCodeBlock;
  final bool enableLink;
  final bool enableBulletList;
  final bool enableOrderedList;
  final bool enableBlockquote;

  // ── Regex patterns ──────────────────────────────────────────────────────────

  /// Helper to pick text color based on bubble alignment
  static Color? _textColor(CometChatColorPalette cp, BubbleAlignment? align) =>
      align == BubbleAlignment.right ? cp.white : cp.textPrimary;

  static final _boldPattern = RegExp(r'\*\*(.+?)\*\*');
  static final _italicPattern = RegExp(r'(?<!_)_([^_]+)_(?!_)');
  static final _doubleUnderscoreItalicPattern = RegExp(r'__(.+?)__');
  static final _strikethroughPattern = RegExp(r'~~(.+?)~~');
  static final _underlinePattern = RegExp(r'<u>(.+?)</u>');
  static final _inlineCodePattern = RegExp(r'`([^`]+)`');
  // Code blocks are parsed manually via _findCodeBlocks, not via regex
  static final _linkPattern = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');
  static final _bulletPattern = RegExp(r'^- (.*)(?:$)', multiLine: true);
  static final _orderedPattern = RegExp(r'^(\d+)\. (.*)(?:$)', multiLine: true);
  static final _blockquotePattern = RegExp(r'(^>[ ]?.*(?:\n>[ ]?.*)*)', multiLine: true);

  /// Strip all markdown markers from text (for nested formats in underlyingText)
  static String _stripMarkers(String text) {
    var r = text;
    r = r.replaceAllMapped(_boldPattern, (m) => m.group(1) ?? '');
    r = r.replaceAllMapped(_doubleUnderscoreItalicPattern, (m) => m.group(1) ?? '');
    r = r.replaceAllMapped(_italicPattern, (m) => m.group(1) ?? '');
    r = r.replaceAllMapped(_strikethroughPattern, (m) => m.group(1) ?? '');
    r = r.replaceAllMapped(_inlineCodePattern, (m) => m.group(1) ?? '');
    r = r.replaceAllMapped(_underlinePattern, (m) => m.group(1) ?? '');
    r = r.replaceAllMapped(_linkPattern, (m) => m.group(1) ?? '');
    return r;
  }

  // ── CometChatTextFormatter interface ────────────────────────────────────────

  @override
  void init() {}

  @override
  void handlePreMessageSend(BuildContext context, dynamic baseMessage) {}

  @override
  void onScrollToBottom(TextEditingController textEditingController) {}

  @override
  void onChange(TextEditingController textEditingController, String previousText) {}

  @override
  TextStyle getMessageInputTextStyle(BuildContext context) => const TextStyle();

  @override
  TextStyle getMessageBubbleTextStyle(
    BuildContext context,
    BubbleAlignment? alignment, {
    bool forConversation = false,
  }) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    return TextStyle(
      color: alignment == BubbleAlignment.right
          ? colorPalette.white
          : colorPalette.textPrimary,
    );
  }

  // ── The main method: getAttributedText ──────────────────────────────────────

  @override
  List<AttributedText> getAttributedText(
    String text,
    BuildContext context,
    BubbleAlignment? alignment, {
    List<AttributedText>? existingAttributes,
    Function(String)? onTap,
    bool forConversation = false,
  }) {
    List<AttributedText> result = existingAttributes ?? [];
    final colorPalette = CometChatThemeHelper.getColorPalette(context);

    // Collect code ranges first — these are "protected" zones where
    // inline formatting (bold, italic, etc.) must NOT be applied.
    final List<_Range> codeRanges = [];
    if (enableCodeBlock) {
      for (final block in _findCodeBlocks(text)) {
        codeRanges.add(_Range(block.start, block.end));
      }
    }
    if (enableInlineCode) {
      for (final match in _inlineCodePattern.allMatches(text)) {
        codeRanges.add(_Range(match.start, match.end));
      }
    }

    // Block-level elements first (code blocks, blockquotes)
    if (enableCodeBlock) {
      result = _collectCodeBlocks(text, context, alignment, colorPalette, result, onTap);
    }
    if (enableBlockquote) {
      result = _collectBlockquotes(text, context, alignment, colorPalette, result, onTap);
    }

    // Inline elements — skip matches inside code ranges
    if (enableBold) {
      result = _collectInline(text, _boldPattern, context, alignment, result, onTap,
          forConversation: forConversation,
          excludeRanges: codeRanges,
          styleBuilder: (cp, align, fc) => TextStyle(
                fontWeight: FontWeight.bold,
                color: _textColor(cp, align),
              ));
    }
    if (enableItalic) {
      // Double underscore __text__ first (before single _ catches inner part)
      result = _collectInline(text, _doubleUnderscoreItalicPattern, context, alignment, result, onTap,
          forConversation: forConversation,
          excludeRanges: codeRanges,
          styleBuilder: (cp, align, fc) => TextStyle(
                fontStyle: FontStyle.italic,
                color: _textColor(cp, align),
              ));
      result = _collectInline(text, _italicPattern, context, alignment, result, onTap,
          forConversation: forConversation,
          excludeRanges: codeRanges,
          styleBuilder: (cp, align, fc) => TextStyle(
                fontStyle: FontStyle.italic,
                color: _textColor(cp, align),
              ));
    }
    if (enableStrikethrough) {
      result = _collectInline(text, _strikethroughPattern, context, alignment, result, onTap,
          forConversation: forConversation,
          excludeRanges: codeRanges,
          styleBuilder: (cp, align, fc) => TextStyle(
                decoration: TextDecoration.lineThrough,
                color: _textColor(cp, align),
              ));
    }
    if (enableUnderline) {
      result = _collectInline(text, _underlinePattern, context, alignment, result, onTap,
          forConversation: forConversation,
          excludeRanges: codeRanges,
          styleBuilder: (cp, align, fc) => TextStyle(
                decoration: TextDecoration.underline,
                color: _textColor(cp, align),
              ));
    }
    if (enableInlineCode) {
      result = _collectInlineCode(text, context, alignment, colorPalette, result, onTap);
    }
    if (enableLink) {
      result = _collectLinks(text, context, alignment, colorPalette, result,
          excludeRanges: codeRanges);
    }
    if (enableBulletList) {
      result = _collectBullets(text, context, alignment, result, onTap, forConversation: forConversation);
    }
    if (enableOrderedList) {
      result = _collectOrdered(text, context, alignment, result, onTap, forConversation: forConversation);
    }

    return result;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Returns true if the range [start, end) overlaps with any range in [ranges].
  static bool _overlapsAny(int start, int end, List<_Range> ranges) {
    for (final r in ranges) {
      if (start < r.end && end > r.start) return true;
    }
    return false;
  }

  // ── Inline format collector ─────────────────────────────────────────────────

  List<AttributedText> _collectInline(
    String text,
    RegExp pattern,
    BuildContext context,
    BubbleAlignment? alignment,
    List<AttributedText> existing,
    Function(String)? onTap, {
    required bool forConversation,
    List<_Range> excludeRanges = const [],
    required TextStyle Function(CometChatColorPalette, BubbleAlignment?, bool) styleBuilder,
  }) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final matches = pattern.allMatches(text);
    final attrs = matches
        .where((match) => !_overlapsAny(match.start, match.end, excludeRanges))
        .map((match) {
      String? content = match.group(1);
      if (content != null) content = _stripMarkers(content);
      return AttributedText(
        start: match.start,
        end: match.end,
        underlyingText: content,
        style: styleBuilder(colorPalette, alignment, forConversation),
        onTap: onTap,
      );
    }).toList();

    if (existing.isNotEmpty) {
      return mergeAttributedText(attrs, existing);
    }
    return attrs;
  }

  // ── Code block collector ────────────────────────────────────────────────────

  List<AttributedText> _collectCodeBlocks(
    String text,
    BuildContext context,
    BubbleAlignment? alignment,
    CometChatColorPalette colorPalette,
    List<AttributedText> existing,
    Function(String)? onTap,
  ) {
    final spacing = CometChatThemeHelper.getSpacing(context);
    final isSent = alignment == BubbleAlignment.right;
    final backgroundColor = isSent
        ? (colorPalette.white?.withValues(alpha: 0.2) ?? const Color(0x33FFFFFF))
        : (colorPalette.background3 ?? const Color(0xFFF5F5F5));
    final textColor = isSent
        ? (colorPalette.white ?? Colors.white)
        : (colorPalette.textPrimary ?? Colors.black);

    final blocks = _findCodeBlocks(text);
    final attrs = blocks
        .where((b) => b.content.isNotEmpty)
        .map((b) {
          return AttributedText(
            start: b.start,
            end: b.end,
            underlyingText: b.content,
            style: TextStyle(fontFamily: 'monospace', color: textColor),
            backgroundColor: backgroundColor,
            padding: EdgeInsets.all(spacing.padding2 ?? 8),
            borderRadius: (spacing.radius2 ?? 8).toDouble(),
            isBlockElement: true,
            onTap: onTap,
          );
        })
        .toList();

    if (existing.isNotEmpty) return mergeAttributedText(attrs, existing);
    return attrs;
  }

  /// Parse code blocks (handles unclosed blocks)
  List<_CodeBlock> _findCodeBlocks(String text) {
    final blocks = <_CodeBlock>[];
    int i = 0;
    while (i < text.length) {
      if (i + 3 <= text.length && text.substring(i, i + 3) == '```') {
        final blockStart = i;
        i += 3;
        if (i < text.length && text[i] == '\n') i++;
        final contentStart = i;

        int? closingPos;
        while (i < text.length) {
          if (i + 3 <= text.length && text.substring(i, i + 3) == '```') {
            closingPos = i;
            break;
          }
          i++;
        }

        final end = closingPos != null ? closingPos + 3 : text.length;
        final contentEnd = closingPos ?? text.length;
        blocks.add(_CodeBlock(blockStart, end, text.substring(contentStart, contentEnd).trim()));
        i = end;
      } else {
        i++;
      }
    }
    return blocks;
  }

  // ── Blockquote collector ────────────────────────────────────────────────────

  // ── Inline code collector ───────────────────────────────────────────────────

  List<AttributedText> _collectInlineCode(
    String text,
    BuildContext context,
    BubbleAlignment? alignment,
    CometChatColorPalette colorPalette,
    List<AttributedText> existing,
    Function(String)? onTap,
  ) {
    final isSent = alignment == BubbleAlignment.right;
    final backgroundColor = isSent
        ? (colorPalette.white?.withValues(alpha: 0.2) ?? const Color(0x33FFFFFF))
        : (colorPalette.background3 ?? const Color(0xFFF5F5F5));
    final textColor = isSent
        ? (colorPalette.white ?? Colors.white)
        : (colorPalette.primary ?? Colors.blue);

    final matches = _inlineCodePattern.allMatches(text);
    final attrs = matches.map((match) {
      final content = match.group(1) ?? '';
      return AttributedText(
        start: match.start,
        end: match.end,
        underlyingText: content,
        style: TextStyle(fontFamily: 'monospace', color: textColor),
        backgroundColor: backgroundColor,
        onTap: onTap,
      );
    }).toList();

    if (existing.isNotEmpty) return mergeAttributedText(attrs, existing);
    return attrs;
  }

  // ── Blockquote collector (continued) ────────────────────────────────────────

  List<AttributedText> _collectBlockquotes(
    String text,
    BuildContext context,
    BubbleAlignment? alignment,
    CometChatColorPalette colorPalette,
    List<AttributedText> existing,
    Function(String)? onTap,
  ) {
    final typography = CometChatThemeHelper.getTypography(context);
    final isSent = alignment == BubbleAlignment.right;

    // Border: 3px left bar — primary for received, white for sent
    final borderColor = isSent
        ? (colorPalette.white ?? Colors.white)
        : (colorPalette.primary ?? Colors.blue);

    // Background: 0.1 alpha translucent white for sent, neutral100 for received
    final backgroundColor = isSent
        ? (colorPalette.white?.withValues(alpha: 0.1) ?? const Color(0x1AFFFFFF))
        : (colorPalette.neutral100 ?? const Color(0xFFF5F5F5));

    // Text: white for sent, textPrimary for received
    final textColor = isSent
        ? (colorPalette.white ?? Colors.white)
        : (colorPalette.textPrimary ?? Colors.black);

    final matches = _blockquotePattern.allMatches(text);
    final attrs = matches.map((match) {
      final matchedText = match.group(0) ?? '';
      final content = _extractBlockquoteContent(matchedText);
      return AttributedText(
        start: match.start,
        end: match.end,
        underlyingText: content,
        style: TextStyle(
          fontSize: typography.body?.regular?.fontSize,
          fontFamily: typography.body?.regular?.fontFamily,
          fontWeight: typography.body?.regular?.fontWeight,
          color: textColor,
        ),
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4, right: 4),
        border: Border(
          left: BorderSide(
            color: borderColor,
            width: 3,
          ),
        ),
        isBlockElement: true,
        onTap: onTap,
      );
    }).toList();

    if (existing.isNotEmpty) return mergeAttributedText(attrs, existing);
    return attrs;
  }

  String _extractBlockquoteContent(String matchedText) {
    return matchedText
        .split('\n')
        .map((line) => line.startsWith('> ') ? line.substring(2) : (line.startsWith('>') ? line.substring(1) : line))
        .join('\n');
  }

  // ── Link collector ──────────────────────────────────────────────────────────

  List<AttributedText> _collectLinks(
    String text,
    BuildContext context,
    BubbleAlignment? alignment,
    CometChatColorPalette colorPalette,
    List<AttributedText> existing, {
    List<_Range> excludeRanges = const [],
  }) {
    final matches = _linkPattern.allMatches(text);
    final linkColor = alignment == BubbleAlignment.right
        ? colorPalette.white
        : colorPalette.primary;
    final attrs = matches
        .where((match) => !_overlapsAny(match.start, match.end, excludeRanges))
        .map((match) {
      final displayText = match.group(1) ?? '';
      final url = match.group(2) ?? '';
      return AttributedText(
        start: match.start,
        end: match.end,
        underlyingText: displayText,
        style: TextStyle(
          decoration: TextDecoration.underline,
          decorationColor: linkColor,
          color: linkColor,
        ),
        onTap: (_) => _openUrl(url),
      );
    }).toList();

    if (existing.isNotEmpty) return mergeAttributedText(attrs, existing);
    return attrs;
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ── Bullet list collector ───────────────────────────────────────────────────

  List<AttributedText> _collectBullets(
    String text,
    BuildContext context,
    BubbleAlignment? alignment,
    List<AttributedText> existing,
    Function(String)? onTap, {
    required bool forConversation,
  }) {
    final matches = _bulletPattern.allMatches(text);
    final attrs = matches.map((match) {
      return AttributedText(
        start: match.start,
        end: match.start + 2, // "- " prefix only
        underlyingText: '• ',
        style: getMessageBubbleTextStyle(context, alignment, forConversation: forConversation),
        onTap: onTap,
      );
    }).toList();

    if (existing.isNotEmpty) return mergeAttributedText(attrs, existing);
    return attrs;
  }

  // ── Ordered list collector ──────────────────────────────────────────────────

  List<AttributedText> _collectOrdered(
    String text,
    BuildContext context,
    BubbleAlignment? alignment,
    List<AttributedText> existing,
    Function(String)? onTap, {
    required bool forConversation,
  }) {
    final matches = _orderedPattern.allMatches(text);
    final attrs = matches.map((match) {
      final number = match.group(1) ?? '1';
      final prefix = '$number. ';
      return AttributedText(
        start: match.start,
        end: match.start + prefix.length,
        style: getMessageBubbleTextStyle(context, alignment, forConversation: forConversation),
        onTap: onTap,
      );
    }).toList();

    if (existing.isNotEmpty) return mergeAttributedText(attrs, existing);
    return attrs;
  }
}

/// Internal helper for code block parsing
class _CodeBlock {
  final int start;
  final int end;
  final String content;
  const _CodeBlock(this.start, this.end, this.content);
}

/// Internal helper representing a text range
class _Range {
  final int start;
  final int end;
  const _Range(this.start, this.end);
}
