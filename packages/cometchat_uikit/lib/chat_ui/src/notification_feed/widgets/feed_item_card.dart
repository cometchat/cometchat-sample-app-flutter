import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';
import 'package:cometchat_cards/cometchat_cards.dart';

import '../cometchat_notification_feed_style.dart';
import '../utils/feed_visibility_tracker.dart';
import '../utils/timestamp_grouper.dart';

/// A single feed item card that wraps [CometChatCardView] from cards-flutter.
///
/// Includes:
/// - Unread indicator (left border when `readAt == null`)
/// - Card rendering via CometChatCardView
/// - Tap handler for onItemClick + "clicked" engagement
/// - Visibility tracking for "viewed" and "read" engagement
class FeedItemCard extends StatefulWidget {
  /// The notification feed item to render.
  final NotificationFeedItem feedItem;

  /// Style configuration.
  final CometChatNotificationFeedStyle style;

  /// Theme mode forwarded to CometChatCardView.
  final CometChatCardThemeMode cardThemeMode;

  /// Theme override forwarded to CometChatCardView.
  final CometChatCardThemeOverride? cardThemeOverride;

  /// Visibility tracker for engagement reporting.
  final FeedVisibilityTracker visibilityTracker;

  /// Callback when the card is tapped.
  final void Function(NotificationFeedItem feedItem)? onItemClick;

  /// Callback when an action within the card is triggered.
  final void Function(
          NotificationFeedItem feedItem, CometChatCardActionEvent action)?
      onActionClick;

  /// Callback to report "clicked" engagement.
  final VoidCallback? onClicked;

  const FeedItemCard({
    super.key,
    required this.feedItem,
    required this.style,
    required this.cardThemeMode,
    this.cardThemeOverride,
    required this.visibilityTracker,
    this.onItemClick,
    this.onActionClick,
    this.onClicked,
  });

  @override
  State<FeedItemCard> createState() => _FeedItemCardState();
}

class _FeedItemCardState extends State<FeedItemCard> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    // Mark already-read items so the tracker doesn't try to mark them again
    if (widget.feedItem.readAt != null) {
      widget.visibilityTracker.markAsAlreadyRead(widget.feedItem.id);
    }
  }

  @override
  void dispose() {
    if (_isVisible) {
      widget.visibilityTracker.onItemHidden(widget.feedItem);
    }
    super.dispose();
  }

  void _handleVisibilityChanged(bool visible) {
    if (visible && !_isVisible) {
      _isVisible = true;
      widget.visibilityTracker.onItemVisible(widget.feedItem);
    } else if (!visible && _isVisible) {
      _isVisible = false;
      widget.visibilityTracker.onItemHidden(widget.feedItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = widget.feedItem.readAt == null;
    // Ensure the content is a valid Card Schema with version and body.
    // Some backend items may send the body element directly without the
    // wrapper — normalize them here.
    final content = widget.feedItem.content;
    final String cardJson;
    if (content.containsKey('version') && content.containsKey('body')) {
      cardJson = jsonEncode(content);
    } else {
      // Wrap bare element(s) in a proper card schema
      cardJson = jsonEncode({
        'version': '1.0',
        'body': [content],
      });
    }
    final locale = Localizations.localeOf(context).toString();

    return _VisibilityDetectorWidget(
      onVisibilityChanged: _handleVisibilityChanged,
      child: Semantics(
        label: 'Notification from ${widget.feedItem.category}${isUnread ? ', unread' : ''}',
        child: GestureDetector(
          onTap: () {
            widget.onClicked?.call();
            widget.onItemClick?.call(widget.feedItem);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: widget.style.cardBackgroundColor,
              borderRadius: BorderRadius.circular(
                  widget.style.cardBorderRadius ?? 12),
              border: Border.all(
                color: widget.style.cardBorderColor ?? Colors.grey.shade200,
                width: widget.style.cardBorderWidth ?? 0.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Unread indicator
                if (isUnread)
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: widget.style.unreadIndicatorColor ?? Colors.blue,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                // Card content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category + timestamp row
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.feedItem.category,
                              style: (widget.style.timestampTextStyle ??
                                      const TextStyle(fontSize: 11))
                                  .copyWith(
                                      color: widget.style.timestampTextColor ??
                                          Colors.grey.shade600),
                            ),
                            Text(
                              getRelativeTime(widget.feedItem.sentAt, locale),
                              style: (widget.style.timestampTextStyle ??
                                      const TextStyle(fontSize: 11))
                                  .copyWith(
                                      color: widget.style.timestampTextColor ??
                                          Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      // Card rendering
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: CometChatCardView(
                          cardJson: cardJson,
                          themeMode: widget.cardThemeMode,
                          themeOverride: widget.cardThemeOverride,
                          onAction: (CometChatCardActionEvent action) {
                            widget.onClicked?.call();
                            widget.onActionClick?.call(
                                widget.feedItem, action);
                            // Show toast for button/link taps
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Action: ${action.action.type} (${action.elementId})',
                                ),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A simple visibility detection widget that uses scroll notifications
/// and layout information to determine if the widget is visible.
///
/// This is a lightweight alternative to the `visibility_detector` package
/// that works within a ListView context.
class _VisibilityDetectorWidget extends StatefulWidget {
  final Widget child;
  final void Function(bool isVisible) onVisibilityChanged;

  const _VisibilityDetectorWidget({
    required this.child,
    required this.onVisibilityChanged,
  });

  @override
  State<_VisibilityDetectorWidget> createState() =>
      _VisibilityDetectorWidgetState();
}

class _VisibilityDetectorWidgetState extends State<_VisibilityDetectorWidget>
    with WidgetsBindingObserver {
  final GlobalKey _key = GlobalKey();
  bool _wasVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _checkVisibility() {
    if (!mounted) return;

    final renderObject = _key.currentContext?.findRenderObject();
    if (renderObject == null || renderObject is! RenderBox) return;

    if (!renderObject.hasSize) return;

    final viewport = RenderAbstractViewport.of(renderObject);
    final offset = viewport.getOffsetToReveal(renderObject, 0.0);
    final scrollableState = Scrollable.maybeOf(_key.currentContext!);
    if (scrollableState == null) return;

    final scrollPosition = scrollableState.position;
    final viewportHeight = scrollPosition.viewportDimension;
    final scrollOffset = scrollPosition.pixels;

    final itemTop = offset.offset - scrollOffset;
    final itemBottom = itemTop + renderObject.size.height;

    // Item is visible if any part is within the viewport
    final isVisible = itemBottom > 0 && itemTop < viewportHeight;

    if (isVisible != _wasVisible) {
      _wasVisible = isVisible;
      widget.onVisibilityChanged(isVisible);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _checkVisibility();
        return false;
      },
      child: KeyedSubtree(
        key: _key,
        child: widget.child,
      ),
    );
  }
}
