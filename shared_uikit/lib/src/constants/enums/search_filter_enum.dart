enum SearchFilter {
  unread('unread'),
  groups('groups'),
  photos('photos'),
  videos('videos'),
  links('links'),
  documents('files'),
  audio('audio');

  final String value;

  const SearchFilter(this.value);

  @override
  String toString() => value;

  static SearchFilter? fromValue(String value) {
    try {
      return SearchFilter.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }
}
