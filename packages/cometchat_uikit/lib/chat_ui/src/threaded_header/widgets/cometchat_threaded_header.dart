import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../cometchat_chat_uikit.dart';
import '../../../../cometchat_chat_uikit.dart' as cc;

/// [CometChatThreadedHeader] is a widget that displays a parent message
/// and its reply count in a threaded conversation view.
///
/// This widget uses BLoC for state management and follows Clean Architecture
/// patterns. It listens to SDK events for real-time reply count updates
/// and parent message changes (edit/delete).
///
/// ```dart
/// CometChatThreadedHeader(
///   parentMessage: BaseMessage(),
///   loggedInUser: User(),
/// );
/// ```
class CometChatThreadedHeader extends StatefulWidget {
  const CometChatThreadedHeader({
    super.key,
    required this.parentMessage,
    this.messageActionView,
    this.style,
    required this.loggedInUser,
    this.template,
    this.height,
    this.width,
    this.receiptsVisibility = true,
    this.textFormatters,
    // Optional pre-cached theme values for optimization
    this.colorPalette,
    this.typography,
    this.spacing,
  });

  /// [parentMessage] parent message for thread
  final BaseMessage parentMessage;

  /// [messageActionView] custom action view
  final Function(BaseMessage message, BuildContext context)? messageActionView;

  /// [style] style parameter
  final CometChatThreadedHeaderStyle? style;

  /// [loggedInUser] get logged in user
  final User loggedInUser;

  /// [template] to get the message template
  final CometChatMessageTemplate? template;

  /// [height] provides height to the widget
  final double? height;

  /// [width] provides width to the widget
  final double? width;

  /// [receiptsVisibility] controls visibility of receipts
  final bool? receiptsVisibility;

  /// [textFormatters] list of text formatters. null = use defaults, empty = no formatters
  final List<CometChatTextFormatter>? textFormatters;

  /// [colorPalette] optional pre-cached color palette for optimization
  final CometChatColorPalette? colorPalette;

  /// [typography] optional pre-cached typography for optimization
  final CometChatTypography? typography;

  /// [spacing] optional pre-cached spacing for optimization
  final CometChatSpacing? spacing;

  @override
  State<CometChatThreadedHeader> createState() =>
      _CometChatThreadedHeaderState();
}

class _CometChatThreadedHeaderState extends State<CometChatThreadedHeader> {
  /// BLoC for managing threaded header state
  late ThreadedHeaderBloc _bloc;

  /// Theme caching - initialized once in didChangeDependencies
  late CometChatColorPalette _colorPalette;
  late CometChatTypography _typography;
  late CometChatSpacing _spacing;
  bool _themeInitialized = false;
  Brightness? _cachedBrightness;

  /// Merged style
  late CometChatThreadedHeaderStyle _threadedHeaderStyle;

  /// Message template for rendering the parent message bubble
  late CometChatMessageTemplate _messageTemplate;

  /// Key for measuring bubble height
  final _bubbleKey = GlobalKey();

  /// Cached screen height — avoids MediaQuery subscription in build()
  double _cachedScreenHeight = 0;

  /// Cached bubble widget — avoids expensive recreation on every keyboard frame
  Widget? _cachedBubble;
  BaseMessage? _cachedBubbleMessage;

  @override
  void initState() {
    super.initState();

    // Resolve message template from data source based on message category/type
    _resolveMessageTemplate();

    // Create BLoC and dispatch initialization event
    _bloc = ThreadedHeaderBloc();
    _bloc.add(
      InitializeThreadedHeader(
        parentMessage: widget.parentMessage,
        loggedInUser: widget.loggedInUser,
      ),
    );
  }

  /// Resolve the message template from data source or use custom template
  void _resolveMessageTemplate() {
    // If custom template is provided, use it
    if (widget.template != null) {
      _messageTemplate = widget.template!;
      return;
    }

    // Get all templates from data source
    final templates = MessageTemplateUtils.getAllMessageTemplates();

    // Find matching template based on message category and type
    CometChatMessageTemplate? resolvedTemplate;
    for (final template in templates) {
      if (widget.parentMessage.category == template.category &&
          widget.parentMessage.type == template.type) {
        resolvedTemplate = template;
        break;
      }
    }

    // Use resolved template or fallback to first template
    _messageTemplate = resolvedTemplate ?? templates.first;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only initialize theme once to avoid expensive lookups during rebuilds
    final currentBrightness = MediaQuery.platformBrightnessOf(context);
    final brightnessChanged =
        _cachedBrightness != null && _cachedBrightness != currentBrightness;
    if (!_themeInitialized || brightnessChanged) {
      _cachedBrightness = currentBrightness;
      // Use passed values or fallback to lookups (for standalone usage)
      _colorPalette =
          widget.colorPalette ?? CometChatThemeHelper.getColorPalette(context);
      _typography =
          widget.typography ?? CometChatThemeHelper.getTypography(context);
      _spacing = widget.spacing ?? CometChatThemeHelper.getSpacing(context);

      // Merge style with theme
      _threadedHeaderStyle =
          CometChatThemeHelper.getTheme<CometChatThreadedHeaderStyle>(
            context: context,
            defaultTheme: CometChatThreadedHeaderStyle.of,
          ).merge(widget.style);

      // Cache screen height so build() doesn't subscribe to MediaQuery
      _cachedScreenHeight = MediaQuery.sizeOf(context).height;

      _themeInitialized = true;
    }
  }

  @override
  void didUpdateWidget(CometChatThreadedHeader oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update cached theme values if they changed
    if (widget.colorPalette != oldWidget.colorPalette &&
        widget.colorPalette != null) {
      _colorPalette = widget.colorPalette!;
    }
    if (widget.typography != oldWidget.typography &&
        widget.typography != null) {
      _typography = widget.typography!;
    }
    if (widget.spacing != oldWidget.spacing && widget.spacing != null) {
      _spacing = widget.spacing!;
    }

    // Update style if it changed
    if (widget.style != oldWidget.style) {
      _threadedHeaderStyle =
          CometChatThemeHelper.getTheme<CometChatThreadedHeaderStyle>(
            context: context,
            defaultTheme: CometChatThreadedHeaderStyle.of,
          ).merge(widget.style);
    }

    // Re-resolve template if parent message or custom template changed
    if (widget.parentMessage != oldWidget.parentMessage ||
        widget.template != oldWidget.template) {
      _resolveMessageTemplate();
    }
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  /// Build the action view showing reply count
  Widget _buildActionView(int replyCount, BuildContext context) {
    if (widget.messageActionView != null) {
      return widget.messageActionView!(widget.parentMessage, context);
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color:
            _threadedHeaderStyle.countContainerBackGroundColor ??
            _colorPalette.extendedPrimary100,
        border:
            _threadedHeaderStyle.countContainerBorder ??
            Border(
              bottom: BorderSide(
                width: 1.0,
                color: _colorPalette.borderDefault ?? Colors.transparent,
                style: BorderStyle.solid,
              ),
            ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: _spacing.padding1 ?? 0,
        horizontal: _spacing.padding4 ?? 0,
      ),
      child: Text(
        "$replyCount ${replyCount > 1 ? cc.Translations.of(context).replies : cc.Translations.of(context).reply}",
        style:
            TextStyle(
                  color:
                      _threadedHeaderStyle.countTextColor ??
                      _colorPalette.textSecondary,
                  fontSize: _typography.body?.regular?.fontSize,
                  fontFamily: _typography.body?.regular?.fontFamily,
                  fontWeight: _typography.body?.regular?.fontWeight,
                )
                .merge(_threadedHeaderStyle.countTextStyle)
                .copyWith(color: _threadedHeaderStyle.countTextColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThreadedHeaderBloc, ThreadedHeaderState>(
      bloc: _bloc,
      builder: (context, state) {
        // Use parent message from state if available, otherwise use widget's
        final parentMessage = state.parentMessage ?? widget.parentMessage;
        final replyCount = state.replyCount;

        // Only rebuild the bubble widget when the message actually changes,
        // not on every keyboard animation frame
        if (_cachedBubble == null || _cachedBubbleMessage != parentMessage) {
          _cachedBubbleMessage = parentMessage;
          _cachedBubble = MessageUtils.getMessageBubble(
            context: context,
            colorPalette: _colorPalette,
            spacing: _spacing,
            typography: _typography,
            bubbleAlignment:
                parentMessage.sender?.uid == widget.loggedInUser.uid
                ? BubbleAlignment.right
                : BubbleAlignment.left,
            message: parentMessage,
            template: _messageTemplate,
            outgoingMessageBubbleStyle:
                _threadedHeaderStyle.outgoingMessageBubbleStyle,
            incomingMessageBubbleStyle:
                _threadedHeaderStyle.incomingMessageBubbleStyle,
            textFormatters:
                widget.textFormatters ??
                MessageTemplateUtils.getDefaultTextFormatters(),
            key: _bubbleKey,
            receiptsVisibility: widget.receiptsVisibility,
          );
        }

        // Use cached screen height instead of MediaQuery.sizeOf(context)
        // to avoid subscribing to MediaQuery changes during keyboard animation
        final maxHeight = _cachedScreenHeight * 0.30;

        return Container(
          width: widget.width ?? double.infinity,
          constraints:
              _threadedHeaderStyle.constraints ??
              BoxConstraints(maxHeight: widget.height ?? maxHeight),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        _threadedHeaderStyle.bubbleContainerBackGroundColor ??
                        _colorPalette.background3,
                    borderRadius:
                        _threadedHeaderStyle.bubbleContainerBorderRadius,
                    border: _threadedHeaderStyle.bubbleContainerBorder,
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(top: _spacing.padding4 ?? 0),
                      child: IgnorePointer(child: _cachedBubble),
                    ),
                  ),
                ),
              ),
              _buildActionView(replyCount, context),
            ],
          ),
        );
      },
    );
  }
}
