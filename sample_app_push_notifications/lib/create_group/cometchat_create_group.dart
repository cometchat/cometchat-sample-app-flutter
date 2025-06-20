import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart' as cc;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'cometchat_create_group_controller.dart';

class CometChatCreateGroup extends StatefulWidget {
  const CometChatCreateGroup({Key? key}) : super(key: key);

  @override
  State<CometChatCreateGroup> createState() => _CometChatCreateGroupState();
}

class _CometChatCreateGroupState extends State<CometChatCreateGroup>
    with SingleTickerProviderStateMixin {
  late CometChatColorPalette colorPalette;
  late CometChatTypography typography;
  late CometChatSpacing spacing;

  late CometChatCreateGroupController createGroupController;

  @override
  void initState() {
    createGroupController = CometChatCreateGroupController();
    createGroupController.tabController = TabController(length: 3, vsync: this);
    createGroupController.tabController
        .addListener(createGroupController.tabControllerListener);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    typography = CometChatThemeHelper.getTypography(context);
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);
  }

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colorPalette.background1,
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(
          spacing.radius6 ?? 0,
        ),
      ),
      child: GetBuilder(
        init: createGroupController,
        tag: createGroupController.tag,
        builder: (CometChatCreateGroupController value) {
          return SafeArea(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorPalette.background1,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(
                      spacing.radius6 ?? 0,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    buildHeader(
                      context,
                      spacing,
                      typography,
                      colorPalette,
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: spacing.padding5 ?? 0,
                          left: spacing.padding6 ?? 0,
                          right: spacing.padding6 ?? 0,
                          bottom: spacing.padding10 ?? 0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: buildAvatar(
                                context,
                                spacing,
                                typography,
                                colorPalette,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: spacing.padding1 ?? 0,
                              ),
                              child: titleText(cc.Translations.of(context).type),
                            ),
                            buildTabs(value),
                            buildInputs(value),
                            (!value.isEmpty && !value.isError)
                                ? const SizedBox()
                                : Padding(
                                    padding: EdgeInsets.only(
                                      bottom: spacing.padding4 ?? 20,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: colorPalette.error?.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          spacing.radius2 ?? 8,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: spacing.padding2 ?? 8,
                                          vertical: spacing.padding1 ?? 4,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                right: spacing.padding1 ?? 2,
                                              ),
                                              child: Icon(
                                                Icons.error_outline,
                                                color: colorPalette.error,
                                                size: 16,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                (value.isEmpty)
                                                    ? cc.Translations.of(context).createGroupEmptyString
                                                    : (value.isError)
                                                        ? cc.Translations.of(context).somethingWrong
                                                        : "",
                                                style: TextStyle(
                                                  color: colorPalette.error,
                                                  fontSize: typography.caption1
                                                      ?.regular?.fontSize,
                                                  fontFamily: typography.caption1
                                                      ?.regular?.fontFamily,
                                                  fontWeight: typography.caption1
                                                      ?.regular?.fontWeight,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                            ElevatedButton(
                              onPressed: () {
                                if (value.groupName.isNotEmpty ||
                                    (value.groupType ==
                                            GroupTypeConstants.password &&
                                        value.groupPassword.isNotEmpty)) {
                                  value.onEmpty(false);
                                  value.createGroup(context, colorPalette, typography, spacing,);
                                } else {
                                  value.onEmpty(true);
                                }
                              },
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                  colorPalette.primary,
                                ),
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      spacing.radius2 ?? 8,
                                    ),
                                  ),
                                ),
                                padding: WidgetStateProperty.all(
                                  EdgeInsets.symmetric(
                                    vertical: spacing.padding2 ?? 8,
                                    horizontal: spacing.padding5 ?? 20,
                                  ),
                                ),
                              ),
                              child: Center(
                                child: (value.isLoading)
                                    ? CircularProgressIndicator(
                                        color: colorPalette.white,
                                      )
                                    : Text(
                                        cc.Translations.of(context).createGroup,
                                        style: TextStyle(
                                          color: colorPalette.buttonIconColor,
                                          fontSize: typography
                                              .button?.medium?.fontSize,
                                          fontFamily: typography
                                              .button?.medium?.fontFamily,
                                          fontWeight: typography
                                              .button?.medium?.fontWeight,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Header Widget
  Widget buildHeader(
    BuildContext context,
    CometChatSpacing spacing,
    CometChatTypography typography,
    CometChatColorPalette colorPalette,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        top: spacing.padding3 ?? 0,
      ),
      child: Container(
        height: 4,
        width: 32,
        decoration: BoxDecoration(
          color: colorPalette.neutral500,
          borderRadius: BorderRadius.circular(
            spacing.radiusMax ?? 0,
          ),
        ),
      ),
    );
  }

  // Header Widget
  Widget buildAvatar(
    BuildContext context,
    CometChatSpacing spacing,
    CometChatTypography typography,
    CometChatColorPalette colorPalette,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: spacing.padding6 ?? 0,
      ),
      child: Column(
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: colorPalette.background2,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.group_outlined,
              color: colorPalette.iconHighlight,
              size: 48,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: spacing.padding2 ?? 0,
            ),
            child: Text(
                cc.Translations.of(context).newGroup,
              style: TextStyle(
                fontFamily: typography.heading2?.medium?.fontFamily,
                fontSize: typography.heading2?.medium?.fontSize,
                color: colorPalette.textPrimary,
                fontWeight: typography.heading2?.medium?.fontWeight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTabs(CometChatCreateGroupController value) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: spacing.padding5 ?? 0,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(
          Radius.circular(
            spacing.radius2 ?? 8,
          ),
        ),
        child: Container(
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(
                spacing.radius2 ?? 8,
              ),
            ),
            color: colorPalette.background3,
          ),
          child: TabBar(
            controller: value.tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerHeight: 1,
            dividerColor: Colors.transparent,
            padding: EdgeInsets.zero,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(spacing.radius2 ?? 8),
              ),
              color: colorPalette.background1,
              border: Border.all(
                color: colorPalette.borderLight ?? Colors.transparent,
                width: 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 3.0,
                  offset: Offset(0, 1),
                ),
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 8.0,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            labelColor: colorPalette.textHighlight,
            unselectedLabelColor: colorPalette.textSecondary,
            tabs: [
              Tab(
                child: Text(
                    cc.Translations.of(context).public,
                ),
              ),
              Tab(
                child: Text(
                    cc.Translations.of(context).private,
                ),
              ),
              Tab(
                child: Text(
                  cc.Translations.of(context).password,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputs(CometChatCreateGroupController value) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleText(cc.Translations.of(context).name,),
          Padding(
            padding: EdgeInsets.only(
              bottom: spacing.padding5 ?? 0,
            ),
            child: textInput(
              nameController,
              cc.Translations.of(context).enterTheGroupName,
              value.onNameChange,
              false,
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: (value.groupType == GroupTypeConstants.password) ? 80 : 0,
            curve: Curves.easeInOut, // Animation curve
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleText(cc.Translations.of(context).password),
                  // Question TextField
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: spacing.padding5 ?? 0,
                    ),
                    child: textInput(
                      passwordController,
                      cc.Translations.of(context).enterTheGroupPassword,
                      value.onPasswordChange,
                      true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget titleText(String title) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: spacing.padding1 ?? 0,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: typography.caption1?.medium?.fontSize,
          fontWeight: typography.caption1?.medium?.fontWeight,
          fontFamily: typography.caption1?.medium?.fontFamily,
          color: colorPalette.textPrimary,
        ),
      ),
    );
  }

  Widget textInput(
    TextEditingController controller,
    String hintText,
    void Function(String)? onChanged,
      bool isPassword,
  ) {
    return TextFormField(
      textCapitalization: isPassword ? TextCapitalization.none : TextCapitalization.sentences,
      keyboardAppearance:
      CometChatThemeHelper.getBrightness(context),
      controller: controller,
      onTapOutside: (event) {
        if(FocusManager.instance.primaryFocus?.context != null){
          FocusScope.of(FocusManager.instance.primaryFocus!.context!).unfocus();
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "";
        }
        return null;
      },
      onChanged: onChanged,
      style: TextStyle(
        color: colorPalette.textPrimary,
        fontSize: typography.body?.regular?.fontSize,
        fontFamily: typography.body?.regular?.fontFamily,
        fontWeight: typography.body?.regular?.fontWeight,
      ),
      decoration: InputDecoration(
        errorStyle: const TextStyle(
          fontSize: 0,
        ),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          vertical: spacing.padding2 ?? 0,
          horizontal: spacing.padding2 ?? 0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            spacing.radius2 ?? 0,
          ),
          borderSide: BorderSide(
            width: 1,
            color: colorPalette.borderLight ?? Colors.transparent,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            spacing.radius2 ?? 0,
          ),
          borderSide: BorderSide(
            width: 1,
            color: colorPalette.borderLight ?? Colors.transparent,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            spacing.radius2 ?? 0,
          ),
          borderSide: BorderSide(
            width: 1,
            color: colorPalette.borderLight ?? Colors.transparent,
          ),
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: colorPalette.textTertiary,
          fontSize: typography.body?.regular?.fontSize,
          fontFamily: typography.body?.regular?.fontFamily,
          fontWeight: typography.body?.regular?.fontWeight,
        ),
        filled: true,
        fillColor: colorPalette.background2,
      ),
    );
  }
}

Future showCreateGroup({
  required BuildContext context,
  required CometChatColorPalette colorPalette,
  required CometChatTypography typography,
  required CometChatSpacing spacing,
}) {
  return showModalBottomSheet(
    backgroundColor: colorPalette.background1,
    context: context,
    isDismissible: true,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (BuildContext context) => Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: const Wrap(
        children: [
          IntrinsicHeight(
            child: CometChatCreateGroup(),
          ),
        ],
      ),
    ),
  );
}
