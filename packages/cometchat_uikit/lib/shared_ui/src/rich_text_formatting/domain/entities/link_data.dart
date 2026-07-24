import 'package:equatable/equatable.dart';

/// Immutable entity representing link data for hyperlink formatting.
///
/// Contains the URL and the display text for a link.
class LinkData extends Equatable {
  /// The URL that the link points to
  final String url;

  /// The text to display for the link
  final String displayText;

  /// Creates a [LinkData] with the specified URL and display text.
  const LinkData({required this.url, required this.displayText});

  @override
  List<Object?> get props => [url, displayText];

  @override
  String toString() {
    return 'LinkData(url: $url, displayText: $displayText)';
  }
}
