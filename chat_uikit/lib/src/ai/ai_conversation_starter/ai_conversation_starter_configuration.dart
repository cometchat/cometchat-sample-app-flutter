import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:flutter/material.dart';

///[AIConversationStarterConfiguration] is a data class that has configuration properties
///to customize the functionality and appearance of [AIConversationStarterExtension]
///
/// ```dart
///   AiConversationStarterConfiguration(
///    style: AiConversationStarterStyle(),
///    theme: CometChatTheme(palette: Palette(),typography: Typography())
///  );
/// ```
class AIConversationStarterConfiguration {
  AIConversationStarterConfiguration(
      {this.conversationStarterStyle,
      this.customView,
      this.apiConfiguration});

  ///[conversationStarterStyle] provides styling to the reply view
  final CometChatAIConversationStarterStyle? conversationStarterStyle;

  ///[customView] gives conversation starter view
  final Widget Function(List<String> replies, BuildContext context)? customView;

  ///[apiConfiguration] set the configuration
  final Future<Map<String, dynamic>> Function(User? user, Group? group)?
      apiConfiguration;

  /// Copies current [AIConversationStarterConfiguration] with some changes
  AIConversationStarterConfiguration copyWith(
      {CometChatAIConversationStarterStyle? conversationStarterStyle,
      CometChatTheme? theme,
      String? emptyStateText,
      String? loadingStateText,
      String? errorStateText,
      Widget Function(List<String> replies, BuildContext context)? customView,
      Widget Function(List<String> replies, BuildContext context)?
          conversationStarterEmptyView,
      WidgetBuilder? emptyStateView,
      WidgetBuilder? loadingStateView,
      WidgetBuilder? errorStateView,
      String? errorIconUrl,
      String? emptyIconUrl,
      String? loadingIconUrl,
      String? loadingIconPackageName,
      String? emptyIconPackageName,
      String? errorIconPackageName,
      Future<Map<String, dynamic>> Function(User? user, Group? group)?
          apiConfiguration}) {
    return AIConversationStarterConfiguration(
      conversationStarterStyle:
          conversationStarterStyle ?? this.conversationStarterStyle,
      customView: customView ?? this.customView,
      apiConfiguration: apiConfiguration ?? this.apiConfiguration,
    );
  }

  /// Merges current [AIConversationStarterConfiguration] with [other]
  AIConversationStarterConfiguration merge(
      AIConversationStarterConfiguration? other) {
    if (other == null) return this;
    return copyWith(
      conversationStarterStyle: other.conversationStarterStyle,
      customView: other.customView,
      apiConfiguration: other.apiConfiguration,
    );
  }
}
