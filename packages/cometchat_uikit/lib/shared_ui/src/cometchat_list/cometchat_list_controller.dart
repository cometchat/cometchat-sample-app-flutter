import 'list_protocols.dart';
import 'package:flutter/foundation.dart';

import '../constants/ui_kit_constants.dart';

/// Generic exception class to replace SDK-specific exceptions
class CometChatListException implements Exception {
  final String code;
  final String message;
  final String? details;

  CometChatListException(this.code, this.message, [this.details]);

  @override
  String toString() => 'CometChatListException($code): $message${details != null ? ' - $details' : ''}';
}

///Common Controller Class which holds the logic to fetch data from different request builders
///
/// Migrated from GetxController to ChangeNotifier.
/// Provides [update], [onInit], and [onClose] lifecycle stubs for backward
/// compatibility with subclasses that previously relied on GetxController.
abstract class CometChatListController<T1, T2> extends ChangeNotifier
    with CometChatListProtocol<T1>, KeyIdentifier<T1, T2> {
  List<T1> list = [];
  bool isLoading = true;
  bool hasMoreItems = true;
  bool hasError = false;
  Exception? error;
  late dynamic request;
  Function(Exception)? onError;
  bool isFetchNext = true;

  /// Callback when data is successfully loaded
  OnLoad<T1>? onLoad;

  /// Callback when the list is empty
  OnEmpty? onEmpty;

  CometChatListController(this.request,
      {this.onError, this.isFetchNext = true, this.onLoad, this.onEmpty});

  // ---------------------------------------------------------------------------
  // Lifecycle stubs — replaces GetxController's onInit / onClose / update
  // ---------------------------------------------------------------------------

  /// Notifies listeners (replaces GetxController.update).
  void update() {
    notifyListeners();
  }

  /// Lifecycle hook called after construction.
  /// Subclasses should call `super.onInit()`.
  void onInit() {
    loadMoreElements();
  }

  /// Lifecycle hook called before disposal.
  /// Subclasses should call `super.onClose()`.
  void onClose() {}

  @override
  void dispose() {
    onClose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------

  @override
  List<T1> getList() {
    return list;
  }

  @override
  int getMatchingIndex(T1 element) {
    int matchingIndex = list.indexWhere((item) => match(item, element));
    return matchingIndex;
  }

  @override
  int getMatchingIndexFromKey(String key) {
    int matchingIndex = list.indexWhere((item) => getKey(item) == key);
    return matchingIndex;
  }

  // Commented out as it's not currently used, but kept for potential future use
  // ignore: unused_element
  void _onSuccess(List<T1> fetchedList, bool Function(T1 element)? isIncluded) {
    if (fetchedList.isEmpty) {
      isLoading = false;
      hasMoreItems = false;
      onEmpty?.call();
      update();
    } else {
      isLoading = false;
      hasMoreItems = true;

      if (isIncluded == null) {
        list.addAll(fetchedList);
      } else {
        for (var element in fetchedList) {
          if (isIncluded(element) == true) {
            list.add(element);
          }
        }
      }

      onLoad?.call(list);
      update();
    }
  }

  _onError(CometChatListException e) {
    if (kDebugMode) {
      print("Error ${e.details}");
    }
    error = e;
    hasError = true;
    update();
  }

  @override
  loadMoreElements({bool Function(T1 element)? isIncluded}) async {
    isLoading = true;
    try {
      if (isFetchNext) {
        await request.fetchNext(
          onSuccess: (List<T1> fetchedList) {
            if (fetchedList.isEmpty) {
              isLoading = false;
              hasMoreItems = false;

              /// Call `onEmpty` when no data is found
              onEmpty?.call();
            } else {
              isLoading = false;
              hasMoreItems = true;

              if (isIncluded == null) {
                list.addAll(fetchedList);
              } else {
                for (var element in fetchedList) {
                  if (isIncluded(element) == true) {
                    list.add(element);
                  }
                }
              }

              /// Call `onLoad` when data is successfully loaded
              onLoad?.call(list);
            }

            update();
          },
          onError: (e) {
            _onError(e);
            onError?.call(e);
          },
        );
      } else {
        await request.fetchPrevious(
          onSuccess: (List<T1> fetchedList) {
            if (fetchedList.isEmpty) {
              isLoading = false;
              hasMoreItems = false;

              /// Call `onEmpty` when no data is found
              onEmpty?.call();
            } else {
              isLoading = false;
              hasMoreItems = true;

              if (isIncluded == null) {
                list.addAll(fetchedList);
              } else {
                for (var element in fetchedList) {
                  if (isIncluded(element) == true) {
                    list.add(element);
                  }
                }
              }

              /// Call `onLoad` when data is successfully loaded
              onLoad?.call(list);
            }

            update();
          },
          onError: (e) {
            _onError(e);
            onError?.call(e);
          },
        );
      }
    } catch (e, s) {
      if (kDebugMode) {
        print("Error in Catch: $e");
      }
      error = CometChatListException("ERR", s.toString(), "Error");
      hasError = true;
      isLoading = false;
      hasMoreItems = false;
      update();
    }
  }


  @override
  updateElement(T1 element, {int? index}) {
    int result;
    if (index == null) {
      result = getMatchingIndex(element);
    } else {
      result = index;
    }

    if (result != -1) {
      list[result] = element;
      update();
    }
  }

  @override
  addElement(T1 element, {int index = 0}) {
    list.insert(index, element);
    update();
  }

  @override
  removeElement(T1 element) {
    int matchingIndex = getMatchingIndex(element);
    if (matchingIndex != -1) {
      list.removeAt(matchingIndex);
      update();
    }
  }

  updateElementAt(T1 element, int index) {
    list[index] = element;
    update();
  }

  @override
  removeElementAt(int index) {
    list.removeAt(index);
    update();
  }
}
