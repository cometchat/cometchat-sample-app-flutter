import 'package:cometchat_sdk/cometchat_sdk.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart' as cc;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../cometchat_uikit_shared.dart';

class CometchatFlagMessageController extends GetxController {
  CometchatFlagMessageController({this.flagReasonLocalizer});
  int? selectedReasonIndex;

  final TextEditingController textFieldController = TextEditingController();

  bool hasError = false;

  bool isLoading = false;

  String errorMessage = 'Something went wrong. Please check and try again.';

  late BuildContext context;

  Map<String, String> defaultTranslatedReasons = {};

  /// [flagReasonLocalizer] This function is used to localize the reason IDs to the desired language.
  final String Function(String reasonId)? flagReasonLocalizer;

  @override
  void onInit() {
    super.onInit();
    textFieldController.addListener(_onTextChanged);
    getReportReasons();
  }

  loadDefaultReasonTranslations() {
    defaultTranslatedReasons = {
      "spam": cc.Translations.of(context).spam,
      "sexual": cc.Translations.of(context).sexual,
      "harassment": cc.Translations.of(context).harassment,
    };
  }

  String getLocalizedReason({required String reasonId, String? reasonName}) {
    if (flagReasonLocalizer != null) {
      return flagReasonLocalizer!(reasonId);
    }
    // Fallback to default translations
    return defaultTranslatedReasons[reasonId] ?? reasonName ?? "";
  }

  getReportReasons() {
    CometChat.getFlagReasons(
      onSuccess: (reasons) {
        for (FlagReason reason in reasons) {
          reportReasons.add(reason);
          loadDefaultReasonTranslations();
        }
        update();
      },
      onError: (excep) {
        debugPrint("Error in fetching report reasons: ${excep.message}");
      },
    );
  }

  void _onTextChanged() {
    update();
  }

  // List of predefined reasons for reporting
  final List<FlagReason> reportReasons = [];

  bool get isReportEnabled => selectedReasonIndex != null;

  void updateIndex(int index) {
    if (selectedReasonIndex == index) {
      selectedReasonIndex = null; // unselect
    } else {
      selectedReasonIndex = index; // select new one
    }
    update();
  }

  @override
  void onClose() {
    textFieldController.removeListener(_onTextChanged);
    textFieldController.dispose();
    super.onClose();
  }

  reportMessage(BuildContext context, BaseMessage message) {
    if (selectedReasonIndex == null) {
      return;
    }
    isLoading = true;
    update();
    FlagDetail detail = FlagDetail(
        reasonId: reportReasons[selectedReasonIndex!].id,
        remark: textFieldController.text);
    CometChat.flagMessage(
      message.id,
      detail,
      onSuccess: (result) {
        final colorPalette = CometChatThemeHelper.getColorPalette(context);
        Navigator.pop(context, false);
        cc.SnackBarUtils.show(
            cc.Translations.of(context).messageReported, context,
            snackBarConfiguration: cc.SnackBarConfiguration(
              backgroundColor: colorPalette.success,
            ));
        isLoading = false;
        update();
      },
      onError: (excep) {
        hasError = true;
        errorMessage = excep.details ??
            cc.Translations.of(context).somethingWentWrongError;
        isLoading = false;
        update();
      },
    );
  }
}