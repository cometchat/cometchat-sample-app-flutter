import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

/// The one-line message preview used by list surfaces that show messages out
/// of their conversation — search results and saved messages.
///
/// Handles every case the search row handles, in one place so the two
/// surfaces cannot drift apart:
///
/// * **Text** — rendered as rich text (markdown, links, phone/email, and
///   `<@uid:..>` mention tags resolved to display names), never raw markup.
/// * **Media** (image/video/file/audio) — a `Sender:` prefix, a type glyph,
///   and the attachment's preview label (file name / count).
/// * **Card** — the card's text, falling back to the localized label.
/// * **Thread replies** — prefixed with the ↳ glyph.
///
/// Callers may override any computed piece ([prefix], [icon], [text],
/// [richTextMessage]); anything left null is derived from [message].
class MessagePreviewSubtitle extends StatelessWidget {
  const MessagePreviewSubtitle({
    super.key,
    required this.message,
    required this.textStyle,
    this.iconColor,
    this.spacing,
    this.showThreadIndicator = true,
    this.showSenderPrefix = true,
    this.prefixAllTypes = false,
    this.prefix,
    this.icon,
    this.text,
    this.richTextMessage,
  });

  /// The message being previewed.
  final BaseMessage message;

  /// Style for the preview text (and the prefix).
  final TextStyle textStyle;

  /// Colour for the type glyph and the thread arrow.
  final Color? iconColor;

  /// Gap between the glyphs and the text. Defaults to 2.
  final double? spacing;

  /// Whether a thread reply shows the ↳ glyph.
  final bool showThreadIndicator;

  /// Whether media previews carry the `Sender:` prefix.
  final bool showSenderPrefix;

  /// Extends the prefix to every message type, text included, instead of
  /// media only. Group listings want "John: hello"; a 1-1 row is already
  /// titled by the counterpart, so callers gate this on the receiver type.
  final bool prefixAllTypes;

  /// Explicit overrides — null means "derive from [message]".
  final String? prefix;
  final IconData? icon;
  final String? text;
  final TextMessage? richTextMessage;

  /// "You:" for own messages, otherwise the sender's first name.
  static String senderPrefixFor(BaseMessage message, BuildContext context) {
    final sender = message.sender;
    if (sender == null) return '';
    final loggedInUid = CometChatUIKit.loggedInUser?.uid;
    if (loggedInUid != null && sender.uid == loggedInUid) {
      return '${Translations.of(context).you}:';
    }
    final name = sender.name.trim();
    if (name.isEmpty) return '';
    return '${name.split(' ').first}:';
  }

  /// Type glyph for a media message, or null for text/card.
  static IconData? _iconFor(BaseMessage message) {
    switch (message.type) {
      case MessageTypeConstants.image:
        return Icons.image_outlined;
      case MessageTypeConstants.video:
        return Icons.videocam_outlined;
      case MessageTypeConstants.file:
        return Icons.description_outlined;
      case MessageTypeConstants.audio:
        return Icons.audiotrack_outlined;
      default:
        return null;
    }
  }

  /// Plain preview text for non-rich message types.
  static String _textFor(BaseMessage message, BuildContext context) {
    if (message is MediaMessage) {
      return AttachmentUtils.previewSubtitleFor(message, context);
    }
    if (message.type == MessageTypeConstants.card) {
      final cardText = (message as CardMessage?)?.getText();
      return cardText?.isNotEmpty == true
          ? cardText!
          : Translations.of(context).cardMessage;
    }
    if (message is TextMessage) return message.text;
    return message.type;
  }

  /// Rich-text span for a text message: markdown + the default formatters,
  /// with the mentions formatter bound to the message so `<@uid:..>` tags
  /// resolve to display names.
  Widget _richText(TextMessage message, BuildContext context) {
    final formatters = <CometChatTextFormatter>[
      MarkdownTextFormatter(),
      ...MessageTemplateUtils.getDefaultTextFormatters(),
    ];
    for (final formatter in formatters) {
      if (formatter is CometChatMentionsFormatter) formatter.message = message;
    }
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: FormatterUtils.buildTextSpan(
          message.text,
          formatters,
          context,
          BubbleAlignment.left,
          forConversation: true,
          textStyle: textStyle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gap = spacing ?? 2;
    final glyphColor =
        iconColor ??
        CometChatThemeHelper.getColorPalette(context).iconSecondary;

    final rich =
        richTextMessage ??
        (message is TextMessage ? message as TextMessage : null);
    final effectivePrefix =
        prefix ??
        (showSenderPrefix &&
                (prefixAllTypes || (rich == null && _iconFor(message) != null))
            ? senderPrefixFor(message, context)
            : '');
    final effectiveIcon = icon ?? _iconFor(message);

    return Row(
      children: [
        if (showThreadIndicator && message.parentMessageId > 0)
          Padding(
            padding: EdgeInsets.only(right: gap),
            child: Icon(
              Icons.subdirectory_arrow_right,
              size: 16,
              color: glyphColor,
            ),
          ),
        if (effectivePrefix.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(right: gap),
            child: Text(effectivePrefix, style: textStyle),
          ),
        if (effectiveIcon != null)
          Padding(
            padding: EdgeInsets.only(right: gap),
            child: Icon(effectiveIcon, size: 16, color: glyphColor),
          ),
        Expanded(
          child: rich != null
              ? _richText(rich, context)
              : Text(
                  text ?? _textFor(message, context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle,
                ),
        ),
      ],
    );
  }
}
