import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../domain/entities/format_type.dart';
import '../domain/entities/format_compatibility.dart';

/// Base class for rich text formatter states
/// Uses Equatable for proper state comparison in BLoC
abstract class RichTextFormatterState extends Equatable {
  const RichTextFormatterState();

  @override
  List<Object?> get props => [];
}

/// Initial state before initialization
class RichTextFormatterInitial extends RichTextFormatterState {
  const RichTextFormatterInitial();
}

/// Ready state with formatting capabilities
///
/// This state is emitted when the formatter is ready to handle formatting operations.
/// It tracks active formats at the current cursor position, the current selection,
/// and any ongoing formatting operations or errors.
class RichTextFormatterReady extends RichTextFormatterState {
  /// Set of formats active at the current cursor position
  final Set<FormatType> activeFormats;

  /// Set of formats that are disabled due to incompatibility with active formats
  final Set<FormatType> disabledFormats;

  /// Current text selection
  final TextSelection selection;

  /// Whether a formatting operation is currently in progress
  final bool isFormattingInProgress;

  /// Error message if the last operation failed
  final String? errorMessage;

  const RichTextFormatterReady({
    this.activeFormats = const {},
    this.disabledFormats = const {},
    this.selection = const TextSelection.collapsed(offset: 0),
    this.isFormattingInProgress = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        activeFormats,
        disabledFormats,
        selection,
        isFormattingInProgress,
        errorMessage,
      ];

  /// Create a copy of this state with updated fields
  RichTextFormatterReady copyWith({
    Set<FormatType>? activeFormats,
    Set<FormatType>? disabledFormats,
    TextSelection? selection,
    bool? isFormattingInProgress,
    String? errorMessage,
  }) {
    final newActiveFormats = activeFormats ?? this.activeFormats;
    // Auto-calculate disabled formats when active formats change
    final newDisabledFormats = disabledFormats ?? 
        FormatCompatibility.getDisabledFormats(newActiveFormats);
    
    return RichTextFormatterReady(
      activeFormats: newActiveFormats,
      disabledFormats: newDisabledFormats,
      selection: selection ?? this.selection,
      isFormattingInProgress:
          isFormattingInProgress ?? this.isFormattingInProgress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
