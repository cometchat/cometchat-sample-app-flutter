import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/usecases/apply_format_usecase.dart';
import '../domain/usecases/detect_active_formats_usecase.dart';
import '../domain/usecases/validate_link_usecase.dart';
import '../domain/usecases/parse_formatted_text_usecase.dart';
import '../domain/entities/format_result.dart';
import '../domain/entities/format_type.dart';
import '../domain/entities/format_compatibility.dart';
import '../di/rich_text_service_locator.dart';
import '../../../../shared_ui/src/clean_architecture/core/result.dart';
import 'rich_text_formatter_event.dart';
import 'rich_text_formatter_state.dart';

/// BLoC for managing rich text formatting state
///
/// This BLoC manages the rich text formatting state and handles:
/// - Applying formatting to text (bold, italic, link, etc.)
/// - Detecting active formats at cursor position
/// - Validating links
/// - Handling Enter key for list/blockquote continuation
///
/// The BLoC uses use cases from the domain layer to perform operations
/// and emits immutable states for the UI to react to.
///
/// Example:
/// ```dart
/// final bloc = RichTextFormatterBloc();
/// bloc.add(const InitializeFormatter());
///
/// // Apply bold formatting
/// bloc.add(FormatApplied(
///   formatType: FormatType.bold,
///   text: controller.text,
///   selection: controller.selection,
/// ));
///
/// // Listen to format results
/// bloc.onFormatApplied = (result) {
///   controller.value = TextEditingValue(
///     text: result.newText,
///     selection: result.newSelection,
///   );
/// };
/// ```
class RichTextFormatterBloc
    extends Bloc<RichTextFormatterEvent, RichTextFormatterState> {
  // Use cases - initialized from service locator if not provided
  final ApplyFormatUseCase applyFormatUseCase;
  final DetectActiveFormatsUseCase detectActiveFormatsUseCase;
  final ValidateLinkUseCase validateLinkUseCase;
  final ParseFormattedTextUseCase parseFormattedTextUseCase;

  // Debounce timer for selection changes
  Timer? _selectionDebounceTimer;
  static const Duration _selectionDebounceDelay = Duration(milliseconds: 100);

  /// Callback when format is successfully applied
  /// Use this to update the text controller with the new text and selection
  void Function(FormatResult)? onFormatApplied;

  /// Creates a RichTextFormatterBloc.
  ///
  /// Use cases are optional - if not provided, they will be retrieved from
  /// the [RichTextServiceLocator]. Make sure to call
  /// `RichTextServiceLocator.instance.setup(configuration)` before creating
  /// a BLoC without explicit use cases.
  ///
  /// Example with service locator:
  /// ```dart
  /// RichTextServiceLocator.instance.setup(const RichTextConfiguration());
  /// final bloc = RichTextFormatterBloc();
  /// ```
  ///
  /// Example with explicit use cases (for testing):
  /// ```dart
  /// final bloc = RichTextFormatterBloc(
  ///   applyFormatUseCase: mockApplyFormat,
  ///   detectActiveFormatsUseCase: mockDetectFormats,
  ///   validateLinkUseCase: mockValidateLink,
  ///   parseFormattedTextUseCase: mockParseText,
  /// );
  /// ```
  RichTextFormatterBloc({
    ApplyFormatUseCase? applyFormatUseCase,
    DetectActiveFormatsUseCase? detectActiveFormatsUseCase,
    ValidateLinkUseCase? validateLinkUseCase,
    ParseFormattedTextUseCase? parseFormattedTextUseCase,
  })  : applyFormatUseCase = applyFormatUseCase ??
            RichTextServiceLocator.instance.applyFormatUseCase,
        detectActiveFormatsUseCase = detectActiveFormatsUseCase ??
            RichTextServiceLocator.instance.detectActiveFormatsUseCase,
        validateLinkUseCase = validateLinkUseCase ??
            RichTextServiceLocator.instance.validateLinkUseCase,
        parseFormattedTextUseCase = parseFormattedTextUseCase ??
            RichTextServiceLocator.instance.parseFormattedTextUseCase,
        super(const RichTextFormatterInitial()) {
    // Register event handlers
    on<InitializeFormatter>(_onInitialize);
    on<FormatApplied>(_onFormatApplied);
    on<SelectionChanged>(_onSelectionChanged);
    on<EnterKeyPressed>(_onEnterKeyPressed);
    on<LinkValidationRequested>(_onLinkValidationRequested);
  }

  /// Initialize the formatter
  void _onInitialize(
    InitializeFormatter event,
    Emitter<RichTextFormatterState> emit,
  ) {
    emit(const RichTextFormatterReady());
  }

  /// Handle format applied event
  Future<void> _onFormatApplied(
    FormatApplied event,
    Emitter<RichTextFormatterState> emit,
  ) async {
    if (state is! RichTextFormatterReady) return;

    final currentState = state as RichTextFormatterReady;
    emit(currentState.copyWith(isFormattingInProgress: true));

    final result = await applyFormatUseCase(
      formatType: event.formatType,
      text: event.text,
      selection: event.selection,
      linkData: event.linkData,
    );

    if (result is Success<FormatResult>) {
      // Notify callback with the format result
      onFormatApplied?.call(result.data);

      // Detect active formats at new cursor position
      final activeFormatsResult = await detectActiveFormatsUseCase(
        text: result.data.newText,
        cursorPosition: result.data.newSelection.start,
      );

      final activeFormats = activeFormatsResult is Success<Set<FormatType>>
          ? activeFormatsResult.data
          : <FormatType>{};

      emit(RichTextFormatterReady(
        activeFormats: activeFormats,
        disabledFormats: FormatCompatibility.getDisabledFormats(activeFormats),
        selection: result.data.newSelection,
        isFormattingInProgress: false,
      ));
    } else if (result is Failure) {
      emit(currentState.copyWith(
        isFormattingInProgress: false,
        errorMessage: result.message,
      ));
    }
  }

  /// Handle selection changed event
  void _onSelectionChanged(
    SelectionChanged event,
    Emitter<RichTextFormatterState> emit,
  ) {
    if (state is! RichTextFormatterReady) return;

    // Cancel previous debounce timer
    _selectionDebounceTimer?.cancel();

    // Debounce rapid selection changes
    _selectionDebounceTimer = Timer(_selectionDebounceDelay, () {
      if (!isClosed) {
        _detectAndEmitActiveFormats(event.text, event.selection, emit);
      }
    });
  }

  /// Detect active formats and emit updated state
  Future<void> _detectAndEmitActiveFormats(
    String text,
    TextSelection selection,
    Emitter<RichTextFormatterState> emit,
  ) async {
    final result = await detectActiveFormatsUseCase(
      text: text,
      cursorPosition: selection.start,
    );

    if (result is Success<Set<FormatType>>) {
      final currentState = state as RichTextFormatterReady;
      emit(currentState.copyWith(
        activeFormats: result.data,
        selection: selection,
      ));
    }
  }

  /// Handle Enter key pressed event
  Future<void> _onEnterKeyPressed(
    EnterKeyPressed event,
    Emitter<RichTextFormatterState> emit,
  ) async {
    // This will be implemented when Enter key handling use case is added
    // For now, this is a placeholder for future functionality
  }

  /// Handle link validation requested event
  Future<void> _onLinkValidationRequested(
    LinkValidationRequested event,
    Emitter<RichTextFormatterState> emit,
  ) async {
    final result = await validateLinkUseCase(event.url);

    if (result is Failure) {
      final currentState = state as RichTextFormatterReady;
      emit(currentState.copyWith(errorMessage: result.message));
    }
  }

  @override
  Future<void> close() {
    _selectionDebounceTimer?.cancel();
    return super.close();
  }
}
