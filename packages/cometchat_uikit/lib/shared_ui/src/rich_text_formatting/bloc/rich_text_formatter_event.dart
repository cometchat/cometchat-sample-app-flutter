import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../domain/entities/format_type.dart';
import '../domain/entities/link_data.dart';

/// Base class for all rich text formatter events
/// Uses Equatable for proper event comparison in BLoC
abstract class RichTextFormatterEvent extends Equatable {
  const RichTextFormatterEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize the formatter
///
/// This event should be dispatched when the formatter is first created
/// to transition from the initial state to the ready state.
class InitializeFormatter extends RichTextFormatterEvent {
  const InitializeFormatter();
}

/// Format applied event
///
/// Dispatched when the user applies a format (e.g., bold, italic, link)
/// to the current text selection.
class FormatApplied extends RichTextFormatterEvent {
  /// The type of format to apply
  final FormatType formatType;

  /// The current text content
  final String text;

  /// The current text selection
  final TextSelection selection;

  /// Link data (required for link formatting)
  final LinkData? linkData;

  const FormatApplied({
    required this.formatType,
    required this.text,
    required this.selection,
    this.linkData,
  });

  @override
  List<Object?> get props => [formatType, text, selection, linkData];
}

/// Selection changed event
///
/// Dispatched when the text selection changes (cursor moves or text is selected).
/// This triggers detection of active formats at the new cursor position.
class SelectionChanged extends RichTextFormatterEvent {
  /// The current text content
  final String text;

  /// The new text selection
  final TextSelection selection;

  const SelectionChanged({
    required this.text,
    required this.selection,
  });

  @override
  List<Object?> get props => [text, selection];
}

/// Enter key pressed event
///
/// Dispatched when the user presses the Enter key.
/// This handles special behavior like list continuation and blockquote continuation.
class EnterKeyPressed extends RichTextFormatterEvent {
  /// The current text content
  final String text;

  /// The current text selection
  final TextSelection selection;

  const EnterKeyPressed({
    required this.text,
    required this.selection,
  });

  @override
  List<Object?> get props => [text, selection];
}

/// Link validation requested event
///
/// Dispatched when the user requests validation of a URL for link formatting.
class LinkValidationRequested extends RichTextFormatterEvent {
  /// The URL to validate
  final String url;

  const LinkValidationRequested(this.url);

  @override
  List<Object> get props => [url];
}
