enum SearchScope {
  conversations('conversations'),
  messages('messages');

  final String value;

  const SearchScope(this.value);

  @override
  String toString() => value;

  static SearchScope? fromValue(String value) {
    try {
      return SearchScope.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }
}
