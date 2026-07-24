import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "../../../../clean_architecture.dart";

// Events
abstract class ReactionsEvent extends Equatable {
  const ReactionsEvent();

  @override
  List<Object?> get props => [];
}

class UpdateReactions extends ReactionsEvent {
  final List<ReactionCount> reactions;

  const UpdateReactions({required this.reactions});

  @override
  List<Object?> get props => [reactions];
}

class AnimateReaction extends ReactionsEvent {
  final String reaction;

  const AnimateReaction({required this.reaction});

  @override
  List<Object?> get props => [reaction];
}

// States
abstract class ReactionsState extends Equatable {
  final List<ReactionCount> reactionList;
  final String? animatingReaction;

  const ReactionsState({required this.reactionList, this.animatingReaction});

  List<ReactionCount> get visibleReactions {
    if (reactionList.length > 4) {
      return reactionList.take(3).toList();
    }
    return reactionList;
  }

  bool get hasMore => reactionList.length > 4;

  int get extraCount => reactionList.length > 4 ? reactionList.length - 3 : 0;

  bool get extraReactedByMe {
    if (reactionList.length > 4) {
      return reactionList
          .sublist(3)
          .any((element) => element.reactedByMe == true);
    }
    return false;
  }

  @override
  List<Object?> get props => [reactionList, animatingReaction];
}

class ReactionsInitial extends ReactionsState {
  const ReactionsInitial({required super.reactionList});
}

class ReactionsUpdated extends ReactionsState {
  const ReactionsUpdated({required super.reactionList});
}

class ReactionsAnimating extends ReactionsState {
  const ReactionsAnimating({
    required super.reactionList,
    required super.animatingReaction,
  });
}

// BLoC
class ReactionsBloc extends Bloc<ReactionsEvent, ReactionsState> {
  ReactionsBloc({required List<ReactionCount> initialReactions})
    : super(ReactionsInitial(reactionList: initialReactions)) {
    on<UpdateReactions>(_onUpdateReactions);
    on<AnimateReaction>(_onAnimateReaction);
  }

  Future<void> _onUpdateReactions(
    UpdateReactions event,
    Emitter<ReactionsState> emit,
  ) async {
    emit(ReactionsUpdated(reactionList: event.reactions));
  }

  Future<void> _onAnimateReaction(
    AnimateReaction event,
    Emitter<ReactionsState> emit,
  ) async {
    emit(
      ReactionsAnimating(
        reactionList: state.reactionList,
        animatingReaction: event.reaction,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 300));

    emit(ReactionsUpdated(reactionList: state.reactionList));
  }
}
