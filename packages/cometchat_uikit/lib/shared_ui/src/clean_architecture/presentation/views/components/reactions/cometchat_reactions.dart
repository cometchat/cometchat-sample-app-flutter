import "../../../../clean_architecture.dart";
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'reactions_bloc.dart';

///[CometChatReactions] is a widget which is used to set the reactions
///It takes [reactionList], [theme], [alignment], [onReactionTap], [onReactionLongPress], [style] as a parameter
///
/// ```dart
/// CometChatReactions(
///  reactionList: reactionList,
///  theme: theme,
///  alignment: BubbleAlignment.left,
///  onReactionTap: (reaction) {
///  print("reaction tapped");
///  },
///  onReactionLongPress: (reaction) {
///  print("reaction long pressed");
///  },
///  );
class CometChatReactions extends StatefulWidget {
  const CometChatReactions(
      {super.key,
      required this.reactionList,
      this.alignment,
      this.onReactionTap,
      this.onReactionLongPress,
      this.style,
      this.padding,
      this.margin,
      this.width,
      this.height,
      this.colorPalette,
      this.spacing,
      this.typography,
      });

  ///[reactionList] is a list of ReactionCount which is used to set the reactions
  final List<ReactionCount> reactionList;

  ///[alignment] is used to set the alignment of the reactions
  final BubbleAlignment? alignment;

  ///[onReactionTap] is a callback which gets called when a reaction is pressed
  final Function(String? reaction)? onReactionTap;

  ///[onReactionLongPress] is a callback which gets called when a reaction is long pressed
  final Function(String? reaction)? onReactionLongPress;

  ///[style] is a parameter used to set the style for the reactions
  final CometChatReactionsStyle? style;

  ///[margin] can be used to apply margin around each reaction
  final EdgeInsets? margin;

  ///[padding] can be used to apply padding inside each reaction
  final EdgeInsets? padding;

  ///[width] provides width to the widget
  final double? width;

  ///[height] provides height to the widget
  final double? height;

  /// [colorPalette] optional pre-cached color palette to avoid expensive lookups during keyboard animation
  final CometChatColorPalette? colorPalette;

  /// [spacing] optional pre-cached spacing to avoid expensive lookups during keyboard animation
  final CometChatSpacing? spacing;

  /// [typography] optional pre-cached typography to avoid expensive lookups during keyboard animation
  final CometChatTypography? typography;

  @override
  State<CometChatReactions> createState() => _CometChatReactionsState();
}

class _CometChatReactionsState extends State<CometChatReactions> {
  late ReactionsBloc _reactionsBloc;

  @override
  void initState() {
    super.initState();
    _reactionsBloc = ReactionsBloc(initialReactions: widget.reactionList);
  }

  @override
  void didUpdateWidget(covariant CometChatReactions oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update reactions bloc if reaction list changed
    if (widget.reactionList != oldWidget.reactionList) {
      _reactionsBloc.add(UpdateReactions(reactions: widget.reactionList));
    }
    // Update style if it changed
    if (widget.style != oldWidget.style) {
      style = CometChatThemeHelper.getTheme<CometChatReactionsStyle>(
              context: context, defaultTheme: CometChatReactionsStyle.of)
          .merge(widget.style);
    }
    // Update cached theme values if they changed
    if (widget.colorPalette != oldWidget.colorPalette && widget.colorPalette != null) {
      colorPalette = widget.colorPalette!;
    }
    if (widget.spacing != oldWidget.spacing && widget.spacing != null) {
      spacing = widget.spacing!;
    }
    if (widget.typography != oldWidget.typography && widget.typography != null) {
      typography = widget.typography!;
    }
  }

  @override
  void dispose() {
    _reactionsBloc.close();
    super.dispose();
  }

  late CometChatReactionsStyle style;
  late CometChatColorPalette colorPalette;
  late CometChatSpacing spacing;
  late CometChatTypography typography;
  bool _themeInitialized = false;
  Brightness? _cachedBrightness;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only initialize theme once to avoid expensive lookups during keyboard animation
    final currentBrightness = MediaQuery.platformBrightnessOf(context);
    final brightnessChanged = _cachedBrightness != null && _cachedBrightness != currentBrightness;
    if (!_themeInitialized || brightnessChanged) {
      _cachedBrightness = currentBrightness;
      style = CometChatThemeHelper.getTheme<CometChatReactionsStyle>(
              context: context, defaultTheme: CometChatReactionsStyle.of)
          .merge(widget.style);
      // Use passed values OR fallback to lookup (for standalone usage)
      colorPalette = widget.colorPalette ?? CometChatThemeHelper.getColorPalette(context);
      spacing = widget.spacing ?? CometChatThemeHelper.getSpacing(context);
      typography = widget.typography ?? CometChatThemeHelper.getTypography(context);
      _themeInitialized = true;
    }
  }



  Widget? getExtraReactions(
    ReactionsState state,
    CometChatReactionsStyle style,
    CometChatColorPalette colorPalette,
    CometChatSpacing spacing,
    CometChatTypography typography,
  ) {
    if (state.hasMore && state.extraCount > 1) {
      return GestureDetector(
          onTap: () {
            if (widget.onReactionLongPress != null) {
              widget.onReactionLongPress!(ReactionConstants.allReactions);
            }
          },
          onLongPress: () {
            if (widget.onReactionLongPress != null) {
              widget.onReactionLongPress!(ReactionConstants.allReactions);
            }
          },
          child: Container(
            margin: widget.margin ?? getMargin(spacing),
            padding: widget.padding ?? EdgeInsets.symmetric(horizontal: spacing.padding2 ?? 0, vertical: spacing.padding ?? 0),
            constraints: const BoxConstraints(
              minHeight: 24,
            ),
            decoration: BoxDecoration(
              color: (state.extraReactedByMe
                      ? style.activeReactionBackgroundColor ??
                          colorPalette.extendedPrimary100
                      : style.backgroundColor ?? colorPalette.background1) ??
                  Colors.transparent,
              border: state.extraReactedByMe == true
                  ? style.activeReactionBorder ??
                      Border.all(
                          color: colorPalette.extendedPrimary300 ?? Colors.transparent,
                          width: 1)
                  : (style.border ??
                      Border.all(
                          color: colorPalette.borderLight ?? Colors.transparent,
                          width: 1)),
              borderRadius: style.borderRadius ?? BorderRadius.all(Radius.circular(spacing.radius5 ?? 0)),
            ),
            child: Text("+${state.extraCount}",
                style: TextStyle(
                        fontSize: typography.body?.regular?.fontSize,
                        color: colorPalette.textPrimary)
                    .merge(style.countTextStyle)),
          ),
        );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReactionsBloc, ReactionsState>(
      bloc: _reactionsBloc,
      buildWhen: (previous, current) =>
          previous.reactionList != current.reactionList ||
          previous.animatingReaction != current.animatingReaction,
      builder: (context, state) {
        final extraReactions = getExtraReactions(state, style, colorPalette, spacing, typography);

        return Row(children: [
          ...state.visibleReactions.map((reactionCount) => GestureDetector(
            onTap: () {
              if (widget.onReactionTap != null) {
                widget.onReactionTap!(reactionCount.reaction);
              }
            },
            onLongPress: () {
              if (widget.onReactionLongPress != null) {
                widget.onReactionLongPress!(reactionCount.reaction);
              }
            },
            child: Container(
                          height: widget.height,
                          width: widget.width,
                          alignment: Alignment.center,
                          margin: widget.margin ?? getMargin(spacing),
                          padding: widget.padding ??
               EdgeInsets.symmetric(horizontal: spacing.padding2 ?? 0, vertical: spacing.padding ?? 0),
                          decoration: BoxDecoration(
              color:
                  (reactionCount.reactedByMe == true
                      ? style.activeReactionBackgroundColor ??
                      colorPalette.extendedPrimary100
                      : style.backgroundColor ?? colorPalette.background1) ?? Colors.transparent,
              border: reactionCount.reactedByMe == true
                  ? style.activeReactionBorder ??
                      Border.all(
                          color:
                             colorPalette.extendedPrimary300 ?? Colors.transparent,
                          width: 1)
                  : (style.border ??
                      Border.all(
                          color: colorPalette.borderLight ?? Colors.transparent,
                          width: 1)),
              borderRadius: style.borderRadius ?? BorderRadius.all(Radius.circular(
                  spacing.radius5 ?? 0)),),
                          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                  reactionCount.reaction ?? "",
                  style: TextStyle(fontSize: typography.body?.regular?.fontSize,
                    fontWeight: typography.body?.regular?.fontWeight,
                  )
                      .merge(style.emojiTextStyle)
              ),
              Padding(
                padding: EdgeInsets.only(right: spacing.padding1 ?? 0),
                child: Text(
                    " ${reactionCount.count}",
                    style: TextStyle(
                        fontSize: typography.body?.regular?.fontSize,
                        fontWeight: typography.body?.regular?.fontWeight,
                        color: style.countTextColor ?? colorPalette.textPrimary)
                        .merge(
                        style.countTextStyle)
                ),
              )
            ],
                          ),
                        ),
          )
      ),
      if (extraReactions != null) extraReactions
    ]);
      },
    );
  }

  EdgeInsets getMargin(CometChatSpacing spacing) {
    double leftAlignment = 0;
    if (widget.alignment == BubbleAlignment.right) {
      leftAlignment = spacing.margin ?? 0;
    }

    double rightAlignment = 0;
    if (widget.alignment == BubbleAlignment.left) {
      rightAlignment = spacing.margin ?? 0;
    }
    return EdgeInsets.only(left: leftAlignment, right: rightAlignment);
  }
}
