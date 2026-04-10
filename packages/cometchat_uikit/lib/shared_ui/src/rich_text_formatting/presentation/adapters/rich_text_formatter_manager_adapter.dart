import 'package:flutter/material.dart';
import '../../../formatter/rich_text/rich_text_format_type.dart';
import '../../../formatter/rich_text/rich_text_configuration.dart';
import '../../../formatter/rich_text/format_result.dart' as legacy;
import '../../../clean_architecture/presentation/formatters/cometchat_text_formatter.dart';
import '../../bloc/rich_text_formatter_bloc.dart';
import '../../bloc/rich_text_formatter_event.dart';
import '../../bloc/rich_text_formatter_state.dart';
import '../../domain/entities/format_type.dart';
import '../../domain/entities/format_result.dart';
import '../../domain/entities/link_data.dart';

/// Adapter that bridges the legacy [RichTextFormatterManager] interface
/// to the new Clean Architecture + BLoC implementation.
///
/// This adapter allows existing code that uses [RichTextFormatterManager]
/// to continue working while the codebase migrates to the new architecture.
///
/// ## Migration Guide
///
/// Instead of:
/// ```dart
/// final manager = RichTextFormatterManager(configuration: config);
/// manager.applyFormat(formatType: RichTextFormatType.bold, controller: controller);
/// ```
///
/// Use the new BLoC directly:
/// ```dart
/// final bloc = RichTextFormatterBloc(...);
/// bloc.add(FormatApplied(
///   formatType: FormatType.bold,
///   text: controller.text,
///   selection: controller.selection,
/// ));
/// ```
///
/// Or use this adapter during migration:
/// ```dart
/// final adapter = RichTextFormatterManagerAdapter(bloc: bloc, configuration: config);
/// adapter.applyFormat(formatType: RichTextFormatType.bold, controller: controller);
/// ```
@Deprecated(
  'Use RichTextFormatterBloc directly instead. '
      'This adapter is provided for backward compatibility during migration. '
      'See migration guide in class documentation.',
)
class RichTextFormatterManagerAdapter {
  RichTextFormatterManagerAdapter({
    required RichTextFormatterBloc bloc,
    required RichTextConfiguration configuration,
  })  : _bloc = bloc,
        _configuration = configuration;

  final RichTextFormatterBloc _bloc;
  final RichTextConfiguration _configuration;

  /// Callback when formatting is applied (legacy interface)
  void Function(RichTextFormatType, String)? onFormatApplied;

  /// Get the configuration
  RichTextConfiguration get configuration => _configuration;

  /// Get enabled format types (reads from configuration)
  List<RichTextFormatType> get enabledFormatTypes {
    final types = <RichTextFormatType>[];
    if (_configuration.enableBold) types.add(RichTextFormatType.bold);
    if (_configuration.enableItalic) types.add(RichTextFormatType.italic);
    if (_configuration.enableUnderline) types.add(RichTextFormatType.underline);
    if (_configuration.enableStrikethrough) {
      types.add(RichTextFormatType.strikethrough);
    }
    if (_configuration.enableInlineCode) {
      types.add(RichTextFormatType.inlineCode);
    }
    if (_configuration.enableCodeBlock) types.add(RichTextFormatType.codeBlock);
    if (_configuration.enableLinks) types.add(RichTextFormatType.link);
    if (_configuration.isBulletListEnabled) {
      types.add(RichTextFormatType.bulletList);
    }
    if (_configuration.isOrderedListEnabled) {
      types.add(RichTextFormatType.orderedList);
    }
    if (_configuration.isBlockquoteEnabled) {
      types.add(RichTextFormatType.blockquote);
    }
    return types;
  }

  /// Get all active formatters as a list
  /// Note: Returns empty list as formatters are now internal to the BLoC
  List<CometChatTextFormatter> get activeFormatters => [];

  /// Apply formatting to the current selection
  /// Delegates to BLoC by dispatching FormatApplied event
  legacy.FormatResult? applyFormat({
    required RichTextFormatType formatType,
    required TextEditingController controller,
    String? linkUrl,
    String? linkDisplayText,
  }) {
    final newFormatType = _convertToNewFormatType(formatType);

    // Create link data if this is a link format
    LinkData? linkData;
    if (formatType == RichTextFormatType.link && linkUrl != null) {
      final displayText = linkDisplayText ??
          (controller.selection.isCollapsed
              ? linkUrl
              : controller.text.substring(
            controller.selection.start,
            controller.selection.end,
          ));
      linkData = LinkData(url: linkUrl, displayText: displayText);
    }

    // Set up callback to capture result and notify legacy callback
    FormatResult? capturedResult;
    final originalCallback = _bloc.onFormatApplied;
    _bloc.onFormatApplied = (result) {
      capturedResult = result;
      onFormatApplied?.call(formatType, result.newText);
      originalCallback?.call(result);
    };

    // Dispatch event to BLoC
    _bloc.add(FormatApplied(
      formatType: newFormatType,
      text: controller.text,
      selection: controller.selection,
      linkData: linkData,
    ));

    // Restore original callback
    _bloc.onFormatApplied = originalCallback;

    // Convert result to legacy format
    if (capturedResult != null) {
      return legacy.FormatResult(
        newText: capturedResult!.newText,
        newSelection: capturedResult!.newSelection,
        formatApplied: formatType,
      );
    }
    return null;
  }

  /// Detect active formats at cursor position
  /// Reads from BLoC state
  Set<RichTextFormatType> getActiveFormats(String text, int cursorPosition) {
    final state = _bloc.state;
    if (state is! RichTextFormatterReady) {
      return <RichTextFormatType>{};
    }

    return state.activeFormats
        .map(_convertToLegacyFormatType)
        .whereType<RichTextFormatType>()
        .toSet();
  }

  /// Get disabled formats based on current active formats
  /// Reads from BLoC state
  Set<RichTextFormatType> getDisabledFormats() {
    final state = _bloc.state;
    if (state is! RichTextFormatterReady) {
      return <RichTextFormatType>{};
    }

    return state.disabledFormats
        .map(_convertToLegacyFormatType)
        .whereType<RichTextFormatType>()
        .toSet();
  }

  /// Check if a format type is enabled
  bool isFormatEnabled(RichTextFormatType formatType) {
    return enabledFormatTypes.contains(formatType);
  }

  /// Handle Enter key press for list continuation and code blocks
  /// Delegates to BLoC by dispatching EnterKeyPressed event
  legacy.FormatResult? handleEnter(String text, TextSelection selection) {
    // Dispatch event to BLoC
    _bloc.add(EnterKeyPressed(text: text, selection: selection));

    // Note: The BLoC handles this asynchronously, so we can't return
    // a synchronous result. Consumers should listen to BLoC state changes
    // or use the onFormatApplied callback instead.
    return null;
  }

  // ============================================================================
  // Format Type Conversion Helpers
  // ============================================================================

  /// Convert legacy RichTextFormatType to new FormatType
  FormatType _convertToNewFormatType(RichTextFormatType legacyType) {
    switch (legacyType) {
      case RichTextFormatType.bold:
        return FormatType.bold;
      case RichTextFormatType.italic:
        return FormatType.italic;
      case RichTextFormatType.strikethrough:
        return FormatType.strikethrough;
      case RichTextFormatType.inlineCode:
        return FormatType.inlineCode;
      case RichTextFormatType.codeBlock:
        return FormatType.codeBlock;
      case RichTextFormatType.link:
        return FormatType.link;
      case RichTextFormatType.bulletList:
        return FormatType.bulletList;
      case RichTextFormatType.orderedList:
        return FormatType.orderedList;
      case RichTextFormatType.blockquote:
        return FormatType.blockquote;
      case RichTextFormatType.underline:
        return FormatType.underline;
    }
  }

  /// Convert new FormatType to legacy RichTextFormatType
  RichTextFormatType? _convertToLegacyFormatType(FormatType newType) {
    switch (newType) {
      case FormatType.bold:
        return RichTextFormatType.bold;
      case FormatType.italic:
        return RichTextFormatType.italic;
      case FormatType.strikethrough:
        return RichTextFormatType.strikethrough;
      case FormatType.inlineCode:
        return RichTextFormatType.inlineCode;
      case FormatType.codeBlock:
        return RichTextFormatType.codeBlock;
      case FormatType.link:
        return RichTextFormatType.link;
      case FormatType.bulletList:
        return RichTextFormatType.bulletList;
      case FormatType.orderedList:
        return RichTextFormatType.orderedList;
      case FormatType.blockquote:
        return RichTextFormatType.blockquote;
      case FormatType.underline:
        return RichTextFormatType.underline;
    }
  }
}
