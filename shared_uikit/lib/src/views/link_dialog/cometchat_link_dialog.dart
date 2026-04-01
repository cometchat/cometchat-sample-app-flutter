import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

/// Result returned from the link dialog containing the text and URL.
class LinkDialogResult {
  /// The display text for the link (optional).
  final String? text;

  /// The URL for the link (required).
  final String url;

  LinkDialogResult({this.text, required this.url});
}

/// A dialog for inserting links with optional display text.
///
/// Shows two text fields:
/// - Text (optional): The display text for the link
/// - Link (required): The URL
///
/// If text is provided, the link will be displayed as [text](url).
/// If only URL is provided, the link will be displayed as the URL itself.
class CometChatLinkDialog {
  /// Creates an instance of [CometChatLinkDialog].
  CometChatLinkDialog({
    required this.context,
    this.onDone,
    this.onCancel,
    this.initialText,
    this.initialUrl,
    this.isEditing = false,
    this.style,
  });

  /// The current [BuildContext] in which the dialog is shown.
  final BuildContext context;

  /// Callback function invoked when the Done button is pressed.
  final void Function(LinkDialogResult result)? onDone;

  /// Callback function invoked when the Cancel button is pressed.
  final VoidCallback? onCancel;

  /// Initial text to populate the text field.
  final String? initialText;

  /// Initial URL to populate the link field.
  final String? initialUrl;

  /// Whether this dialog is for editing an existing link.
  /// When true, the title will show "Edit Link" instead of "Add Link".
  final bool isEditing;

  /// Style configuration for the dialog.
  final CometChatLinkDialogStyle? style;

  /// Shows the dialog.
  void show() {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final spacing = CometChatThemeHelper.getSpacing(context);
    final typography = CometChatThemeHelper.getTypography(context);

    final linkDialogStyle = style ?? const CometChatLinkDialogStyle();

    final textController = TextEditingController(text: initialText);
    final urlController = TextEditingController(text: initialUrl);

    showDialog(
      context: context,
      barrierColor: linkDialogStyle.shadow ?? Colors.black54,
      builder: (BuildContext dialogContext) {
        return _LinkDialogContent(
          colorPalette: colorPalette,
          spacing: spacing,
          typography: typography,
          style: linkDialogStyle,
          textController: textController,
          urlController: urlController,
          isEditing: isEditing,
          onDone: onDone,
          onCancel: onCancel,
        );
      },
    );
  }
}

class _LinkDialogContent extends StatefulWidget {
  const _LinkDialogContent({
    required this.colorPalette,
    required this.spacing,
    required this.typography,
    required this.style,
    required this.textController,
    required this.urlController,
    this.isEditing = false,
    this.onDone,
    this.onCancel,
  });

  final CometChatColorPalette colorPalette;
  final CometChatSpacing spacing;
  final CometChatTypography typography;
  final CometChatLinkDialogStyle style;
  final TextEditingController textController;
  final TextEditingController urlController;
  final bool isEditing;
  final void Function(LinkDialogResult result)? onDone;
  final VoidCallback? onCancel;

  @override
  State<_LinkDialogContent> createState() => _LinkDialogContentState();
}

class _LinkDialogContentState extends State<_LinkDialogContent> {
  bool _isUrlValid = false;

  @override
  void initState() {
    super.initState();
    _isUrlValid = widget.urlController.text.trim().isNotEmpty;
    widget.urlController.addListener(_onUrlChanged);
  }

  @override
  void dispose() {
    widget.urlController.removeListener(_onUrlChanged);
    super.dispose();
  }

  void _onUrlChanged() {
    final isValid = widget.urlController.text.trim().isNotEmpty;
    if (isValid != _isUrlValid) {
      setState(() {
        _isUrlValid = isValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorPalette = widget.colorPalette;
    final spacing = widget.spacing;
    final typography = widget.typography;
    final style = widget.style;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        side: style.border ??
            BorderSide(
              color: colorPalette.borderLight ?? Colors.transparent,
              width: 1,
            ),
        borderRadius: style.borderRadius ??
            BorderRadius.all(
              Radius.circular(spacing.radius4 ?? 16),
            ),
      ),
      backgroundColor: style.backgroundColor ?? colorPalette.background1,
      insetPadding: EdgeInsets.symmetric(
        horizontal: spacing.margin4 ?? 16,
        vertical: spacing.margin4 ?? 16,
      ),
      titlePadding: EdgeInsets.only(
        left: spacing.padding5 ?? 20,
        right: spacing.padding5 ?? 20,
        top: spacing.padding5 ?? 20,
        bottom: spacing.padding3 ?? 12,
      ),
      contentPadding: EdgeInsets.only(
        left: spacing.padding5 ?? 20,
        right: spacing.padding5 ?? 20,
        bottom: spacing.padding3 ?? 12,
      ),
      actionsPadding: EdgeInsets.only(
        left: spacing.padding5 ?? 20,
        right: spacing.padding5 ?? 20,
        bottom: spacing.padding5 ?? 20,
      ),
      title: Text(
        widget.isEditing ? 'Edit Link' : 'Add Link',
        style: TextStyle(
          fontSize: typography.heading3?.medium?.fontSize,
          fontWeight: typography.heading3?.medium?.fontWeight,
          fontFamily: typography.heading3?.medium?.fontFamily,
          color: style.titleTextColor ?? colorPalette.textPrimary,
        ).merge(style.titleTextStyle),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text field
          Text(
            'Text',
            style: TextStyle(
              fontSize: typography.caption1?.medium?.fontSize,
              fontWeight: typography.caption1?.medium?.fontWeight,
              fontFamily: typography.caption1?.medium?.fontFamily,
              color: style.labelTextColor ?? colorPalette.textSecondary,
            ).merge(style.labelTextStyle),
          ),
          SizedBox(height: spacing.padding1 ?? 4),
          TextField(
            controller: widget.textController,
            decoration: InputDecoration(
              hintText: 'Enter display text',
              hintStyle: TextStyle(
                fontSize: typography.body?.regular?.fontSize,
                fontWeight: typography.body?.regular?.fontWeight,
                fontFamily: typography.body?.regular?.fontFamily,
                color: style.hintTextColor ?? colorPalette.textTertiary,
              ).merge(style.hintTextStyle),
              filled: true,
              fillColor: style.inputBackgroundColor ?? colorPalette.background2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(spacing.radius2 ?? 8),
                borderSide: BorderSide(
                  color: colorPalette.borderLight ?? Colors.transparent,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(spacing.radius2 ?? 8),
                borderSide: BorderSide(
                  color: colorPalette.borderLight ?? Colors.transparent,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(spacing.radius2 ?? 8),
                borderSide: BorderSide(
                  color: colorPalette.primary ?? Colors.blue,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: spacing.padding3 ?? 12,
                vertical: spacing.padding2 ?? 8,
              ),
            ),
            style: TextStyle(
              fontSize: typography.body?.regular?.fontSize,
              fontWeight: typography.body?.regular?.fontWeight,
              fontFamily: typography.body?.regular?.fontFamily,
              color: style.inputTextColor ?? colorPalette.textPrimary,
            ).merge(style.inputTextStyle),
          ),
          SizedBox(height: spacing.padding4 ?? 16),
          // Link field (required)
          Text(
            'Link',
            style: TextStyle(
              fontSize: typography.caption1?.medium?.fontSize,
              fontWeight: typography.caption1?.medium?.fontWeight,
              fontFamily: typography.caption1?.medium?.fontFamily,
              color: style.labelTextColor ?? colorPalette.textSecondary,
            ).merge(style.labelTextStyle),
          ),
          SizedBox(height: spacing.padding1 ?? 4),
          TextField(
            controller: widget.urlController,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              hintText: 'Enter URL',
              hintStyle: TextStyle(
                fontSize: typography.body?.regular?.fontSize,
                fontWeight: typography.body?.regular?.fontWeight,
                fontFamily: typography.body?.regular?.fontFamily,
                color: style.hintTextColor ?? colorPalette.textTertiary,
              ).merge(style.hintTextStyle),
              filled: true,
              fillColor: style.inputBackgroundColor ?? colorPalette.background2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(spacing.radius2 ?? 8),
                borderSide: BorderSide(
                  color: colorPalette.borderLight ?? Colors.transparent,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(spacing.radius2 ?? 8),
                borderSide: BorderSide(
                  color: colorPalette.borderLight ?? Colors.transparent,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(spacing.radius2 ?? 8),
                borderSide: BorderSide(
                  color: colorPalette.primary ?? Colors.blue,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: spacing.padding3 ?? 12,
                vertical: spacing.padding2 ?? 8,
              ),
            ),
            style: TextStyle(
              fontSize: typography.body?.regular?.fontSize,
              fontWeight: typography.body?.regular?.fontWeight,
              fontFamily: typography.body?.regular?.fontFamily,
              color: style.inputTextColor ?? colorPalette.textPrimary,
            ).merge(style.inputTextStyle),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Row(
          children: [
            // Cancel button
            Expanded(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onCancel?.call();
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    style.cancelButtonBackground ?? Colors.transparent,
                  ),
                  side: WidgetStateProperty.all(
                    BorderSide(
                      color: colorPalette.borderDark ?? Colors.transparent,
                      width: 1,
                    ),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(spacing.radius2 ?? 8),
                    ),
                  ),
                  padding: WidgetStateProperty.all(
                    EdgeInsets.symmetric(
                      horizontal: spacing.padding4 ?? 16,
                      vertical: spacing.padding2 ?? 8,
                    ),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: typography.button?.medium?.fontSize,
                    fontWeight: typography.button?.medium?.fontWeight,
                    fontFamily: typography.button?.medium?.fontFamily,
                    color: style.cancelButtonTextColor ?? colorPalette.textPrimary,
                  ).merge(style.cancelButtonTextStyle),
                ),
              ),
            ),
            SizedBox(width: spacing.padding2 ?? 8),
            // Save button
            Expanded(
              child: TextButton(
                onPressed: _isUrlValid
                    ? () {
                        final text = widget.textController.text.trim();
                        final url = widget.urlController.text.trim();
                        Navigator.of(context).pop();
                        widget.onDone?.call(LinkDialogResult(
                          text: text.isNotEmpty ? text : null,
                          url: url,
                        ));
                      }
                    : null,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    _isUrlValid
                        ? (style.doneButtonBackground ?? colorPalette.primary)
                        : (style.doneButtonDisabledBackground ??
                            colorPalette.background4),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(spacing.radius2 ?? 8),
                    ),
                  ),
                  padding: WidgetStateProperty.all(
                    EdgeInsets.symmetric(
                      horizontal: spacing.padding4 ?? 16,
                      vertical: spacing.padding2 ?? 8,
                    ),
                  ),
                ),
                child: Text(
                  'Save',
                  style: TextStyle(
                    fontSize: typography.button?.medium?.fontSize,
                    fontWeight: typography.button?.medium?.fontWeight,
                    fontFamily: typography.button?.medium?.fontFamily,
                    color: _isUrlValid
                        ? (style.doneButtonTextColor ?? colorPalette.white)
                        : (style.doneButtonDisabledTextColor ??
                            colorPalette.textTertiary),
                  ).merge(style.doneButtonTextStyle),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
