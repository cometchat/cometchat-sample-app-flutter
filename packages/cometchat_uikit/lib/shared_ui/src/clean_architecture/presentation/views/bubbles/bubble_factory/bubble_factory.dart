import 'package:flutter/material.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;
import '../../../../core/constants/enums.dart';
import '../../../theme/colors/cometchat_color_palette.dart';
import '../../../theme/typography/cometchat_typography.dart';
import '../../../theme/spacing/cometchat_spacing.dart';

/// Callback for providing custom views for message bubble slots.
/// Returns Widget or null to use default/hide.
typedef BubbleViewProvider =
    Widget? Function(
      BuildContext context,
      BaseMessage message,
      BubbleAlignment alignment,
    );

/// Abstract factory for creating message bubble content widgets.
///
/// Unlike Android's separate createView/bindView for RecyclerView optimization,
/// Flutter's declarative paradigm handles view creation and data binding
/// through widget rebuilding automatically.
///
/// Each factory is responsible for creating the appropriate bubble widget
/// for a specific message type (text, image, video, etc.).
abstract class BubbleFactory<T extends BaseMessage> {
  /// Builds the bubble content widget for the given message.
  Widget build(
    BuildContext context,
    T message,
    BubbleAlignment alignment, {
    CometChatColorPalette? colorPalette,
    CometChatTypography? typography,
    CometChatSpacing? spacing,
  });

  /// Returns the factory key for a given message.
  /// Default: category + "_" + type. Deleted messages return "deleted".
  static String getFactoryKey(BaseMessage message) {
    if (message.deletedAt != null) {
      return 'deleted';
    }
    return '${message.category}_${message.type}';
  }

  /// Creates a factory key from category and type strings.
  static String createKey(String category, String type) => '${category}_$type';
}
