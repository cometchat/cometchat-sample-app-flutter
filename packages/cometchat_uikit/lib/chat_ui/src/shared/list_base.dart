/// A generic mixin providing list management operations for BLoC classes.
///
/// This mixin can be mixed into any BLoC to provide reusable list operations
/// with customizable hooks that can be overridden for custom behavior.
///
/// Example usage:
/// ```dart
/// class MyBloc extends Bloc<MyEvent, MyState> with ListBase<MyItem> {
///   @override
///   void onItemAdded(MyItem item, List<MyItem> updatedList) {
///     // Custom logic when item is added
///     emit(MyState(items: updatedList));
///   }
/// }
/// ```
mixin ListBase<T> {
  /// Internal list storage
  List<T> _items = [];

  /// Returns an unmodifiable view of the current items
  List<T> get items => List.unmodifiable(_items);

  /// Returns the number of items in the list
  int get itemCount => _items.length;

  /// Returns true if the list is empty
  bool get isEmpty => _items.isEmpty;

  /// Returns true if the list is not empty
  bool get isNotEmpty => _items.isNotEmpty;

  // ============================================================
  // BASIC OPERATIONS
  // ============================================================

  /// Adds an item to the end of the list.
  /// Calls [onItemAdded] hook after adding.
  void addItem(T item) {
    final updatedList = [..._items, item];
    _items = updatedList;
    onItemAdded(item, updatedList);
  }

  /// Removes a specified item from the list.
  /// Calls [onItemRemoved] hook after removing.
  /// Returns true if item was found and removed.
  bool removeItem(T item) {
    if (!_items.contains(item)) return false;
    final updatedList = _items.where((e) => e != item).toList();
    _items = updatedList;
    onItemRemoved(item, updatedList);
    return true;
  }

  /// Adds multiple items to the end of the list.
  /// Calls [onItemAdded] hook for each item.
  void addAllItems(List<T> itemsToAdd) {
    if (itemsToAdd.isEmpty) return;
    final updatedList = [..._items, ...itemsToAdd];
    _items = updatedList;
    for (final item in itemsToAdd) {
      onItemAdded(item, updatedList);
    }
  }

  /// Removes an item at a specific index.
  /// Returns the removed item, or null if index is out of bounds.
  T? removeItemAt(int index) {
    if (index < 0 || index >= _items.length) return null;
    final item = _items[index];
    final updatedList = [..._items]..removeAt(index);
    _items = updatedList;
    onItemRemoved(item, updatedList);
    return item;
  }

  /// Updates an item at a specific index.
  /// Returns true if update was successful.
  bool updateItem(int index, T newItem) {
    if (index < 0 || index >= _items.length) return false;
    final oldItem = _items[index];
    final updatedList = [..._items];
    updatedList[index] = newItem;
    _items = updatedList;
    onItemUpdated(oldItem, newItem, updatedList);
    return true;
  }

  /// Inserts an item at a specific index.
  /// Returns true if insertion was successful.
  bool insertItemAt(int index, T newItem) {
    if (index < 0 || index > _items.length) return false;
    final updatedList = [..._items]..insert(index, newItem);
    _items = updatedList;
    onItemAdded(newItem, updatedList);
    return true;
  }

  /// Adds items at the beginning of the list.
  void addAllItemsAtStart(List<T> itemsToAdd) {
    if (itemsToAdd.isEmpty) return;
    final updatedList = [...itemsToAdd, ..._items];
    _items = updatedList;
    for (final item in itemsToAdd) {
      onItemAdded(item, updatedList);
    }
  }

  /// Clears all items from the list.
  void clearItems() {
    final previousList = [..._items];
    _items = [];
    onListCleared(previousList);
  }

  // ============================================================
  // ADVANCED OPERATIONS
  // ============================================================

  /// Swaps two items at the specified indices.
  /// Returns true if swap was successful.
  bool swapItems(int index1, int index2) {
    if (index1 < 0 || index1 >= _items.length) return false;
    if (index2 < 0 || index2 >= _items.length) return false;
    final updatedList = [..._items];
    final temp = updatedList[index1];
    updatedList[index1] = updatedList[index2];
    updatedList[index2] = temp;
    _items = updatedList;
    onItemUpdated(updatedList[index2], updatedList[index1], updatedList);
    return true;
  }

  /// Replaces all items with a new list.
  void replaceAll(List<T> newItems) {
    final previousList = [..._items];
    _items = [...newItems];
    onListReplaced(previousList, _items);
  }

  /// Finds the first item matching the predicate.
  /// Returns null if no item matches.
  T? findFirst(bool Function(T) predicate) {
    for (final item in _items) {
      if (predicate(item)) return item;
    }
    return null;
  }

  /// Finds the index of the first item matching the predicate.
  /// Returns -1 if no item matches.
  int findIndex(bool Function(T) predicate) {
    for (int i = 0; i < _items.length; i++) {
      if (predicate(_items[i])) return i;
    }
    return -1;
  }

  /// Filters items based on a predicate.
  /// Removes items that don't match the predicate.
  void filterItems(bool Function(T) predicate) {
    final previousList = [..._items];
    final updatedList = _items.where(predicate).toList();
    _items = updatedList;
    onListReplaced(previousList, updatedList);
  }

  /// Checks if the list contains a specified item.
  bool containsItem(T item) {
    return _items.contains(item);
  }

  /// Removes items that match the predicate.
  void removeIf(bool Function(T) predicate) {
    final itemsToRemove = _items.where(predicate).toList();
    if (itemsToRemove.isEmpty) return;
    final updatedList = _items.where((e) => !predicate(e)).toList();
    _items = updatedList;
    for (final item in itemsToRemove) {
      onItemRemoved(item, updatedList);
    }
  }

  /// Reverses the order of items in the list.
  void reverse() {
    final previousList = [..._items];
    _items = _items.reversed.toList();
    onListReplaced(previousList, _items);
  }

  /// Retrieves an item at a specific index safely.
  /// Returns null if index is out of bounds.
  T? getItemAt(int index) {
    if (index < 0 || index >= _items.length) return null;
    return _items[index];
  }

  /// Replaces the first occurrence of an item with a new item.
  /// Returns true if replacement was successful.
  bool replaceFirst(T oldItem, T newItem) {
    final index = _items.indexOf(oldItem);
    if (index < 0) return false;
    return updateItem(index, newItem);
  }

  /// Adds an item only if it doesn't already exist in the list.
  /// Returns true if item was added.
  bool addUniqueItem(T item) {
    if (_items.contains(item)) return false;
    addItem(item);
    return true;
  }

  /// Updates the first item matching the predicate.
  /// Returns true if update was successful.
  bool updateItemWhere(bool Function(T) predicate, T newItem) {
    final index = findIndex(predicate);
    if (index < 0) return false;
    return updateItem(index, newItem);
  }

  /// Moves an item from one index to another.
  /// Returns true if move was successful.
  bool moveItem(int fromIndex, int toIndex) {
    if (fromIndex < 0 || fromIndex >= _items.length) return false;
    if (toIndex < 0 || toIndex >= _items.length) return false;
    final previousList = [..._items];
    final item = _items[fromIndex];
    final updatedList = [..._items]..removeAt(fromIndex);
    updatedList.insert(toIndex, item);
    _items = updatedList;
    onListReplaced(previousList, updatedList);
    return true;
  }

  // ============================================================
  // OVERRIDE HOOKS
  // ============================================================

  /// Called when an item is added to the list.
  /// Override this method to add custom logic after item addition.
  ///
  /// [item] - The item that was added
  /// [updatedList] - The list after the item was added
  void onItemAdded(T item, List<T> updatedList) {}

  /// Called when an item is removed from the list.
  /// Override this method to add custom logic after item removal.
  ///
  /// [item] - The item that was removed
  /// [updatedList] - The list after the item was removed
  void onItemRemoved(T item, List<T> updatedList) {}

  /// Called when an item is updated in the list.
  /// Override this method to add custom logic after item update.
  ///
  /// [oldItem] - The item before update
  /// [newItem] - The item after update
  /// [updatedList] - The list after the update
  void onItemUpdated(T oldItem, T newItem, List<T> updatedList) {}

  /// Called when the list is cleared.
  /// Override this method to add custom logic after list clear.
  ///
  /// [previousList] - The list before it was cleared
  void onListCleared(List<T> previousList) {}

  /// Called when the entire list is replaced.
  /// Override this method to add custom logic after list replacement.
  ///
  /// [previousList] - The list before replacement
  /// [newList] - The new list after replacement
  void onListReplaced(List<T> previousList, List<T> newList) {}
}
