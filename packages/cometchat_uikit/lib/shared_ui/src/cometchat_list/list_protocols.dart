///Marker class to state predefined methods for CometChatList
mixin CometChatListProtocol<T1> {
  bool match(T1 elementA, T1 elementB);

  void loadMoreElements({bool Function(T1 element)? isIncluded});

  int getMatchingIndex(T1 element);

  void updateElement(T1 element, {int? index});

  void addElement(T1 element, {int index});

  void removeElement(T1 element);

  int getMatchingIndexFromKey(String key);

  //updateElementAt(T1 element, int index);

  void removeElementAt(int index);

  List<T1> getList();
}

///Abstract class to get the key in case of searching
mixin KeyIdentifier<T, T2> {
  T2 getKey(T element);
}

// abstract class CometChatReverseListProtocol<T>
//     extends CometChatListProtocol<T> {
//   loadPreviousElements({bool Function(T element)? isIncluded});
// }
