import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "../../../../clean_architecture.dart";
import 'package:flutter/material.dart';

// Events
abstract class CardBubbleEvent extends Equatable {
  const CardBubbleEvent();

  @override
  List<Object?> get props => [];
}

class InitializeCard extends CardBubbleEvent {
  final CardMessage cardMessage;
  final User? loggedInUser;

  const InitializeCard({
    required this.cardMessage,
    this.loggedInUser,
  });

  @override
  List<Object?> get props => [cardMessage, loggedInUser];
}

class ButtonClicked extends CardBubbleEvent {
  final ButtonElement button;
  final String elementId;
  final BuildContext context;

  const ButtonClicked({
    required this.button,
    required this.elementId,
    required this.context,
  });

  @override
  List<Object?> get props => [button, elementId, context];
}

class MarkInteracted extends CardBubbleEvent {
  final BaseInteractiveElement interactiveElement;

  const MarkInteracted({required this.interactiveElement});

  @override
  List<Object?> get props => [interactiveElement];
}

// States
abstract class CardBubbleState extends Equatable {
  final Map<String, bool> interactionMap;
  final bool isSentByMe;

  const CardBubbleState({
    required this.interactionMap,
    required this.isSentByMe,
  });

  bool isInteracted(String elementId) => interactionMap[elementId] ?? false;

  @override
  List<Object?> get props => [interactionMap, isSentByMe];
}

class CardBubbleInitial extends CardBubbleState {
  const CardBubbleInitial()
      : super(
          interactionMap: const {},
          isSentByMe: false,
        );
}

class CardBubbleLoaded extends CardBubbleState {
  const CardBubbleLoaded({
    required super.interactionMap,
    required super.isSentByMe,
  });
}

class CardBubbleSubmitting extends CardBubbleState {
  const CardBubbleSubmitting({
    required super.interactionMap,
    required super.isSentByMe,
  });
}

class CardBubbleSuccess extends CardBubbleState {
  const CardBubbleSuccess({
    required super.interactionMap,
    required super.isSentByMe,
  });
}

class CardBubbleError extends CardBubbleState {
  final String error;

  const CardBubbleError({
    required this.error,
    required super.interactionMap,
    required super.isSentByMe,
  });

  @override
  List<Object?> get props => [error, interactionMap, isSentByMe];
}

// BLoC
class CardBubbleBloc extends Bloc<CardBubbleEvent, CardBubbleState> {
  final CardMessage cardMessage;

  CardBubbleBloc({required this.cardMessage})
      : super(const CardBubbleInitial()) {
    on<InitializeCard>(_onInitialize);
    on<ButtonClicked>(_onButtonClicked);
    on<MarkInteracted>(_onMarkInteracted);
  }

  Future<void> _onInitialize(
    InitializeCard event,
    Emitter<CardBubbleState> emit,
  ) async {
    // Initialize interaction map
    final interactionMap = <String, bool>{};
    if (event.cardMessage.interactions != null) {
      for (var element in event.cardMessage.interactions!) {
        interactionMap[element.elementId] = true;
      }
    }

    final isSentByMe = InteractiveMessageUtils.checkIsSentByMe(
      event.loggedInUser,
      event.cardMessage,
    );

    emit(CardBubbleLoaded(
      interactionMap: interactionMap,
      isSentByMe: isSentByMe,
    ));
  }

  Future<void> _onButtonClicked(
    ButtonClicked event,
    Emitter<CardBubbleState> emit,
  ) async {
    emit(CardBubbleSubmitting(
      interactionMap: state.interactionMap,
      isSentByMe: state.isSentByMe,
    ));

    try {
      final status = await ActionElementUtils.performAction(
        element: event.button,
        messageId: cardMessage.id,
        context: event.context,
      );

      if (status == true) {
        add(MarkInteracted(interactiveElement: event.button));
      } else {
        emit(CardBubbleLoaded(
          interactionMap: state.interactionMap,
          isSentByMe: state.isSentByMe,
        ));
      }
    } catch (e) {
      emit(CardBubbleError(
        error: e.toString(),
        interactionMap: state.interactionMap,
        isSentByMe: state.isSentByMe,
      ));
    }
  }

  Future<void> _onMarkInteracted(
    MarkInteracted event,
    Emitter<CardBubbleState> emit,
  ) async {
    await InteractiveMessageUtils.markInteracted(
      event.interactiveElement,
      cardMessage,
      state.interactionMap,
      onSuccess: (bool matched) {
        final updatedMap = Map<String, bool>.from(state.interactionMap);
        updatedMap[event.interactiveElement.elementId] = true;

        emit(CardBubbleSuccess(
          interactionMap: updatedMap,
          isSentByMe: state.isSentByMe,
        ));
      },
    );
  }
}
