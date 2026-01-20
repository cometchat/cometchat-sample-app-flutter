import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

///An abstract class which holds the logic for searching in different lists
abstract class CometChatMessageSearchListController<T1, T2>
    extends CometchatMessageList<T1, T2>
    implements CometChatSearchListControllerProtocol<T1> {
  String? searchKeyword;
  final _deBouncer = Debouncer(milliseconds: 500);
  BuilderProtocol builderProtocol;

  CometChatMessageSearchListController({
    required this.builderProtocol,
    String? searchKeyword,
    Function(Exception)? onError,
    bool isFetchNext = true,
    OnLoad<T1>? onLoad,
    OnEmpty? onEmpty,
  }) : super(
          searchKeyword != null && searchKeyword != ''
              ? builderProtocol.getSearchRequest(searchKeyword)
              : builderProtocol.getRequest(),
          onError: onError,
          isFetchNext: isFetchNext,
          onEmpty: onEmpty,
          onLoad: onLoad,
        );

  @override
  onSearch(String val) {
    _deBouncer.run(() {
      request = builderProtocol.getSearchRequest(val);
      list = [];
      isLoading = true;
      update();
      loadMoreElements();
    });
  }
}
