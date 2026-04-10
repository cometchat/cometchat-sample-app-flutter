import 'dart:async';
import '../../../data/models/suggestion_list_item.dart';

class MessageComposerSuggestions {
  // Create a stream controller
  static final StreamController<List<SuggestionListItem>> _controller =
      StreamController<List<SuggestionListItem>>();

  // Create a stream from the controller
  static Stream<List<SuggestionListItem>> get stream => _controller.stream;
}
