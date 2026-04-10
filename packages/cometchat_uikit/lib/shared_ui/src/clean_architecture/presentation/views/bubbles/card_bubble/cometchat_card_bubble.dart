import "../../../../clean_architecture.dart";
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'card_bubble_bloc.dart';

///[CometChatCardBubble] creates the card view for [InteractiveMessage] with type [MessageTypeConstants.card] by default
///
///used by default  when the category and type of [MediaMessage] is message and [MessageTypeConstants.image] respectively
/// ```dart
///             CometChatCardBubble(
///                  theme: cometChatTheme,
///                  imageUrl:
///                      'image url',
///                  style: const CardBubbleStyle(
///                    borderRadius: 8,
///                  ),
///                );
/// ```
class CometChatCardBubble extends StatefulWidget {
  const CometChatCardBubble(
      {super.key,
      this.cardBubbleStyle,
      required this.cardMessage,
      this.onActionTap,
      this.loggedInUser});

  ///[cardBubbleStyle] sets the style for the card
  final CardBubbleStyle? cardBubbleStyle;

  ///[cardMessage] sets the message object for the card
  final CardMessage cardMessage;

  ///[onActionTap] overrides the on tap functionality
  final Function(BaseInteractiveElement interactiveElement)? onActionTap;

  ///[loggedInUser] pass logged in user to bubble
  final User? loggedInUser;

  @override
  State<CometChatCardBubble> createState() => _CometChatCardState();
}

class _CometChatCardState extends State<CometChatCardBubble> {
  late CardBubbleBloc _cardBubbleBloc;
  late ButtonElementStyle defaultButtonStyle;
  
  // Cached values to avoid MediaQuery in build()
  double _cachedMaxWidth = 300;
  bool _themeInitialized = false;
  Brightness? _cachedBrightness;

  @override
  void initState() {
    super.initState();
    _cardBubbleBloc = CardBubbleBloc(cardMessage: widget.cardMessage);
    _cardBubbleBloc.add(InitializeCard(
      cardMessage: widget.cardMessage,
      loggedInUser: widget.loggedInUser,
    ));
    populateStyles();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentBrightness = MediaQuery.platformBrightnessOf(context);
    final brightnessChanged = _cachedBrightness != null && _cachedBrightness != currentBrightness;
    if (!_themeInitialized || brightnessChanged) {
      _cachedBrightness = currentBrightness;
      _themeInitialized = true;
      // Cache width to avoid MediaQuery in build()
      _cachedMaxWidth = MediaQuery.sizeOf(context).width * 65 / 100;
    }
  }

  @override
  void dispose() {
    _cardBubbleBloc.close();
    super.dispose();
  }

  populateStyles() {
    defaultButtonStyle = ButtonElementStyle(
      height: 35,
      borderRadius: BorderRadius.circular(6),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CardBubbleBloc, CardBubbleState>(
      bloc: _cardBubbleBloc,
      buildWhen: (previous, current) =>
          previous.interactionMap != current.interactionMap ||
          previous.isSentByMe != current.isSentByMe,
      builder: (context, state) {
        return Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: const BorderRadius.all(Radius.circular(4.0)),
        border: Border.all(
          width: 4,
        ),
      ),
      constraints: BoxConstraints(
          maxWidth: _cachedMaxWidth),
      //color: theme.palette.getBackground(),
      child: Column(
        children: [
          if (widget.cardMessage.imageUrl != null &&
              widget.cardMessage.imageUrl?.trim() != '')
            CometChatImageBubble(
              width: _cachedMaxWidth,
              imageUrl: widget.cardMessage.imageUrl!,
            ),
          if (widget.cardMessage.text.trim() != '')
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                widget.cardMessage.text,
                style: widget.cardBubbleStyle?.textStyle,
              ),
            ),
          if (widget.cardMessage.cardActions.isNotEmpty)
            ...List.generate(
                widget.cardMessage.cardActions.length,
                (index) => showActions(
                    widget.cardMessage.cardActions[index], state)),
        ],
      ),
    );
      },
    );
  }

  Widget showActions(
      BaseInteractiveElement interactiveElement, CardBubbleState state) {
    switch (interactiveElement.runtimeType) {
      case ButtonElement:
        ButtonElement buttonElement = interactiveElement as ButtonElement;

        bool isDisabled = InteractiveMessageUtils.checkElementDisabled(
            state.interactionMap, buttonElement, state.isSentByMe, widget.cardMessage);

        ButtonElementStyle buttonElementStyle;

        buttonElementStyle =
            widget.cardBubbleStyle?.buttonStyle?.merge(defaultButtonStyle) ??
                defaultButtonStyle;

        return Center(
          child: InkWell(
            onTap: () async {
              if (isDisabled) {
                return;
              }

              if (widget.onActionTap == null) {
                _cardBubbleBloc.add(ButtonClicked(
                  button: buttonElement,
                  elementId: buttonElement.elementId,
                  context: context,
                ));
              } else {
                widget.onActionTap!(interactiveElement);
              }
            },
            child: Container(
              height: buttonElementStyle.height,
              width: buttonElementStyle.width,
              decoration: const BoxDecoration(
                  border: Border(
                top: BorderSide(
                  width: 4.0, // Border width
                ),
              )),
              child: Center(
                child: Text(buttonElement.buttonText,
                    style: isDisabled == true
                        ? buttonElementStyle.buttonTextStyle?.merge(
                            const TextStyle())
                        : buttonElementStyle.buttonTextStyle),
              ),
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
