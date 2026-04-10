import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class ListBaseEvent extends Equatable {
  const ListBaseEvent();

  @override
  List<Object?> get props => [];
}

class InitializeList extends ListBaseEvent {
  const InitializeList();
}

class UpdateScrollVisibility extends ListBaseEvent {
  final bool showScrollToBottom;

  const UpdateScrollVisibility({required this.showScrollToBottom});

  @override
  List<Object?> get props => [showScrollToBottom];
}

class ScrollToTop extends ListBaseEvent {
  const ScrollToTop();
}

class ScrollToBottom extends ListBaseEvent {
  const ScrollToBottom();
}

// States
abstract class ListBaseState extends Equatable {
  final bool showScrollToBottom;
  final ScrollController scrollController;

  const ListBaseState({
    required this.showScrollToBottom,
    required this.scrollController,
  });

  @override
  List<Object?> get props => [showScrollToBottom];
}

class ListBaseInitial extends ListBaseState {
  ListBaseInitial()
      : super(
          showScrollToBottom: false,
          scrollController: ScrollController(),
        );
}

class ListBaseReady extends ListBaseState {
  const ListBaseReady({
    required super.showScrollToBottom,
    required super.scrollController,
  });
}

class ListBaseScrolling extends ListBaseState {
  const ListBaseScrolling({
    required super.showScrollToBottom,
    required super.scrollController,
  });
}

// BLoC
class ListBaseBloc extends Bloc<ListBaseEvent, ListBaseState> {
  late final ScrollController _scrollController;

  ListBaseBloc() : super(ListBaseInitial()) {
    _scrollController = state.scrollController;

    on<InitializeList>(_onInitialize);
    on<UpdateScrollVisibility>(_onUpdateScrollVisibility);
    on<ScrollToTop>(_onScrollToTop);
    on<ScrollToBottom>(_onScrollToBottom);

    _setupScrollListener();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;

      final showButton = _scrollController.offset > 100;
      if (showButton != state.showScrollToBottom) {
        add(UpdateScrollVisibility(showScrollToBottom: showButton));
      }
    });
  }

  Future<void> _onInitialize(
    InitializeList event,
    Emitter<ListBaseState> emit,
  ) async {
    emit(ListBaseReady(
      showScrollToBottom: false,
      scrollController: _scrollController,
    ));
  }

  Future<void> _onUpdateScrollVisibility(
    UpdateScrollVisibility event,
    Emitter<ListBaseState> emit,
  ) async {
    emit(ListBaseReady(
      showScrollToBottom: event.showScrollToBottom,
      scrollController: _scrollController,
    ));
  }

  Future<void> _onScrollToTop(
    ScrollToTop event,
    Emitter<ListBaseState> emit,
  ) async {
    if (_scrollController.hasClients) {
      emit(ListBaseScrolling(
        showScrollToBottom: state.showScrollToBottom,
        scrollController: _scrollController,
      ));

      await _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );

      emit(ListBaseReady(
        showScrollToBottom: false,
        scrollController: _scrollController,
      ));
    }
  }

  Future<void> _onScrollToBottom(
    ScrollToBottom event,
    Emitter<ListBaseState> emit,
  ) async {
    if (_scrollController.hasClients) {
      emit(ListBaseScrolling(
        showScrollToBottom: state.showScrollToBottom,
        scrollController: _scrollController,
      ));

      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );

      emit(ListBaseReady(
        showScrollToBottom: state.showScrollToBottom,
        scrollController: _scrollController,
      ));
    }
  }

  @override
  Future<void> close() {
    _scrollController.dispose();
    return super.close();
  }
}
