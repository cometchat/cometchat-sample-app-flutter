import '../../../../cometchat_uikit_shared.dart';

abstract class CometChatDetailsControllerProtocol {
  int updateOption(
    String templateId,
    String oldOptionID,
    CometChatDetailsOption updatedOption,
  );

  int removeOption(String templateId, String optionId);

  int addOption(
    String templateId,
    CometChatDetailsOption newOption, {
    int? position,
  });

  void useOption(CometChatDetailsOption option, String sectionId);

  void onAddMemberClicked(Group group);

  void onTransferOwnershipClicked(Group group);

  void onBanMemberClicked(Group group);

  void onViewMemberClicked(Group group);

  List<CometChatDetailsTemplate> getDetailsTemplateList();

  Map<String, List<CometChatDetailsOption>> getDetailsOptionMap();
}
