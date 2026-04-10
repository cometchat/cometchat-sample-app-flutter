import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class TextBubbleEvent {}

class InitializeTextEvent extends TextBubbleEvent {
  final String? text;
  final List<dynamic>? formatters;

  InitializeTextEvent({
    this.text,
    this.formatters,
  });
}

class UpdateTextEvent extends TextBubbleEvent {
  final String text;

  UpdateTextEvent(this.text);
}

class ApplyFormattersEvent extends TextBubbleEvent {}

// States
abstract class TextBubbleBlocState {
  final String text;
  final List<dynamic>? formatters;
  final bool isFormatted;

  const TextBubbleBlocState({
    required this.text,
    this.formatters,
    this.isFormatted = false,
  });

  // Computed properties
  bool get hasText => text.isNotEmpty;
  bool get hasFormatters => formatters != null && formatters!.isNotEmpty;
}

class TextBubbleInitial extends TextBubbleBlocState {
  const TextBubbleInitial()
      : super(
          text: '',
          formatters: null,
          isFormatted: false,
        );
}

class TextBubbleLoaded extends TextBubbleBlocState {
  const TextBubbleLoaded({
    required super.text,
    super.formatters,
    super.isFormatted,
  });

  TextBubbleLoaded copyWith({
    String? text,
    List<dynamic>? formatters,
    bool? isFormatted,
  }) {
    return TextBubbleLoaded(
      text: text ?? this.text,
      formatters: formatters ?? this.formatters,
      isFormatted: isFormatted ?? this.isFormatted,
    );
  }
}

// BLoC
class TextBubbleBloc extends Bloc<TextBubbleEvent, TextBubbleBlocState> {
  TextBubbleBloc() : super(const TextBubbleInitial()) {
    on<InitializeTextEvent>(_onInitialize);
    on<UpdateTextEvent>(_onUpdateText);
    on<ApplyFormattersEvent>(_onApplyFormatters);
  }

  void _onInitialize(
    InitializeTextEvent event,
    Emitter<TextBubbleBlocState> emit,
  ) {
    emit(TextBubbleLoaded(
      text: event.text ?? '',
      formatters: event.formatters,
    ));

    // Apply formatters if available
    if (event.formatters != null && event.formatters!.isNotEmpty) {
      add(ApplyFormattersEvent());
    }
  }

  void _onUpdateText(
    UpdateTextEvent event,
    Emitter<TextBubbleBlocState> emit,
  ) {
    if (state is TextBubbleLoaded) {
      final currentState = state as TextBubbleLoaded;
      emit(currentState.copyWith(
        text: event.text,
        isFormatted: false,
      ));

      // Reapply formatters if available
      if (currentState.formatters != null && currentState.formatters!.isNotEmpty) {
        add(ApplyFormattersEvent());
      }
    }
  }

  void _onApplyFormatters(
    ApplyFormattersEvent event,
    Emitter<TextBubbleBlocState> emit,
  ) {
    if (state is TextBubbleLoaded) {
      final currentState = state as TextBubbleLoaded;
      emit(currentState.copyWith(isFormatted: true));
      
      // Actual formatting is done in the view layer using FormatterUtils
      // This event marks that formatters have been applied
    }
  }
}
