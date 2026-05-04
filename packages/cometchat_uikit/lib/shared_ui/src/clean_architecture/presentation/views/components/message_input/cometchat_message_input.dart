import 'package:flutter/material.dart';
import "../../../../clean_architecture.dart";

///[CometChatMessageInput] is a component that provides a skeleton layout for contents of [CometChatMessageComposer] like TextField, auxiliary options, primary button view and attachment options.
///
/// The default layout is a single-row inline layout:
/// ```
/// ┌─────────────────────────────────────────────────────────────┐
/// │ [+] │ Type your message...          │ [😊] [🎤] [✨] │ [➤] │
/// └─────────────────────────────────────────────────────────────┘
///   Sec    Text Input                      Auxiliary      Send
/// ```
///
/// ```dart
///   CometChatMessageInput(
///    placeholderText: "some placeholder",
///    primaryButtonView: Container(),
///    secondaryButtonView: GestureDetector(
///      onTap: () {},
///      child: Container(),
///    ),
///    auxiliaryButtonView: Row(
///      children: <Widget>[],
///    ),
///    auxiliaryButtonsAlignment: AuxiliaryButtonsAlignment.right,
///  );
/// ```
class CometChatMessageInput extends StatefulWidget {
  const CometChatMessageInput(
      {super.key,
      this.text,
      this.placeholderText,
      this.onChange,
      this.style,
      this.maxLine,
      this.secondaryButtonView,
      this.auxiliaryButtonView,
      this.primaryButtonView,
      this.auxiliaryButtonsAlignment = AuxiliaryButtonsAlignment.right,
      this.textEditingController,
      this.focusNode,
      this.hideBottomView,
      this.padding,
      this.margin,
      this.height,
      this.width,
      this.onEnterPressed,
      this.showCodeBlockIndicator = false,
      this.codeBlockIndicatorColor,
      this.codeBlockContent,
      this.onContentInserted});

  ///[text] initial text for the input field
  final String? text;

  ///[placeholderText] hint text for input field
  final String? placeholderText;

  ///[onChange] callback to handle change in value of text in the input field
  final Function(String val)? onChange;

  ///[style] provides style to this widget
  final CometChatMessageInputStyle? style;

  ///[maxLine] maximum lines allowed to increase in the input field
  final int? maxLine;

  ///[secondaryButtonView] additional ui component apart from primary
  final Widget? secondaryButtonView;

  ///[auxiliaryButtonView] additional ui component apart from primary and secondary
  final Widget? auxiliaryButtonView;

  ///[primaryButtonView] is a ui component that would trigger basic functionality
  final Widget? primaryButtonView;

  ///[auxiliaryButtonsAlignment] controls position auxiliary button view
  final AuxiliaryButtonsAlignment? auxiliaryButtonsAlignment;

  ///[textEditingController] provides control of the input field
  final TextEditingController? textEditingController;

  ///[focusNode] allows to dismiss platform and CometChat UI elements
  final FocusNode? focusNode;

  ///[hideBottomView] hide the bottom toolbar for message input
  final bool? hideBottomView;

  ///[height] defines the height of the widget
  final double? height;

  ///[width] defines the width of the widget
  final double? width;

  ///[padding] defines the padding of the widget
  final EdgeInsetsGeometry? padding;

  ///[margin] defines the margin of the widget
  final EdgeInsetsGeometry? margin;

  ///[onEnterPressed] callback to handle Enter key press for list continuation
  ///Returns true if the Enter was handled (e.g., for list continuation), false otherwise
  final bool Function(String text, TextSelection selection)? onEnterPressed;

  ///[showCodeBlockIndicator] shows a Slack-style left accent bar when true
  ///Used to indicate code block formatting in the input
  final bool showCodeBlockIndicator;

  ///[codeBlockIndicatorColor] color for the code block indicator bar
  final Color? codeBlockIndicatorColor;

  ///[codeBlockContent] the extracted code content without backticks
  ///When provided, displays this instead of raw text with backticks
  final String? codeBlockContent;

  ///[onContentInserted] callback when keyboard inserts media content (e.g. GIF)
  final ValueChanged<KeyboardInsertedContent>? onContentInserted;

  @override
  State<CometChatMessageInput> createState() => _CometChatMessageInputState();
}

class _CometChatMessageInputState extends State<CometChatMessageInput> {
  TextEditingController? _textEditingController;
  bool _isOwnController = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    if (widget.textEditingController != null) {
      _textEditingController = widget.textEditingController;
      _isOwnController = false;
    } else {
      _textEditingController = TextEditingController(text: widget.text);
      _isOwnController = true;
    }
  }

  @override
  void dispose() {
    if (_isOwnController) {
      _textEditingController?.dispose();
    }
    _textEditingController = null;
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CometChatMessageInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle controller change
    if (widget.textEditingController != oldWidget.textEditingController) {
      if (_isOwnController) {
        _textEditingController?.dispose();
      }
      _initController();
    } else if (widget.text != oldWidget.text && widget.text != null && _textEditingController != null) {
      // Only update text if controller hasn't changed
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _textEditingController != null) {
          _textEditingController!.text = widget.text ?? '';
          _textEditingController!.selection =
              TextSelection.collapsed(offset: _textEditingController!.text.length);
        }
      });
    }
    
    // Update style if changed
    if (widget.style != oldWidget.style && widget.style != null) {
      messageInputStyle =
          CometChatThemeHelper.getTheme<CometChatMessageInputStyle>(
                  context: context, defaultTheme: CometChatMessageInputStyle.of)
              .merge(widget.style);
    }
  }

  late CometChatMessageInputStyle messageInputStyle;
  late CometChatColorPalette colorPalette;
  late CometChatSpacing spacing;
  late CometChatTypography typography;
  bool _themeInitialized = false;
  Brightness? _cachedBrightness;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only initialize theme once to avoid expensive lookups during keyboard animation
    // But re-initialize when brightness changes (dark mode toggle)
    final currentBrightness = MediaQuery.platformBrightnessOf(context);
    final brightnessChanged = _cachedBrightness != null && _cachedBrightness != currentBrightness;
    if (_themeInitialized && !brightnessChanged) return;
    _cachedBrightness = currentBrightness;
    _themeInitialized = true;
    
    messageInputStyle =
        CometChatThemeHelper.getTheme<CometChatMessageInputStyle>(
                context: context, defaultTheme: CometChatMessageInputStyle.of)
            .merge(widget.style);
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);
    typography = CometChatThemeHelper.getTypography(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      margin: widget.margin,
      padding: widget.padding ?? const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: messageInputStyle.backgroundColor,
        border: messageInputStyle.border,
        borderRadius: messageInputStyle.borderRadius ??
            BorderRadius.circular(spacing.radius2 ?? 0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Secondary buttons (left side - attachment button)
          if (widget.secondaryButtonView != null)
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 17),
              child: widget.secondaryButtonView!,
            ),

          // Auxiliary buttons (left alignment option)
          if (widget.auxiliaryButtonsAlignment == AuxiliaryButtonsAlignment.left &&
              widget.auxiliaryButtonView != null &&
              widget.hideBottomView != true)
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 17),
              child: widget.auxiliaryButtonView!,
            ),

          // Text input (center, expanded)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: spacing.padding2 ?? 8,
                right: spacing.padding2 ?? 8,
                top: 12,
                bottom: 12,
              ),
              child: _textEditingController != null
                  ? _buildRegularInput()
                  : const SizedBox.shrink(),
            ),
          ),

          // Auxiliary buttons (right alignment - default)
          if (widget.auxiliaryButtonsAlignment == AuxiliaryButtonsAlignment.right &&
              widget.auxiliaryButtonView != null &&
              widget.hideBottomView != true)
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 17),
              child: widget.auxiliaryButtonView!,
            ),

          // Primary/Send button (far right)
          if (widget.primaryButtonView != null && widget.hideBottomView != true)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
              child: widget.primaryButtonView!,
            ),
        ],
      ),
    );
  }

  /// Builds the regular text input field
  Widget _buildRegularInput() {
    // Check if we're in code block mode (WYSIWYG)
    // Show code block visual even when text is empty (codeBlockContent can be null or empty string)
    if (widget.showCodeBlockIndicator) {
      return _buildCodeBlockInput();
    }
    
    // Regular text input
    return TextFormField(
      key: ValueKey(_textEditingController.hashCode),
      textCapitalization: TextCapitalization.sentences,
      keyboardAppearance: CometChatThemeHelper.getBrightness(context),
      cursorColor: colorPalette.primary ?? Colors.blue,
      scrollPhysics: const ClampingScrollPhysics(),
      contentInsertionConfiguration: widget.onContentInserted != null
          ? ContentInsertionConfiguration(
              allowedMimeTypes: const ['image/gif', 'image/png', 'image/jpeg', 'image/webp'],
              onContentInserted: widget.onContentInserted!,
            )
          : null,
      style: TextStyle(
        color: colorPalette.textPrimary,
        fontSize: typography.body?.regular?.fontSize,
        fontWeight: typography.body?.regular?.fontWeight,
        fontFamily: typography.body?.regular?.fontFamily,
      )
          .merge(messageInputStyle.textStyle)
          .copyWith(color: messageInputStyle.textColor),
      onChanged: widget.onChange,
      controller: _textEditingController,
      minLines: 1,
      maxLines: widget.maxLine ?? 4,
      decoration: InputDecoration(
        filled: messageInputStyle.filledColor != null,
        fillColor: messageInputStyle.filledColor,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          vertical: spacing.padding1 ?? 4,
        ),
        hintText: widget.placeholderText ?? Translations.of(context).typeYourMessage,
        hintStyle: TextStyle(
          color: colorPalette.textTertiary,
          fontSize: typography.body?.regular?.fontSize,
          fontWeight: typography.body?.regular?.fontWeight,
          fontFamily: typography.body?.regular?.fontFamily,
        )
            .merge(messageInputStyle.placeholderTextStyle)
            .copyWith(color: messageInputStyle.placeholderColor),
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
      ),
      focusNode: widget.focusNode,
    );
  }
  
  /// Builds the code block styled input field
  /// Shows a dark container with monospace font, scrollable for long content
  Widget _buildCodeBlockInput() {
    // Use theme colors for code block
    final codeBackgroundColor = colorPalette.background3 ?? const Color(0xFF1E1E1E);
    final borderColor = colorPalette.borderDark ?? const Color(0xFF404040);
    final textColor = colorPalette.textPrimary ?? Colors.white;
    final hintColor = colorPalette.textTertiary ?? Colors.grey;

    return Container(
      constraints: BoxConstraints(
        maxHeight: 200, // Max height before scrolling
      ),
      decoration: BoxDecoration(
        color: codeBackgroundColor,
        borderRadius: BorderRadius.circular(spacing.radius2 ?? 8),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.padding3 ?? 12),
        child: TextFormField(
          key: ValueKey('codeblock_${_textEditingController.hashCode}'),
          textCapitalization: TextCapitalization.none,
          keyboardAppearance: CometChatThemeHelper.getBrightness(context),
          style: TextStyle(
            color: textColor,
            fontSize: typography.body?.regular?.fontSize ?? 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'monospace',
            height: 1.5,
          ),
          onChanged: widget.onChange,
          controller: _textEditingController,
          minLines: 1,
          maxLines: null, // Allow unlimited lines, container handles scrolling
          decoration: InputDecoration(
            filled: false,
            isDense: true,
            contentPadding: EdgeInsets.zero,
            hintText: widget.placeholderText ?? 'Enter code...',
            hintStyle: TextStyle(
              color: hintColor,
              fontSize: typography.body?.regular?.fontSize ?? 14,
              fontWeight: FontWeight.w400,
              fontFamily: 'monospace',
            ),
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
          ),
          focusNode: widget.focusNode,
        ),
      ),
    );
  }
}
