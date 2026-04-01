import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';
import 'package:url_launcher/url_launcher.dart';

/// Helper class to hold the result of parsing nested formats.
class _NestedFormatResult {
  final String plainText;
  final TextStyle style;
  
  _NestedFormatResult({required this.plainText, required this.style});
}

/// Helper class to hold a format match with its metadata.
class _FormatMatch {
  final int start;
  final int end;
  final String content;
  final FormatType? formatType;
  final String? url; // For links
  final bool isMention; // Flag to identify mention matches
  
  _FormatMatch({
    required this.start,
    required this.end,
    required this.content,
    this.formatType,
    this.url,
    this.isMention = false,
  });
}

/// Style configuration for rich text formatting in messages.
///
/// This class defines the visual appearance of formatted text elements
/// such as bold, italic, code blocks, links, etc.
class CometChatRichTextFormatterStyle {
  const CometChatRichTextFormatterStyle({
    this.boldTextStyle,
    this.italicTextStyle,
    this.underlineTextStyle,
    this.strikethroughTextStyle,
    this.inlineCodeTextStyle,
    this.inlineCodeBackgroundColor,
    this.codeBlockTextStyle,
    this.codeBlockBackgroundColor,
    this.linkTextStyle,
    this.linkColor,
    this.bulletListTextStyle,
    this.orderedListTextStyle,
    this.blockquoteTextStyle,
    this.blockquoteBorderColor,
  });

  /// Text style for bold formatted text.
  final TextStyle? boldTextStyle;

  /// Text style for italic formatted text.
  final TextStyle? italicTextStyle;

  /// Text style for underlined text.
  final TextStyle? underlineTextStyle;

  /// Text style for strikethrough text.
  final TextStyle? strikethroughTextStyle;

  /// Text style for inline code.
  final TextStyle? inlineCodeTextStyle;

  /// Background color for inline code.
  final Color? inlineCodeBackgroundColor;

  /// Text style for code blocks.
  final TextStyle? codeBlockTextStyle;

  /// Background color for code blocks.
  final Color? codeBlockBackgroundColor;

  /// Text style for links.
  final TextStyle? linkTextStyle;

  /// Color for link text.
  final Color? linkColor;

  /// Text style for bullet list items.
  final TextStyle? bulletListTextStyle;

  /// Text style for ordered list items.
  final TextStyle? orderedListTextStyle;

  /// Text style for blockquote text.
  final TextStyle? blockquoteTextStyle;

  /// Border color for blockquote.
  final Color? blockquoteBorderColor;

  /// Creates a copy of this style with the given fields replaced.
  CometChatRichTextFormatterStyle copyWith({
    TextStyle? boldTextStyle,
    TextStyle? italicTextStyle,
    TextStyle? underlineTextStyle,
    TextStyle? strikethroughTextStyle,
    TextStyle? inlineCodeTextStyle,
    Color? inlineCodeBackgroundColor,
    TextStyle? codeBlockTextStyle,
    Color? codeBlockBackgroundColor,
    TextStyle? linkTextStyle,
    Color? linkColor,
    TextStyle? bulletListTextStyle,
    TextStyle? orderedListTextStyle,
    TextStyle? blockquoteTextStyle,
    Color? blockquoteBorderColor,
  }) {
    return CometChatRichTextFormatterStyle(
      boldTextStyle: boldTextStyle ?? this.boldTextStyle,
      italicTextStyle: italicTextStyle ?? this.italicTextStyle,
      underlineTextStyle: underlineTextStyle ?? this.underlineTextStyle,
      strikethroughTextStyle: strikethroughTextStyle ?? this.strikethroughTextStyle,
      inlineCodeTextStyle: inlineCodeTextStyle ?? this.inlineCodeTextStyle,
      inlineCodeBackgroundColor: inlineCodeBackgroundColor ?? this.inlineCodeBackgroundColor,
      codeBlockTextStyle: codeBlockTextStyle ?? this.codeBlockTextStyle,
      codeBlockBackgroundColor: codeBlockBackgroundColor ?? this.codeBlockBackgroundColor,
      linkTextStyle: linkTextStyle ?? this.linkTextStyle,
      linkColor: linkColor ?? this.linkColor,
      bulletListTextStyle: bulletListTextStyle ?? this.bulletListTextStyle,
      orderedListTextStyle: orderedListTextStyle ?? this.orderedListTextStyle,
      blockquoteTextStyle: blockquoteTextStyle ?? this.blockquoteTextStyle,
      blockquoteBorderColor: blockquoteBorderColor ?? this.blockquoteBorderColor,
    );
  }

  /// Merges this style with another, with the other style taking precedence.
  CometChatRichTextFormatterStyle merge(CometChatRichTextFormatterStyle? other) {
    if (other == null) return this;
    return copyWith(
      boldTextStyle: other.boldTextStyle,
      italicTextStyle: other.italicTextStyle,
      underlineTextStyle: other.underlineTextStyle,
      strikethroughTextStyle: other.strikethroughTextStyle,
      inlineCodeTextStyle: other.inlineCodeTextStyle,
      inlineCodeBackgroundColor: other.inlineCodeBackgroundColor,
      codeBlockTextStyle: other.codeBlockTextStyle,
      codeBlockBackgroundColor: other.codeBlockBackgroundColor,
      linkTextStyle: other.linkTextStyle,
      linkColor: other.linkColor,
      bulletListTextStyle: other.bulletListTextStyle,
      orderedListTextStyle: other.orderedListTextStyle,
      blockquoteTextStyle: other.blockquoteTextStyle,
      blockquoteBorderColor: other.blockquoteBorderColor,
    );
  }
}


/// [CometChatRichTextFormatter] is a text formatter that handles rich text
/// formatting in the message composer and message bubbles.
///
/// This formatter extends [CometChatTextFormatter] and provides:
/// - Detection and styling of markdown-formatted text (bold, italic, code, etc.)
/// - Input field text styling with format highlighting
/// - Message bubble text styling for rendered formatted content
/// - Integration with [RichTextFormatterManager] for format operations
///
/// The formatter supports the following format types:
/// - Bold: **text**
/// - Italic: _text_
/// - Underline: <u>text</u>
/// - Strikethrough: ~~text~~
/// - Inline code: `code`
/// - Code block: ```code```
/// - Link: [text](url)
/// - Bullet list: - item
/// - Ordered list: 1. item
/// - Blockquote: > text
///
/// Example usage:
/// ```dart
/// CometChatRichTextFormatter(
///   style: CometChatRichTextFormatterStyle(
///     boldTextStyle: TextStyle(fontWeight: FontWeight.bold),
///     italicTextStyle: TextStyle(fontStyle: FontStyle.italic),
///     linkColor: Colors.blue,
///   ),
/// );
/// ```
class CometChatRichTextFormatter extends CometChatTextFormatter {
  CometChatRichTextFormatter({
    super.showLoadingIndicator = false,
    super.onSearch,
    super.message,
    super.messageBubbleTextStyle,
    super.messageInputTextStyle,
    super.composerId,
    super.suggestionListEventSink,
    super.previousTextEventSink,
    super.user,
    super.group,
    this.style,
    this.onLinkTap,
    this.enabledFormats,
  }) : super(
          // Rich text formatter doesn't use tracking character
          trackingCharacter: null,
          // Combined pattern to match all rich text formats
          pattern: _combinedPattern,
        );

  /// Style configuration for rich text formatting.
  final CometChatRichTextFormatterStyle? style;

  /// Callback invoked when a link is tapped in the message bubble.
  final void Function(String url)? onLinkTap;

  /// Set of enabled format types. If null, all formats are enabled.
  final Set<FormatType>? enabledFormats;

  /// Combined regex pattern that matches all rich text formats.
  static RegExp get _combinedPattern => FormatPatterns.combined;

  /// Individual patterns for each format type - delegated to FormatPatterns
  static RegExp get _boldPattern => FormatPatterns.bold;
  static RegExp get _italicPattern => FormatPatterns.italic;
  static RegExp get _underlinePattern => FormatPatterns.underline;
  static RegExp get _strikethroughPattern => FormatPatterns.strikethrough;
  static RegExp get _inlineCodePattern => FormatPatterns.inlineCode;
  static RegExp get _codeBlockPattern => FormatPatterns.codeBlock;
  static RegExp get _linkPattern => FormatPatterns.link;
  static RegExp get _blockquotePattern => FormatPatterns.blockquote;

  @override
  void init() {
    // No initialization needed for rich text formatter
  }
  
  /// Handles link tap by either calling the custom onLinkTap callback
  /// or using the default URL launcher.
  void _handleLinkTap(String url) async {
    if (onLinkTap != null) {
      onLinkTap!(url);
    } else {
      // Default behavior: launch the URL
      String urlToLaunch = url;
      if (!RegExp(r'^(https?:\/\/)', caseSensitive: false).hasMatch(url)) {
        urlToLaunch = 'https://$url';
      }
      try {
        await launchUrl(Uri.parse(urlToLaunch));
      } catch (e) {
        debugPrint('Failed to launch URL: $e');
      }
    }
  }

  @override
  TextStyle getMessageInputTextStyle(BuildContext context) {
    if (messageInputTextStyle != null) {
      return messageInputTextStyle!(context);
    }
    
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);
    
    return TextStyle(
      color: colorPalette.textPrimary,
      fontSize: typography.body?.regular?.fontSize,
      fontWeight: typography.body?.regular?.fontWeight,
      fontFamily: typography.body?.regular?.fontFamily,
    );
  }

  @override
  TextStyle getMessageBubbleTextStyle(
    BuildContext context,
    BubbleAlignment? alignment, {
    bool forConversation = false,
  }) {
    if (messageBubbleTextStyle != null) {
      return messageBubbleTextStyle!(context, alignment, forConversation: forConversation);
    }
    
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);
    
    return TextStyle(
      color: alignment == BubbleAlignment.right
          ? colorPalette.white
          : colorPalette.textPrimary,
      fontSize: typography.body?.regular?.fontSize,
      fontWeight: typography.body?.regular?.fontWeight,
      fontFamily: typography.body?.regular?.fontFamily,
    );
  }

  @override
  void handlePreMessageSend(BuildContext context, BaseMessage baseMessage) {
    // Rich text formatting is preserved as-is in the message text
    // No transformation needed before sending
  }

  @override
  void onScrollToBottom(TextEditingController textEditingController) {
    // No pagination needed for rich text formatter
  }

  @override
  void onChange(TextEditingController textEditingController, String previousText) {
    // Rich text formatter doesn't need to track changes for suggestions
    // Format detection is handled by RichTextFormatterManager in the controller
  }

  /// Builds attributed text for the input field with format highlighting.
  ///
  /// This method identifies formatted regions in the text and applies
  /// appropriate styling to help users visualize their formatting.
  @override
  List<AttributedText> buildInputFieldText({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
    required String text,
    List<AttributedText>? existingAttributes,
  }) {
    final List<AttributedText> attributedTexts = [];
    
    // Process each format type and collect attributed text regions
    _addAttributedTextForPattern(
      text: text,
      pattern: _boldPattern,
      formatType: FormatType.bold,
      context: context,
      attributedTexts: attributedTexts,
    );
    
    _addAttributedTextForPattern(
      text: text,
      pattern: _italicPattern,
      formatType: FormatType.italic,
      context: context,
      attributedTexts: attributedTexts,
    );
    
    _addAttributedTextForPattern(
      text: text,
      pattern: _underlinePattern,
      formatType: FormatType.underline,
      context: context,
      attributedTexts: attributedTexts,
    );
    
    _addAttributedTextForPattern(
      text: text,
      pattern: _strikethroughPattern,
      formatType: FormatType.strikethrough,
      context: context,
      attributedTexts: attributedTexts,
    );
    
    _addAttributedTextForPattern(
      text: text,
      pattern: _inlineCodePattern,
      formatType: FormatType.inlineCode,
      context: context,
      attributedTexts: attributedTexts,
    );
    
    _addAttributedTextForPattern(
      text: text,
      pattern: _codeBlockPattern,
      formatType: FormatType.codeBlock,
      context: context,
      attributedTexts: attributedTexts,
    );
    
    _addAttributedTextForPattern(
      text: text,
      pattern: _linkPattern,
      formatType: FormatType.link,
      context: context,
      attributedTexts: attributedTexts,
    );
    
    // Add blockquote styling for input field
    _addAttributedTextForPattern(
      text: text,
      pattern: _blockquotePattern,
      formatType: FormatType.blockquote,
      context: context,
      attributedTexts: attributedTexts,
    );
    
    // Note: bulletList and orderedList line-level formats are NOT
    // processed here because their prefixes ("- ", "1. ") are converted
    // to visual markers ("• ", "1. ") by the display conversion methods.
    
    // Merge with existing attributes
    if (existingAttributes != null && existingAttributes.isNotEmpty) {
      return mergeAttributedText(attributedTexts, existingAttributes);
    }
    
    return attributedTexts;
  }

  /// Adds attributed text entries for matches of a specific pattern.
  /// 
  /// For the input field, we show the content with formatting applied
  /// but without the markdown markers visible.
  /// It handles nested formats by recursively parsing and combining styles.
  void _addAttributedTextForPattern({
    required String text,
    required RegExp pattern,
    required FormatType formatType,
    required BuildContext context,
    required List<AttributedText> attributedTexts,
  }) {
    // Skip if this format is not enabled
    if (enabledFormats != null && !enabledFormats!.contains(formatType)) {
      return;
    }
    
    final matches = pattern.allMatches(text);
    
    for (final match in matches) {
      // Extract the content without markers (group 1 contains the inner text)
      final content = match.group(1) ?? text.substring(match.start, match.end);
      
      // Parse nested formats and get combined style and plain text
      final nestedResult = _parseNestedFormatsForInput(
        content,
        context,
        {formatType},
      );
      
      attributedTexts.add(AttributedText(
        start: match.start,
        end: match.end,
        // Provide the fully stripped content as underlyingText
        underlyingText: nestedResult.plainText,
        style: nestedResult.style,
      ));
    }
  }
  
  /// Parses nested formats for input field styling.
  _NestedFormatResult _parseNestedFormatsForInput(
    String text,
    BuildContext context,
    Set<FormatType> activeFormats,
  ) {
    String currentText = text;
    Set<FormatType> formats = Set.from(activeFormats);
    
    // Keep parsing until no more format markers are found
    bool foundFormat = true;
    while (foundFormat) {
      foundFormat = false;
      
      // Check for bold
      final boldMatch = _boldPattern.firstMatch(currentText);
      if (boldMatch != null && boldMatch.start == 0 && boldMatch.end == currentText.length) {
        formats.add(FormatType.bold);
        currentText = boldMatch.group(1) ?? currentText;
        foundFormat = true;
        continue;
      }
      
      // Check for italic
      final italicMatch = _italicPattern.firstMatch(currentText);
      if (italicMatch != null && italicMatch.start == 0 && italicMatch.end == currentText.length) {
        formats.add(FormatType.italic);
        currentText = italicMatch.group(1) ?? currentText;
        foundFormat = true;
        continue;
      }
      
      // Check for underline
      final underlineMatch = _underlinePattern.firstMatch(currentText);
      if (underlineMatch != null && underlineMatch.start == 0 && underlineMatch.end == currentText.length) {
        formats.add(FormatType.underline);
        currentText = underlineMatch.group(1) ?? currentText;
        foundFormat = true;
        continue;
      }
      
      // Check for strikethrough
      final strikethroughMatch = _strikethroughPattern.firstMatch(currentText);
      if (strikethroughMatch != null && strikethroughMatch.start == 0 && strikethroughMatch.end == currentText.length) {
        formats.add(FormatType.strikethrough);
        currentText = strikethroughMatch.group(1) ?? currentText;
        foundFormat = true;
        continue;
      }
      
      // Check for inline code
      final inlineCodeMatch = _inlineCodePattern.firstMatch(currentText);
      if (inlineCodeMatch != null && inlineCodeMatch.start == 0 && inlineCodeMatch.end == currentText.length) {
        formats.add(FormatType.inlineCode);
        currentText = inlineCodeMatch.group(1) ?? currentText;
        foundFormat = true;
        continue;
      }
    }
    
    // Build combined style from all detected formats
    final combinedStyle = _getCombinedInputStyleForFormats(formats, context);
    
    return _NestedFormatResult(plainText: currentText, style: combinedStyle);
  }
  
  /// Returns a combined text style for multiple format types in the input field.
  TextStyle _getCombinedInputStyleForFormats(
    Set<FormatType> formats,
    BuildContext context,
  ) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);
    
    TextStyle result = TextStyle(
      color: colorPalette.textPrimary,
      fontSize: typography.body?.regular?.fontSize,
      fontFamily: typography.body?.regular?.fontFamily,
    );
    
    // Collect decorations to combine them properly
    List<TextDecoration> decorations = [];
    
    // Apply each format to the style
    for (final format in formats) {
      switch (format) {
        case FormatType.bold:
          result = result.copyWith(fontWeight: FontWeight.bold);
          break;
        case FormatType.italic:
          result = result.copyWith(fontStyle: FontStyle.italic);
          break;
        case FormatType.underline:
          decorations.add(TextDecoration.underline);
          break;
        case FormatType.strikethrough:
          decorations.add(TextDecoration.lineThrough);
          break;
        case FormatType.inlineCode:
          result = result.copyWith(
            fontFamily: 'monospace',
            color: style?.inlineCodeTextStyle?.color ?? colorPalette.primary,
            backgroundColor: style?.inlineCodeBackgroundColor ?? colorPalette.background3,
          );
          break;
        case FormatType.codeBlock:
          // Code block in input field uses backgroundColor in TextStyle
          // (WidgetSpan with Container doesn't work well in editable text fields)
          result = result.copyWith(
            fontFamily: 'monospace',
            backgroundColor: style?.codeBlockBackgroundColor ?? colorPalette.background3,
          );
          break;
        case FormatType.link:
          decorations.add(TextDecoration.underline);
          result = result.copyWith(color: style?.linkColor ?? colorPalette.primary);
          break;
        case FormatType.blockquote:
          // Blockquote text keeps normal style - visual indicator is the │ prefix
          break;
        default:
          // Other formats don't affect inline text style
          break;
      }
    }
    
    // Apply combined decorations with matching decoration color
    if (decorations.isNotEmpty) {
      result = result.copyWith(
        decoration: TextDecoration.combine(decorations),
        decorationColor: result.color,
      );
    }
    
    return result;
  }


  /// Gets attributed text for message bubble rendering.
  ///
  /// This method processes the message text and returns attributed text
  /// regions with appropriate styling for each format type.
  /// It handles nested formats by detecting the outermost format first,
  /// then recursively parsing inner formats.
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
    
    // Parse all formatted regions, handling nested formats properly
    _parseFormattedRegions(
      text: text,
      context: context,
      alignment: alignment,
      attributedTexts: attributedTexts,
      forConversation: forConversation,
    );
    
    // Merge with existing attributes
    if (existingAttributes != null && existingAttributes.isNotEmpty) {
      return mergeAttributedText(attributedTexts, existingAttributes);
    }
    
    return attributedTexts;
  }
  
  /// Parses all formatted regions in the text, handling nested formats.
  /// This method finds all format matches and processes them to handle nesting.
  void _parseFormattedRegions({
    required String text,
    required BuildContext context,
    required BubbleAlignment? alignment,
    required List<AttributedText> attributedTexts,
    required bool forConversation,
  }) {
    // Collect all matches from all patterns
    final allMatches = <_FormatMatch>[];
    
    // Add matches for inline format types only (not line-level formats)
    // Line-level formats (bulletList, orderedList, blockquote) should not
    // consume inline formats - they just add a prefix to the line
    _collectMatches(text, _boldPattern, FormatType.bold, allMatches);
    _collectMatches(text, _italicPattern, FormatType.italic, allMatches);
    _collectMatches(text, _underlinePattern, FormatType.underline, allMatches);
    _collectMatches(text, _strikethroughPattern, FormatType.strikethrough, allMatches);
    _collectMatches(text, _inlineCodePattern, FormatType.inlineCode, allMatches);
    _collectMatches(text, _codeBlockPattern, FormatType.codeBlock, allMatches);
    _collectMatches(text, _linkPattern, FormatType.link, allMatches);
    // Collect blockquote matches - these will be merged into consecutive blocks
    _collectMatches(text, _blockquotePattern, FormatType.blockquote, allMatches);
    
    if (allMatches.isEmpty) return;
    
    // Merge consecutive blockquote lines into single blocks
    final mergedMatches = _mergeConsecutiveBlockquotes(allMatches, text);
    
    // Sort by start position, then by length (longer matches first to get outermost)
    mergedMatches.sort((a, b) {
      final startCompare = a.start.compareTo(b.start);
      if (startCompare != 0) return startCompare;
      // For same start, prefer longer (outermost) match
      return b.end.compareTo(a.end);
    });
    
    // Filter to keep only non-overlapping matches (outermost wins)
    final filteredMatches = <_FormatMatch>[];
    int lastEnd = 0;
    
    for (final match in mergedMatches) {
      if (match.start >= lastEnd) {
        filteredMatches.add(match);
        lastEnd = match.end;
      }
    }
    
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final spacing = CometChatThemeHelper.getSpacing(context);
    
    // Process each outermost match
    for (final match in filteredMatches) {
      String content = match.content;
      
      // For blockquote, strip the "> " prefix before parsing nested formats
      // The prefix is handled by the visual styling (left border)
      if (match.formatType == FormatType.blockquote && content.startsWith('> ')) {
        content = content.substring(2);
      }
      
      // For code blocks, add container styling (background, padding, border radius)
      // and detect URLs inside the code block for clickable links
      if (match.formatType == FormatType.codeBlock) {
        // Build child spans that detect URLs inside the code block
        final childSpans = _buildCodeBlockChildSpans(
          content,
          context,
          alignment,
          forConversation,
        );
        
        final codeBlockStyle = TextStyle(
          fontFamily: 'monospace',
          color: alignment == BubbleAlignment.right
              ? colorPalette.white
              : colorPalette.textPrimary,
        );
        
        attributedTexts.add(AttributedText(
          start: match.start,
          end: match.end,
          underlyingText: content,
          style: codeBlockStyle,
          backgroundColor: style?.codeBlockBackgroundColor ?? 
              (alignment == BubbleAlignment.right 
                  ? colorPalette.white?.withValues(alpha: 0.2)
                  : colorPalette.background3),
          padding: EdgeInsets.all(spacing.padding2 ?? 8),
          borderRadius: spacing.radius2 ?? 8,
          isFullWidth: true,
          childSpans: childSpans,
        ));
      } else if (match.formatType == FormatType.inlineCode) {
        // Build child spans that detect URLs inside the inline code
        final childSpans = _buildInlineCodeChildSpans(
          content,
          context,
          alignment,
          forConversation,
        );
        
        final inlineCodeColor = alignment == BubbleAlignment.right
            ? colorPalette.white
            : colorPalette.primary;
        final inlineCodeStyle = TextStyle(
          fontFamily: 'monospace',
          color: style?.inlineCodeTextStyle?.color ?? inlineCodeColor,
          backgroundColor: style?.inlineCodeBackgroundColor ?? 
              (alignment == BubbleAlignment.right 
                  ? colorPalette.white?.withValues(alpha: 0.2)
                  : colorPalette.background3),
        );
        
        attributedTexts.add(AttributedText(
          start: match.start,
          end: match.end,
          underlyingText: content,
          style: inlineCodeStyle,
          childSpans: childSpans,
        ));
      } else if (match.formatType == FormatType.blockquote) {
        // For blockquotes, parse inline formats within the content
        // and build child spans for rich text rendering
        final childSpans = _buildBlockquoteChildSpans(
          content,
          context,
          alignment,
          forConversation,
        );
        
        // For blockquotes, add left border and background styling (full width)
        // Use primary color for received messages, white for sent messages
        final borderColor = style?.blockquoteBorderColor ?? 
            (alignment == BubbleAlignment.right 
                ? colorPalette.white
                : colorPalette.primary);
        final backgroundColor = alignment == BubbleAlignment.right 
            ? colorPalette.white?.withValues(alpha: 0.1)
            : colorPalette.neutral100;
        attributedTexts.add(AttributedText(
          start: match.start,
          end: match.end,
          underlyingText: content,
          style: _getBlockquoteBaseStyle(context, alignment),
          backgroundColor: backgroundColor,
          padding: EdgeInsets.only(
            left: spacing.padding2 ?? 8,
            top: spacing.padding1 ?? 4,
            bottom: spacing.padding1 ?? 4,
            right: spacing.padding1 ?? 4,
          ),
          border: Border(
            left: BorderSide(
              color: borderColor ?? Colors.grey,
              width: 3,
            ),
          ),
          isFullWidth: true,
          childSpans: childSpans,
        ));
      } else if (match.formatType != null) {
        // Parse nested formats and get combined style and plain text
        final nestedResult = _parseNestedFormats(
          content,
          context,
          alignment,
          forConversation,
          {match.formatType!},
        );
        
        attributedTexts.add(AttributedText(
          start: match.start,
          end: match.end,
          underlyingText: nestedResult.plainText,
          style: nestedResult.style,
          onTap: match.formatType == FormatType.link && match.url != null
              ? (_) => _handleLinkTap(match.url!)
              : null,
        ));
      }
    }
  }
  
  /// Collects all matches for a pattern into the matches list.
  void _collectMatches(
    String text,
    RegExp pattern,
    FormatType formatType,
    List<_FormatMatch> matches,
  ) {
    // Skip if this format is not enabled
    if (enabledFormats != null && !enabledFormats!.contains(formatType)) {
      return;
    }
    
    for (final match in pattern.allMatches(text)) {
      String content;
      String? url;
      
      if (formatType == FormatType.link) {
        content = match.group(1) ?? '';
        url = match.group(2);
      } else if (formatType == FormatType.bulletList ||
                 formatType == FormatType.orderedList ||
                 formatType == FormatType.blockquote) {
        // For line-level formats, keep the full text including the prefix
        // because the prefix ("- ", "1. ", "> ") is part of the display
        content = text.substring(match.start, match.end);
      } else {
        content = match.group(1) ?? text.substring(match.start, match.end);
      }
      
      matches.add(_FormatMatch(
        start: match.start,
        end: match.end,
        content: content,
        formatType: formatType,
        url: url,
      ));
    }
  }
  
  /// Merges consecutive blockquote lines into single blocks.
  /// 
  /// This allows proper handling of multi-line blockquotes where ordered lists
  /// should maintain sequential numbering across lines.
  List<_FormatMatch> _mergeConsecutiveBlockquotes(List<_FormatMatch> matches, String text) {
    // Separate blockquote matches from other matches
    final blockquoteMatches = matches.where((m) => m.formatType == FormatType.blockquote).toList();
    final otherMatches = matches.where((m) => m.formatType != FormatType.blockquote).toList();
    
    if (blockquoteMatches.isEmpty) {
      return matches;
    }
    
    // Sort blockquote matches by start position
    blockquoteMatches.sort((a, b) => a.start.compareTo(b.start));
    
    // Merge consecutive blockquote lines
    final mergedBlockquotes = <_FormatMatch>[];
    _FormatMatch? currentBlock;
    
    for (final match in blockquoteMatches) {
      if (currentBlock == null) {
        currentBlock = match;
      } else {
        // Check if this match is on the next line (immediately after previous match + newline)
        final expectedNextStart = currentBlock.end + 1; // +1 for newline
        if (match.start == expectedNextStart) {
          // Merge: extend the current block to include this line
          // Content becomes: previous content + newline + this line's content (without "> " prefix)
          final thisContent = match.content.startsWith('> ') 
              ? match.content.substring(2) 
              : match.content;
          final prevContent = currentBlock.content.startsWith('> ')
              ? currentBlock.content.substring(2)
              : currentBlock.content;
          currentBlock = _FormatMatch(
            start: currentBlock.start,
            end: match.end,
            content: '> $prevContent\n$thisContent', // Keep "> " prefix for first line only
            formatType: FormatType.blockquote,
          );
        } else {
          // Not consecutive - save current block and start new one
          mergedBlockquotes.add(currentBlock);
          currentBlock = match;
        }
      }
    }
    
    // Don't forget the last block
    if (currentBlock != null) {
      mergedBlockquotes.add(currentBlock);
    }
    
    // Combine merged blockquotes with other matches
    return [...otherMatches, ...mergedBlockquotes];
  }

  /// Builds child spans for code block content that detect URLs and make them clickable.
  /// 
  /// URLs inside code blocks are rendered with underline decoration while keeping
  /// the monospace font style.
  List<InlineSpan> _buildCodeBlockChildSpans(
    String content,
    BuildContext context,
    BubbleAlignment? alignment,
    bool forConversation,
  ) {
    final spans = <InlineSpan>[];
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    
    final baseStyle = TextStyle(
      fontFamily: 'monospace',
      color: alignment == BubbleAlignment.right
          ? colorPalette.white
          : colorPalette.textPrimary,
    );
    
    // Detect URLs in the content
    final urlPattern = RegExp(RegexConstants.urlRegexPattern);
    final urlMatches = urlPattern.allMatches(content).toList();
    
    if (urlMatches.isEmpty) {
      // No URLs - return single span with base style
      spans.add(TextSpan(text: content, style: baseStyle));
      return spans;
    }
    
    // Build spans with URL detection
    int currentPos = 0;
    for (final match in urlMatches) {
      // Add text before the URL
      if (match.start > currentPos) {
        spans.add(TextSpan(
          text: content.substring(currentPos, match.start),
          style: baseStyle,
        ));
      }
      
      // Add the URL with underline and tap handler
      final url = content.substring(match.start, match.end);
      final linkColor = alignment == BubbleAlignment.right
          ? colorPalette.white
          : (style?.linkColor ?? colorPalette.primary);
      
      spans.add(TextSpan(
        text: url,
        style: baseStyle.copyWith(
          color: linkColor,
          decoration: TextDecoration.underline,
          decorationColor: linkColor,
        ),
        recognizer: TapGestureRecognizer()..onTap = () => _handleLinkTap(url),
      ));
      
      currentPos = match.end;
    }
    
    // Add remaining text after the last URL
    if (currentPos < content.length) {
      spans.add(TextSpan(
        text: content.substring(currentPos),
        style: baseStyle,
      ));
    }
    
    return spans;
  }

  /// Builds child spans for inline code content that detect URLs and make them clickable.
  /// 
  /// URLs inside inline code are rendered with underline decoration while keeping
  /// the monospace font style.
  List<InlineSpan> _buildInlineCodeChildSpans(
    String content,
    BuildContext context,
    BubbleAlignment? alignment,
    bool forConversation,
  ) {
    final spans = <InlineSpan>[];
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    
    final inlineCodeColor = alignment == BubbleAlignment.right
        ? colorPalette.white
        : colorPalette.primary;
    final baseStyle = TextStyle(
      fontFamily: 'monospace',
      color: style?.inlineCodeTextStyle?.color ?? inlineCodeColor,
    );
    
    // Detect URLs in the content
    final urlPattern = RegExp(RegexConstants.urlRegexPattern);
    final urlMatches = urlPattern.allMatches(content).toList();
    
    if (urlMatches.isEmpty) {
      // No URLs - return single span with base style
      spans.add(TextSpan(text: content, style: baseStyle));
      return spans;
    }
    
    // Build spans with URL detection
    int currentPos = 0;
    for (final match in urlMatches) {
      // Add text before the URL
      if (match.start > currentPos) {
        spans.add(TextSpan(
          text: content.substring(currentPos, match.start),
          style: baseStyle,
        ));
      }
      
      // Add the URL with underline and tap handler
      final url = content.substring(match.start, match.end);
      final linkColor = alignment == BubbleAlignment.right
          ? colorPalette.white
          : (style?.linkColor ?? colorPalette.primary);
      
      spans.add(TextSpan(
        text: url,
        style: baseStyle.copyWith(
          color: linkColor,
          decoration: TextDecoration.underline,
          decorationColor: linkColor,
        ),
        recognizer: TapGestureRecognizer()..onTap = () => _handleLinkTap(url),
      ));
      
      currentPos = match.end;
    }
    
    // Add remaining text after the last URL
    if (currentPos < content.length) {
      spans.add(TextSpan(
        text: content.substring(currentPos),
        style: baseStyle,
      ));
    }
    
    return spans;
  }

  /// Builds child spans for blockquote content with inline formatting, mentions,
  /// bullet lists, ordered lists, and code blocks.
  /// 
  /// This method parses the blockquote content for all format types
  /// and returns a list of InlineSpans that can be used in a RichText widget.
  List<InlineSpan> _buildBlockquoteChildSpans(
    String content,
    BuildContext context,
    BubbleAlignment? alignment,
    bool forConversation,
  ) {
    final spans = <InlineSpan>[];
    final baseStyle = _getBlockquoteBaseStyle(context, alignment);
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final spacing = CometChatThemeHelper.getSpacing(context);
    
    // First, check for code blocks inside the blockquote
    // Code blocks take precedence and should be rendered as a separate block
    final codeBlockMatches = _codeBlockPattern.allMatches(content).toList();
    if (codeBlockMatches.isNotEmpty) {
      int currentPos = 0;
      for (final codeMatch in codeBlockMatches) {
        // Process content before the code block
        if (codeMatch.start > currentPos) {
          final beforeContent = content.substring(currentPos, codeMatch.start);
          _buildBlockquoteLineSpans(
            beforeContent, 
            context, 
            alignment, 
            forConversation, 
            spans, 
            baseStyle, 
            colorPalette, 
            spacing,
          );
        }
        
        // Add the code block with styling
        final codeContent = codeMatch.group(1) ?? '';
        final codeBlockBgColor = alignment == BubbleAlignment.right 
            ? colorPalette.white?.withValues(alpha: 0.2)
            : colorPalette.background3;
        
        spans.add(WidgetSpan(
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(vertical: spacing.padding1 ?? 4),
            padding: EdgeInsets.all(spacing.padding2 ?? 8),
            decoration: BoxDecoration(
              color: codeBlockBgColor,
              borderRadius: BorderRadius.circular(spacing.radius2 ?? 8),
            ),
            child: Text(
              codeContent,
              style: baseStyle.copyWith(fontFamily: 'monospace'),
            ),
          ),
        ));
        
        currentPos = codeMatch.end;
      }
      
      // Process remaining content after the last code block
      if (currentPos < content.length) {
        final afterContent = content.substring(currentPos);
        _buildBlockquoteLineSpans(
          afterContent, 
          context, 
          alignment, 
          forConversation, 
          spans, 
          baseStyle, 
          colorPalette, 
          spacing,
        );
      }
      
      return spans;
    }
    
    // No code blocks - process line by line for bullet/ordered lists
    _buildBlockquoteLineSpans(
      content, 
      context, 
      alignment, 
      forConversation, 
      spans, 
      baseStyle, 
      colorPalette, 
      spacing,
    );
    
    return spans;
  }
  
  /// Builds spans for blockquote content, processing line by line for bullet/ordered lists.
  void _buildBlockquoteLineSpans(
    String content,
    BuildContext context,
    BubbleAlignment? alignment,
    bool forConversation,
    List<InlineSpan> spans,
    TextStyle baseStyle,
    CometChatColorPalette colorPalette,
    CometChatSpacing spacing,
  ) {
    // Process content line by line to handle bullet and ordered lists
    final lines = content.split('\n');
    
    // Track ordered list numbering - reset when a non-list line is encountered
    int orderedListNumber = 1;
    
    // Track if we've added any content (to handle trailing empty lines)
    bool hasAddedContent = false;
    
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      String displayLine = line;
      
      // Skip empty lines at the end (trailing empty blockquote lines)
      // But keep empty lines in the middle for proper spacing
      if (line.isEmpty && i == lines.length - 1) {
        continue;
      }
      
      // Check for bullet list: "- item" -> " •  item" (aligned with ordered list)
      if (line.startsWith('- ')) {
        displayLine = ' •  ${line.substring(2)}';
        // Bullet list doesn't reset ordered list counter
      }
      // Check for ordered list: "N. item" -> renumber sequentially
      else if (RegExp(r'^\d+\.\s').hasMatch(line)) {
        // Extract the content after the number prefix
        final match = RegExp(r'^\d+\.\s').firstMatch(line);
        if (match != null) {
          final listContent = line.substring(match.end);
          // Replace with sequential number
          displayLine = '$orderedListNumber. $listContent';
          orderedListNumber++;
        }
      }
      // Non-list line - reset ordered list counter
      else if (line.trim().isNotEmpty) {
        orderedListNumber = 1;
      }
      
      // Add newline before this line if we've already added content
      if (hasAddedContent) {
        spans.add(TextSpan(text: '\n', style: baseStyle));
      }
      
      // Build inline format spans for this line
      _buildBlockquoteInlineSpans(
        displayLine,
        context,
        alignment,
        forConversation,
        spans,
        baseStyle,
        colorPalette,
        spacing,
      );
      
      hasAddedContent = true;
    }
  }
  
  /// Builds inline format spans for a single line of blockquote content.
  void _buildBlockquoteInlineSpans(
    String content,
    BuildContext context,
    BubbleAlignment? alignment,
    bool forConversation,
    List<InlineSpan> spans,
    TextStyle baseStyle,
    CometChatColorPalette colorPalette,
    CometChatSpacing spacing,
  ) {
    // Collect all inline format matches within the content
    final allMatches = <_FormatMatch>[];
    _collectMatches(content, _boldPattern, FormatType.bold, allMatches);
    _collectMatches(content, _italicPattern, FormatType.italic, allMatches);
    _collectMatches(content, _underlinePattern, FormatType.underline, allMatches);
    _collectMatches(content, _strikethroughPattern, FormatType.strikethrough, allMatches);
    _collectMatches(content, _inlineCodePattern, FormatType.inlineCode, allMatches);
    _collectMatches(content, _linkPattern, FormatType.link, allMatches);
    
    // Collect mention matches
    final mentionPattern = RegExp(RegexConstants.mentionRegexPattern);
    final mentionedUsers = message?.mentionedUsers ?? [];
    for (final match in mentionPattern.allMatches(content)) {
      final mentionType = match.group(1) ?? '';
      final mentionId = match.group(2) ?? '';
      
      String displayText;
      if (mentionType == 'all') {
        displayText = '@all';
      } else {
        // Find user by uid
        final userIndex = mentionedUsers.indexWhere((u) => u.uid == mentionId);
        if (userIndex != -1) {
          displayText = '@${mentionedUsers[userIndex].name}';
        } else {
          // User not found in mentionedUsers - try to extract a reasonable display
          // This can happen if the message was sent but mentionedUsers wasn't populated
          displayText = '@$mentionId'; // Show @userId as fallback
        }
      }
      
      allMatches.add(_FormatMatch(
        start: match.start,
        end: match.end,
        content: displayText,
        isMention: true,
        url: mentionType == 'all' ? 'all:$mentionId' : 'uid:$mentionId',
      ));
    }
    
    if (allMatches.isEmpty) {
      // No formatting - return single span with base style
      spans.add(TextSpan(text: content, style: baseStyle));
      return;
    }
    
    // Sort by start position, then by length (longer matches first)
    allMatches.sort((a, b) {
      final startCompare = a.start.compareTo(b.start);
      if (startCompare != 0) return startCompare;
      return b.end.compareTo(a.end);
    });
    
    // Filter to keep only non-overlapping matches
    final filteredMatches = <_FormatMatch>[];
    int lastEnd = 0;
    for (final match in allMatches) {
      if (match.start >= lastEnd) {
        filteredMatches.add(match);
        lastEnd = match.end;
      }
    }
    
    // Build spans from matches
    int currentPos = 0;
    for (final match in filteredMatches) {
      // Add unstyled text before this match
      if (match.start > currentPos) {
        spans.add(TextSpan(
          text: content.substring(currentPos, match.start),
          style: baseStyle,
        ));
      }
      
      if (match.isMention) {
        // Handle mention styling
        final mentionInfo = match.url?.split(':') ?? [];
        final mentionType = mentionInfo.isNotEmpty ? mentionInfo[0] : '';
        final mentionId = mentionInfo.length > 1 ? mentionInfo[1] : '';
        
        bool isLoggedInUser = false;
        if (mentionType == 'uid') {
          final userIndex = mentionedUsers.indexWhere((u) => u.uid == mentionId);
          isLoggedInUser = userIndex != -1 && mentionedUsers[userIndex].uid == CometChatUIKit.loggedInUser?.uid;
        } else if (mentionType == 'all') {
          isLoggedInUser = true; // Style @all like logged-in user mention
        }
        
        final mentionBgColor = (alignment == BubbleAlignment.right
            ? (isLoggedInUser ? colorPalette.warning : colorPalette.white)
            : (isLoggedInUser ? colorPalette.warning : colorPalette.primary))
            ?.withValues(alpha: 0.2) ?? Colors.transparent;
        
        // Use WidgetSpan for mention to apply background color with padding
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: spacing.padding ?? 0),
            decoration: BoxDecoration(
              color: mentionBgColor,
              borderRadius: BorderRadius.circular(spacing.radius ?? 0),
            ),
            child: Text(
              match.content,
              style: baseStyle.copyWith(
                color: isLoggedInUser
                    ? (alignment == BubbleAlignment.right ? colorPalette.white : colorPalette.warning)
                    : (alignment == BubbleAlignment.right ? colorPalette.white : colorPalette.primary),
              ),
            ),
          ),
        ));
        currentPos = match.end;
        continue;
      }
      
      // Parse nested formats and get combined style
      final nestedResult = _parseNestedFormats(
        match.content,
        context,
        alignment,
        forConversation,
        {if (match.formatType != null) match.formatType!},
      );
      
      // Add styled text for this match
      spans.add(TextSpan(
        text: nestedResult.plainText,
        style: nestedResult.style,
      ));
      
      currentPos = match.end;
    }
    
    // Add remaining unstyled text
    if (currentPos < content.length) {
      spans.add(TextSpan(
        text: content.substring(currentPos),
        style: baseStyle,
      ));
    }
  }
  
  /// Returns the base text style for blockquote content.
  TextStyle _getBlockquoteBaseStyle(BuildContext context, BubbleAlignment? alignment) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);
    
    return TextStyle(
      color: alignment == BubbleAlignment.right
          ? colorPalette.white
          : colorPalette.textPrimary,
      fontSize: typography.body?.regular?.fontSize,
      fontFamily: typography.body?.regular?.fontFamily,
    );
  }

  /// Result of parsing nested formats.
  /// Contains the plain text (with all markers stripped) and the combined style.
  _NestedFormatResult _parseNestedFormats(
    String text,
    BuildContext context,
    BubbleAlignment? alignment,
    bool forConversation,
    Set<FormatType> activeFormats,
  ) {
    String currentText = text;
    Set<FormatType> formats = Set.from(activeFormats);
    
    // Keep parsing until no more format markers are found
    bool foundFormat = true;
    while (foundFormat) {
      foundFormat = false;
      
      // Check for bold
      final boldMatch = _boldPattern.firstMatch(currentText);
      if (boldMatch != null && boldMatch.start == 0 && boldMatch.end == currentText.length) {
        formats.add(FormatType.bold);
        currentText = boldMatch.group(1) ?? currentText;
        foundFormat = true;
        continue;
      }
      
      // Check for italic
      final italicMatch = _italicPattern.firstMatch(currentText);
      if (italicMatch != null && italicMatch.start == 0 && italicMatch.end == currentText.length) {
        formats.add(FormatType.italic);
        currentText = italicMatch.group(1) ?? currentText;
        foundFormat = true;
        continue;
      }
      
      // Check for underline
      final underlineMatch = _underlinePattern.firstMatch(currentText);
      if (underlineMatch != null && underlineMatch.start == 0 && underlineMatch.end == currentText.length) {
        formats.add(FormatType.underline);
        currentText = underlineMatch.group(1) ?? currentText;
        foundFormat = true;
        continue;
      }
      
      // Check for strikethrough
      final strikethroughMatch = _strikethroughPattern.firstMatch(currentText);
      if (strikethroughMatch != null && strikethroughMatch.start == 0 && strikethroughMatch.end == currentText.length) {
        formats.add(FormatType.strikethrough);
        currentText = strikethroughMatch.group(1) ?? currentText;
        foundFormat = true;
        continue;
      }
      
      // Check for inline code
      final inlineCodeMatch = _inlineCodePattern.firstMatch(currentText);
      if (inlineCodeMatch != null && inlineCodeMatch.start == 0 && inlineCodeMatch.end == currentText.length) {
        formats.add(FormatType.inlineCode);
        currentText = inlineCodeMatch.group(1) ?? currentText;
        foundFormat = true;
        continue;
      }
    }
    
    // Build combined style from all detected formats
    final combinedStyle = _getCombinedStyleForFormats(formats, context, alignment, forConversation);
    
    return _NestedFormatResult(plainText: currentText, style: combinedStyle);
  }
  
  /// Returns a combined text style for multiple format types.
  TextStyle _getCombinedStyleForFormats(
    Set<FormatType> formats,
    BuildContext context,
    BubbleAlignment? alignment,
    bool forConversation,
  ) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);
    
    final baseColor = alignment == BubbleAlignment.right
        ? colorPalette.white
        : colorPalette.textPrimary;
    
    TextStyle result = TextStyle(
      color: baseColor,
      fontSize: typography.body?.regular?.fontSize,
      fontFamily: typography.body?.regular?.fontFamily,
    );
    
    // Collect decorations to combine them properly
    List<TextDecoration> decorations = [];
    
    // Apply each format to the style
    for (final format in formats) {
      switch (format) {
        case FormatType.bold:
          result = result.copyWith(fontWeight: FontWeight.bold);
          break;
        case FormatType.italic:
          result = result.copyWith(fontStyle: FontStyle.italic);
          break;
        case FormatType.underline:
          decorations.add(TextDecoration.underline);
          break;
        case FormatType.strikethrough:
          decorations.add(TextDecoration.lineThrough);
          break;
        case FormatType.inlineCode:
          final inlineCodeColor = alignment == BubbleAlignment.right
              ? colorPalette.white
              : colorPalette.primary;
          result = result.copyWith(
            fontFamily: 'monospace',
            color: style?.inlineCodeTextStyle?.color ?? inlineCodeColor,
            backgroundColor: style?.inlineCodeBackgroundColor ?? 
                (alignment == BubbleAlignment.right 
                    ? colorPalette.white?.withValues(alpha: 0.2)
                    : colorPalette.background3),
          );
          break;
        case FormatType.codeBlock:
          // Code block uses container background via AttributedText.backgroundColor
          // so we only set the font family here
          result = result.copyWith(
            fontFamily: 'monospace',
          );
          break;
        case FormatType.link:
          final linkColor = alignment == BubbleAlignment.right
              ? colorPalette.white
              : (style?.linkColor ?? colorPalette.primary);
          decorations.add(TextDecoration.underline);
          result = result.copyWith(color: linkColor);
          break;
        case FormatType.blockquote:
          // Blockquote text keeps normal style - visual indicator is the │ prefix
          break;
        default:
          // Other formats don't affect inline text style
          break;
      }
    }
    
    // Apply combined decorations with matching decoration color
    if (decorations.isNotEmpty) {
      result = result.copyWith(
        decoration: TextDecoration.combine(decorations),
        decorationColor: result.color,
      );
    }
    
    return result;
  }

  /// Detects which formats are active at the given cursor position.
  ///
  /// This is a convenience method that delegates to [RichTextFormatterManager].
  Set<FormatType> detectActiveFormats(String text, int cursorPosition) {
    return RichTextFormatterManager.detectActiveFormats(text, cursorPosition);
  }

  /// Applies a format to the selected text.
  ///
  /// This is a convenience method that delegates to [RichTextFormatterManager].
  FormattedResult applyFormat({
    required String text,
    required int selectionStart,
    required int selectionEnd,
    required FormatType formatType,
  }) {
    return RichTextFormatterManager.applyFormat(
      text: text,
      selectionStart: selectionStart,
      selectionEnd: selectionEnd,
      formatType: formatType,
    );
  }

  /// Toggles a format on the selected text.
  ///
  /// This is a convenience method that delegates to [RichTextFormatterManager].
  FormattedResult toggleFormat({
    required String text,
    required int selectionStart,
    required int selectionEnd,
    required FormatType formatType,
  }) {
    return RichTextFormatterManager.toggleFormat(
      text: text,
      selectionStart: selectionStart,
      selectionEnd: selectionEnd,
      formatType: formatType,
    );
  }

  /// Removes a format from the selected text.
  ///
  /// This is a convenience method that delegates to [RichTextFormatterManager].
  FormattedResult removeFormat({
    required String text,
    required int selectionStart,
    required int selectionEnd,
    required FormatType formatType,
  }) {
    return RichTextFormatterManager.removeFormat(
      text: text,
      selectionStart: selectionStart,
      selectionEnd: selectionEnd,
      formatType: formatType,
    );
  }

  /// Checks if the text at the given position has the specified format.
  ///
  /// This is a convenience method that delegates to [RichTextFormatterManager].
  bool hasFormat({
    required String text,
    required FormatType formatType,
    required int position,
  }) {
    return RichTextFormatterManager.hasFormat(
      text: text,
      formatType: formatType,
      position: position,
    );
  }

  /// Strips all markdown formatting from the text and returns plain text.
  ///
  /// This is useful for displaying preview text in conversation lists
  /// where formatting should not be visible.
  /// Delegates to [FormatPatterns.stripFormatting] for centralized logic.
  static String stripFormatting(String text) {
    return FormatPatterns.stripFormatting(text);
  }

  /// Checks if the given text contains any rich text formatting.
  static bool containsFormatting(String text) {
    return _combinedPattern.hasMatch(text);
  }
}
