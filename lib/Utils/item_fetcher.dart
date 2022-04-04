//----------- fetch items like conversation list,user list ,etc.-----------
import 'package:cometchat/cometchat_sdk.dart';

class ItemFetcher<T> {
  Future<List<T>> fetchNext(dynamic request) async {
    final list = <T>[];

    List<T> res = await request.fetchNext(
        onSuccess: (List<T> conversations) {},
        onError: (CometChatException e) {});

    list.addAll(res);
    return list;
  }

  Future<List<T>> fetchPreviuos(dynamic request) async {
    final list = <T>[];

    List<T> res = await request.fetchPrevious(
        onSuccess: (List<T> messages) {}, onError: (CometChatException e) {});

    list.addAll(res);
    return list;
  }
}
