import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../cometchat_uikit_shared.dart';
import '../../../cometchat_uikit_shared.dart' as cc;

class CometChatFlagMessage extends StatefulWidget {
  const CometChatFlagMessage({
    required this.message,
    this.style,
    this.actionsPadding,
    this.contentPadding,
    this.titlePadding,
    this.flagReasonLocalizer,
    this.hideFlagRemarkField,
    super.key,
  });

  /// [message] The message object to be reported
  final BaseMessage message;

  /// [style] to customize the appearance of the flag message dialog
  final CometchatFlagMessageStyle? style;

  /// [contentPadding] provides padding to the content of the flag message dialog
  final EdgeInsetsGeometry? contentPadding;

  /// [titlePadding] provides padding to the title of the flag message dialog
  final EdgeInsetsGeometry? titlePadding;

  /// [actionsPadding] provides padding to the actions of the flag message dialog
  final EdgeInsetsGeometry? actionsPadding;

  /// [flagReasonLocalizer] This function is used to localize the reason IDs to the desired language.
  final String Function(String reasonId)? flagReasonLocalizer;

  /// [hideFlagRemarkField] This prop defines whether to hide the remark field in the flag message option.
  final bool? hideFlagRemarkField;

  @override
  State<CometChatFlagMessage> createState() => _CometChatFlagMessageState();
}

class _CometChatFlagMessageState extends State<CometChatFlagMessage> {
  late CometchatFlagMessageController flagMessageController;
  late String _currentDateTime;

  @override
  void initState() {
    _currentDateTime = DateTime.now().millisecondsSinceEpoch.toString();
    flagMessageController = CometchatFlagMessageController(
      flagReasonLocalizer: widget.flagReasonLocalizer,
    );
    super.initState();
  }

  late CometChatColorPalette colorPalette;
  late CometChatSpacing spacing;
  late CometChatTypography typography;
  late CometchatFlagMessageStyle flagMessageStyle;

  @override
  void didChangeDependencies() {
    flagMessageStyle = CometChatThemeHelper.getTheme<CometchatFlagMessageStyle>(
            context: context, defaultTheme: CometchatFlagMessageStyle.of)
        .merge(widget.style);

    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);
    typography = CometChatThemeHelper.getTypography(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CometchatFlagMessageController>(
      tag: "default_tag_flag_message$_currentDateTime",
      init: flagMessageController,
      builder: (controller) {
        controller.context = context;
        final bool isReportButtonEnabled = controller.isReportEnabled;
        return AlertDialog(
          backgroundColor:
              flagMessageStyle.backgroundColor ?? colorPalette.background1,
          shape: RoundedRectangleBorder(
            borderRadius: flagMessageStyle.borderRadius ??
                BorderRadius.circular(
                  spacing.radius5 ?? 0,
                ),
            side: flagMessageStyle.border ??
                BorderSide(
                  color: colorPalette.borderLight ?? Colors.transparent,
                ),
          ),
          contentPadding: widget.contentPadding ??
              EdgeInsets.only(
                top: spacing.padding3 ?? 0,
                left: spacing.padding5 ?? 0,
                right: spacing.padding5 ?? 0,
              ),
          titlePadding: widget.titlePadding ??
              EdgeInsets.symmetric(
                vertical: spacing.padding4 ?? 0,
                horizontal: spacing.padding4 ?? 0,
              ),
          actionsPadding: widget.actionsPadding ??
              EdgeInsets.all(
                spacing.padding5 ?? 0,
              ),
          actionsAlignment: MainAxisAlignment.center,
          title: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  bottom: spacing.padding2 ?? 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      cc.Translations.of(context).reportMessage,
                      style: TextStyle(
                        color: colorPalette.textPrimary,
                        fontSize: typography.heading2?.bold?.fontSize,
                        fontWeight: typography.heading2?.bold?.fontWeight,
                        fontFamily: typography.heading2?.bold?.fontFamily,
                      )
                          .merge(
                            flagMessageStyle.titleTextStyle,
                          )
                          .copyWith(
                            color: flagMessageStyle.titleTextColor ??
                                colorPalette.textPrimary,
                          ),
                    ),
                    GestureDetector(
                      child: Icon(
                        Icons.close,
                        color: flagMessageStyle.closeIconTint ??
                            colorPalette.iconPrimary,
                        size: 24,
                      ),
                      onTap: () => Navigator.pop(context, false),
                    ),
                  ],
                ),
              ),
              Text(
                cc.Translations.of(context).reportChatInfo,
                style: TextStyle(
                  color: colorPalette.textSecondary,
                  fontSize: typography.button?.regular?.fontSize,
                  fontWeight: typography.button?.regular?.fontWeight,
                  fontFamily: typography.button?.regular?.fontFamily,
                )
                    .merge(
                      flagMessageStyle.subTitleTextStyle,
                    )
                    .copyWith(
                      color: flagMessageStyle.subTitleTextColor ??
                          colorPalette.textSecondary,
                    ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: (widget.hideFlagRemarkField == false)
                          ? (spacing.padding6 ?? 0)
                          : 0,
                    ),
                    child: Wrap(
                      spacing: spacing.spacing2 ?? 8, // horizontal spacing
                      runSpacing: spacing.spacing2 ?? 8, // vertical spacing
                      children: List.generate(
                        controller.reportReasons.length,
                        (index) {
                          final isSelected =
                              controller.selectedReasonIndex == index;
                          return GestureDetector(
                            onTap: () {
                              controller.updateIndex(index);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: spacing.padding1 ?? 6,
                                horizontal: spacing.padding3 ?? 12,
                              ),
                              decoration: BoxDecoration(
                                color: (isSelected == true)
                                    ? (flagMessageStyle
                                            .chipActiveBackgroundColor ??
                                        colorPalette.extendedPrimary100)
                                    : (flagMessageStyle.chipBackgroundColor ??
                                        colorPalette.background1),
                                border: (flagMessageStyle.chipActiveBorder !=
                                            null &&
                                        isSelected == true)
                                    ? flagMessageStyle.chipActiveBorder
                                    : (flagMessageStyle.chipBorder ??
                                        Border.all(
                                          color: ((isSelected == true)
                                                  ? colorPalette
                                                      .extendedPrimary200
                                                  : colorPalette
                                                      .borderDefault) ??
                                              Colors.transparent,
                                        )),
                                borderRadius: (flagMessageStyle
                                                .chipActiveBorderRadius !=
                                            null &&
                                        isSelected == true)
                                    ? flagMessageStyle.chipActiveBorderRadius
                                    : (flagMessageStyle.chipBorderRadius ??
                                        BorderRadius.circular(
                                          spacing.radiusMax ?? 0,
                                        )),
                              ),
                              child: Text(
                                  controller.defaultTranslatedReasons
                                          .containsKey(controller
                                              .reportReasons[index].id
                                              .toLowerCase())
                                      ? controller.defaultTranslatedReasons[
                                          controller.reportReasons[index].id
                                              .toLowerCase()]!
                                      : (controller.getLocalizedReason(
                                          reasonId: controller
                                              .reportReasons[index].id,
                                          reasonName: controller
                                              .reportReasons[index].name)),
                                  style: (flagMessageStyle
                                                  .chipActiveTitleTextStyle !=
                                              null &&
                                          isSelected == true)
                                      ? flagMessageStyle
                                          .chipActiveTitleTextStyle
                                      : TextStyle(
                                          color: ((isSelected == true)
                                              ? (flagMessageStyle
                                                      .chipActiveTitleTextColor ??
                                                  colorPalette.textHighlight)
                                              : (flagMessageStyle
                                                      .chipTitleTextColor ??
                                                  colorPalette.textPrimary)),
                                          fontSize: typography
                                              .button?.regular?.fontSize,
                                          fontWeight: typography
                                              .button?.regular?.fontWeight,
                                          fontFamily: typography
                                              .button?.regular?.fontFamily,
                                        )
                                          .merge(
                                            flagMessageStyle.chipTitleTextStyle,
                                          )
                                          .copyWith(
                                            color: isSelected
                                                ? (flagMessageStyle
                                                        .chipActiveTitleTextColor ??
                                                    colorPalette.textHighlight)
                                                : (flagMessageStyle
                                                        .chipTitleTextColor ??
                                                    colorPalette.textPrimary),
                                          )),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if (widget.hideFlagRemarkField == false)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: spacing.padding1 ?? 0,
                      ),
                      child: Text.rich(
                        TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: cc.Translations.of(context)
                                  .reason, // Note the space here
                              style: TextStyle(
                                color: colorPalette.textPrimary,
                                fontSize: typography.body?.medium?.fontSize,
                                fontWeight: typography.body?.medium?.fontWeight,
                                fontFamily: typography.body?.medium?.fontFamily,
                              )
                                  .merge(flagMessageStyle
                                      .remarkFieldTitleTextStyle)
                                  .copyWith(
                                      color: flagMessageStyle
                                          .remarkFieldTitleTextColor),
                            ),
                            TextSpan(
                              text:
                                  ' (${cc.Translations.of(context).optional})', // Note the space here
                              style: TextStyle(
                                color: colorPalette.textTertiary,
                                fontSize: typography.body?.regular?.fontSize,
                                fontWeight:
                                    typography.body?.regular?.fontWeight,
                                fontFamily:
                                    typography.body?.regular?.fontFamily,
                              )
                                  .merge(flagMessageStyle
                                      .remarkFieldSubTitleTextStyle)
                                  .copyWith(
                                      color: flagMessageStyle
                                          .remarkFieldSubTitleTextColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (widget.hideFlagRemarkField == false)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: controller.hasError ? spacing.padding4 ?? 0 : 0,
                      ),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.15,
                        child: TextField(
                          controller: controller.textFieldController,
                          maxLines: 6,
                          textAlignVertical: TextAlignVertical.top,
                          style: TextStyle(
                            color: colorPalette.textPrimary,
                            fontSize: typography.body?.regular?.fontSize,
                            fontWeight: typography.body?.regular?.fontWeight,
                            fontFamily: typography.body?.regular?.fontFamily,
                          )
                              .merge(
                                flagMessageStyle.remarkFieldTextStyle,
                              )
                              .copyWith(
                                color: flagMessageStyle.remarkFieldTextColor ??
                                    colorPalette.textPrimary,
                              ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor:
                                flagMessageStyle.remarkFieldBackgroundColor ??
                                    colorPalette.background2,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                spacing.radius2 ?? 0,
                              ),
                              borderSide: BorderSide(
                                color: colorPalette.borderLight ??
                                    Colors.transparent,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                spacing.radius2 ?? 0,
                              ),
                              borderSide: BorderSide(
                                color: colorPalette.borderLight ??
                                    Colors.transparent,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                spacing.radius2 ?? 0,
                              ),
                              borderSide: BorderSide(
                                color: colorPalette.borderLight ??
                                    Colors.transparent,
                              ),
                            ),
                            hintText:
                                "${cc.Translations.of(context).additionalContext}...",
                            hintStyle: TextStyle(
                              color: colorPalette.textTertiary,
                              fontSize: typography.body?.regular?.fontSize,
                              fontWeight: typography.body?.regular?.fontWeight,
                              fontFamily: typography.body?.regular?.fontFamily,
                            )
                                .merge(
                                  flagMessageStyle.remarkFieldHintTextStyle,
                                )
                                .copyWith(
                                  color: flagMessageStyle
                                          .remarkFieldHintTextColor ??
                                      colorPalette.textTertiary,
                                ),
                            contentPadding: EdgeInsets.all(
                              spacing.padding2 ?? 0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (controller.hasError)
                    Text(
                      controller.errorMessage,
                      style: TextStyle(
                        color: flagMessageStyle.errorTextColor ??
                            colorPalette.error,
                        fontSize: typography.button?.regular?.fontSize,
                        fontWeight: typography.button?.regular?.fontWeight,
                        fontFamily: typography.button?.regular?.fontFamily,
                      ).merge(
                        flagMessageStyle.errorTextStyle,
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          flagMessageStyle.cancelButtonBackgroundColor ??
                              colorPalette.background1),
                      side: flagMessageStyle.cancelButtonBorder ??
                          MaterialStateProperty.all(
                            BorderSide(
                              color:
                                  colorPalette.borderDark ?? Colors.transparent,
                            ),
                          ),
                      shadowColor:
                          MaterialStateProperty.all(colorPalette.transparent),
                      shape: flagMessageStyle.cancelButtonShape ??
                          MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                spacing.radius2 ?? 0,
                              ),
                            ),
                          ),
                      padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(
                          vertical: spacing.padding2 ?? 0,
                          horizontal: spacing.padding5 ?? 0,
                        ),
                      ),
                    ),
                    child: Text(
                      cc.Translations.of(context).cancel,
                      style: TextStyle(
                        color: colorPalette.textPrimary,
                        fontSize: typography.button?.medium?.fontSize,
                        fontWeight: typography.button?.medium?.fontWeight,
                        fontFamily: typography.button?.medium?.fontFamily,
                      )
                          .merge(
                            flagMessageStyle.cancelButtonTextStyle,
                          )
                          .copyWith(
                            color: flagMessageStyle.cancelButtonTextColor ??
                                colorPalette.textPrimary,
                          ),
                    ),
                  ),
                ),
                SizedBox(
                  width: spacing.padding2,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isReportButtonEnabled
                        ? () {
                            controller.reportMessage(context, widget.message);
                          }
                        : () {},
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        isReportButtonEnabled
                            ? (flagMessageStyle
                                    .reportButtonActiveBackgroundColor ??
                                colorPalette.primary)
                            : (flagMessageStyle.reportButtonBackgroundColor ??
                                colorPalette.background4),
                      ),
                      side: flagMessageStyle.reportButtonBorder,
                      shape: flagMessageStyle.reportButtonShape ??
                          MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                spacing.radius2 ?? 0,
                              ),
                            ),
                          ),
                      shadowColor:
                          MaterialStateProperty.all(colorPalette.transparent),
                      padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(
                          vertical: spacing.padding2 ?? 0,
                          horizontal: spacing.padding5 ?? 0,
                        ),
                      ),
                    ),
                    child: (controller.isLoading)
                        ? Center(
                            child: SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                color: colorPalette.white,
                              ),
                            ),
                          )
                        : Text(
                            cc.Translations.of(context).report,
                            style: TextStyle(
                              color: colorPalette.buttonIconColor,
                              fontSize: typography.button?.medium?.fontSize,
                              fontWeight: typography.button?.medium?.fontWeight,
                              fontFamily: typography.button?.medium?.fontFamily,
                            )
                                .merge(
                                  flagMessageStyle.reportButtonTextStyle,
                                )
                                .copyWith(
                                  color:
                                      flagMessageStyle.reportButtonTextColor ??
                                          colorPalette.buttonIconColor,
                                ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
