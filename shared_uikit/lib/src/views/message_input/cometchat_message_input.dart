import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

///[CometChatMessageInput] is a component that provides a skeleton layout for contents of [CometChatMessageComposer] like TextField, auxiliary options, primary button view and attachment options.
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
      this.width});

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

  @override
  State<CometChatMessageInput> createState() => _CometChatMessageInputState();
}

class _CometChatMessageInputState extends State<CometChatMessageInput> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    if (widget.textEditingController != null) {
      _textEditingController = widget.textEditingController!;
    } else {
      _textEditingController = TextEditingController(text: widget.text);
    }
  }

  @override
  void dispose() {
    if (widget.textEditingController == null) {
      _textEditingController.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CometChatMessageInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text && widget.text != null) {
      _textEditingController.text = widget.text ?? '';
      _textEditingController.selection =
          TextSelection.collapsed(offset: _textEditingController.text.length);
    }
  }

  late CometChatMessageInputStyle messageInputStyle;
  late CometChatColorPalette colorPalette;
  late CometChatSpacing spacing;
  late CometChatTypography typography;

  @override
  void didChangeDependencies() {
    messageInputStyle =
        CometChatThemeHelper.getTheme<CometChatMessageInputStyle>(
                context: context, defaultTheme: CometChatMessageInputStyle.of)
            .merge(widget.style);
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);
    typography = CometChatThemeHelper.getTypography(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      margin: widget.margin,
      padding: widget.padding,
      decoration: BoxDecoration(
        border: messageInputStyle.border,
        borderRadius: messageInputStyle.borderRadius ??
            BorderRadius.circular(spacing.radius2 ?? 0),
      ),
      child: Column(
        children: [
          Container(
              padding: EdgeInsets.only(
                  left: spacing.padding3 ?? 0, right: spacing.padding3 ?? 0),
              decoration: BoxDecoration(
                color: messageInputStyle.filledColor ?? messageInputStyle.backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(spacing.radius2 ?? 0),
                  topRight: Radius.circular(spacing.radius2 ?? 0),
                ),
              ),
              child: TextFormField(
                textCapitalization: TextCapitalization.sentences,
                keyboardAppearance:
                    CometChatThemeHelper.getBrightness(context),
                style: TextStyle(
                        color: colorPalette.textPrimary,
                        fontSize: typography.body?.regular?.fontSize,
                        fontWeight: typography.body?.regular?.fontWeight,
                        fontFamily: typography.body?.regular?.fontFamily)
                    .merge(messageInputStyle.textStyle)
                    .copyWith(color: messageInputStyle.textColor),
                onChanged: widget.onChange,
                controller: _textEditingController,
                minLines: 1,
                maxLines: widget.maxLine ?? 4,
                decoration: InputDecoration(
                  filled: messageInputStyle.filledColor != null,
                  fillColor: messageInputStyle.filledColor,
                  hintText: widget.placeholderText ??
                      Translations.of(context).typeYourMessage,
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
              )),
          if (widget.hideBottomView != true)
            Divider(
                height: messageInputStyle.dividerHeight ?? 1,
                color: messageInputStyle.dividerTint),
          if (widget.hideBottomView != true)
            Container(
              padding: EdgeInsets.symmetric(horizontal: spacing.padding3 ?? 0, vertical: spacing.padding2 ?? 0),
              decoration: BoxDecoration(
                  color: messageInputStyle.backgroundColor,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(spacing.radius2 ?? 0),
                      bottomRight: Radius.circular(spacing.radius2 ?? 0))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //-----show add to chat bottom sheet-----
                  if (widget.secondaryButtonView != null)
                    widget.secondaryButtonView!,

                  if (widget.auxiliaryButtonsAlignment ==
                          AuxiliaryButtonsAlignment.left &&
                      widget.auxiliaryButtonView != null)
                    widget.auxiliaryButtonView!,

                  const Spacer(),

                  //-----show auxiliary buttons -----
                  if (widget.auxiliaryButtonsAlignment ==
                          AuxiliaryButtonsAlignment.right &&
                      widget.auxiliaryButtonView != null)
                    widget.auxiliaryButtonView!,

                  //  -----show send button-----
                  if (widget.primaryButtonView != null)
                    widget.primaryButtonView!,
                ],
              ),
            )
        ],
      ),
    );
  }
}
