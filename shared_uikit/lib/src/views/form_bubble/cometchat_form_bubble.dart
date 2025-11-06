import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';
import 'package:cometchat_uikit_shared/src/utils/action_element_utils.dart';
import 'package:cometchat_uikit_shared/src/views/button_element/cometchat_button_element.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A widget for displaying a chat form bubble for category [MessageCategoryConstants.interactive] and type [MessageTypeConstants.form] .
///
/// This widget can be used to display a chat form bubble in a CometChat conversation.
/// It provides various customization options for the appearance and behavior of the form.
class CometChatFormBubble extends StatefulWidget {
  const CometChatFormBubble(
      {super.key,
      this.title,
      this.formBubbleStyle,
      required this.formMessage,
      this.theme,
      this.onSubmitTap,
      this.loggedInUser,
      this.quickViewStyle});

  /// The [formBubbleStyle] property allows you to customize the style of the form bubble.
  final FormBubbleStyle? formBubbleStyle;

  /// The [title] is an optional title for the form.
  final String? title;

  /// The [formMessage] is a required parameter that contains the message to be displayed in the form bubble.
  final FormMessage formMessage;

  /// The [theme] property allows to apply a custom CometChat theme to the form bubble.
  final CometChatTheme? theme;

  /// The [onSubmitTap] property is a callback function that is called when the user submits the form.
  /// It receives a map of form data as an argument.
  final Function(Map<String, dynamic>)? onSubmitTap;

  /// The [loggedInUser] property represents the currently logged-in user.
  final User? loggedInUser;

  /// The [quickViewStyle] property represents the currently logged-in user.
  final QuickViewStyle? quickViewStyle;

  @override
  State<CometChatFormBubble> createState() => _CometChatFormBubbleState();
}

class _CometChatFormBubbleState extends State<CometChatFormBubble> {
  late List<ElementEntity> formFields;
  bool isGoalAchieved = false;
  late CometChatTheme theme;
  Map<String, bool?> interactionMap = {};
  List<String> mandatoryElementList = [];
  bool isValidating = false;
  late TextStyle buttonTextStyle;
  late ButtonElementStyle buttonElementStyle;
  late ButtonElementStyle submitButtonElementStyle;
  late SingleSelectStyle singleSelectStyle;
  late DropDownElementStyle dropDownElementStyle;
  late CheckBoxElementStyle checkBoxElementStyle;
  late RadioButtonElementStyle radioButtonElementStyle;
  late TextInputElementStyle textInputStyle;
  late TextStyle labelStyle;
  bool? isSentByMe = false;

  @override
  void initState() {
    theme = widget.theme ?? cometChatTheme;
    isSentByMe = InteractiveMessageUtils.checkIsSentByMe(
        widget.loggedInUser, widget.formMessage);
    _populateMap();
    formFields = widget.formMessage.formFields;
    _checkInteractionGoals();
    _populateResponse();
    populateStyles();
    super.initState();
  }

  double screenHeight({var context, double? mulBy}) {
    return MediaQuery.of(context).size.height * mulBy!;
  }

  double screenWidth({var context, double? mulBy}) {
    return MediaQuery.of(context).size.width * mulBy!;
  }

  populateStyles() {
    final TextStyle defaultButtonTextStyle = TextStyle(
        fontSize: theme.typography.title2.fontSize,
        fontWeight: theme.typography.title2.fontWeight,
        fontFamily: theme.typography.title2.fontFamily,
        color: theme.palette.getSecondary());

    final TextStyle textStyle2 = TextStyle(
        fontSize: theme.typography.text2.fontSize,
        fontWeight: theme.typography.text2.fontWeight,
        color: theme.palette.getAccent(),
        fontFamily: theme.typography.text2.fontFamily);

    final TextStyle textStyle3 = TextStyle(
        fontSize: theme.typography.subtitle2.fontSize,
        fontWeight: theme.typography.subtitle2.fontWeight,
        color: theme.palette.getAccent400(),
        fontFamily: theme.typography.subtitle2.fontFamily);

    final TextStyle textStyle4 = TextStyle(
        fontSize: theme.typography.subtitle2.fontSize,
        fontWeight: theme.typography.subtitle2.fontWeight,
        fontFamily: theme.typography.subtitle2.fontFamily,
        color: theme.palette.getAccent200());

    final TextStyle textStyle5 = TextStyle(
        fontSize: theme.typography.subtitle1.fontSize,
        fontWeight: theme.typography.subtitle1.fontWeight,
        fontFamily: theme.typography.subtitle1.fontFamily,
        color: theme.palette.getAccent());

    final TextStyle textStyle6 = TextStyle(
      fontSize: theme.typography.subtitle1.fontSize,
      fontWeight: theme.typography.subtitle1.fontWeight,
      fontFamily: theme.typography.subtitle1.fontFamily,
      color: theme.palette.getAccent(),
    );

    final ButtonElementStyle defaultButtonStyle = ButtonElementStyle(
      height: 35,
      borderRadius: BorderRadius.circular(6),
      buttonTextStyle: defaultButtonTextStyle,
    );

    final SingleSelectStyle defaultSingleSelectStyle = SingleSelectStyle(
      height: 35,
      borderRadius: BorderRadius.circular(6),
      selectedOptionBackground: theme.palette.getBackground(),
      selectedOptionTextStyle: textStyle2,
      optionTextStyle: textStyle3,
    );

    final DropDownElementStyle defaultDropDownStyle = DropDownElementStyle(
        height: 35,
        borderRadius: BorderRadius.circular(6),
        hintTextStyle: textStyle4,
        optionTextStyle: textStyle5,
        background: theme.palette.getBackground(),
        labelStyle: textStyle6);

    final CheckBoxElementStyle defaultCheckBoxElementStyle =
        CheckBoxElementStyle(
            borderRadius: BorderRadius.circular(6),
            optionTextStyle: textStyle5,
            background: theme.palette.getBackground(),
            labelStyle: textStyle6);

    final RadioButtonElementStyle defaultRadioElementStyle =
        RadioButtonElementStyle(
      borderRadius: BorderRadius.circular(6),
      optionTextStyle: textStyle5,
      background: theme.palette.getBackground(),
      labelStyle: textStyle6,
    );

    final TextInputElementStyle defaultTextInputStyle = TextInputElementStyle(
      borderRadius: BorderRadius.circular(6),
      height: 35,
      background: theme.palette.getBackground(),
      labelStyle: textStyle6,
      textStyle: textStyle6,
      hintTextStyle: textStyle3,
    );

    buttonElementStyle =
        widget.formBubbleStyle?.buttonStyle?.merge(defaultButtonStyle) ??
            defaultButtonStyle;

    submitButtonElementStyle =
        widget.formBubbleStyle?.submitButtonStyle?.merge(defaultButtonStyle) ??
            defaultButtonStyle;

    singleSelectStyle = widget.formBubbleStyle?.singleSelectStyle
            ?.merge(defaultSingleSelectStyle) ??
        defaultSingleSelectStyle;

    dropDownElementStyle =
        widget.formBubbleStyle?.dropDownStyle?.merge(defaultDropDownStyle) ??
            defaultDropDownStyle;

    textInputStyle =
        widget.formBubbleStyle?.textInputStyle?.merge(defaultTextInputStyle) ??
            defaultTextInputStyle;

    checkBoxElementStyle = defaultCheckBoxElementStyle;

    radioButtonElementStyle = defaultRadioElementStyle;

    labelStyle = textStyle6.merge(widget.formBubbleStyle?.labelStyle);
  }

  //populates the
  _populateMap() {
    if (widget.formMessage.interactions != null) {
      for (var element in widget.formMessage.interactions!) {
        interactionMap[element.elementId] = true;
      }
    }
  }

  _checkInteractionGoals() {
    if (widget.formMessage.interactionGoal != null) {
      bool goalAchieved =
          InteractiveMessageUtils.checkInteractionGoalAchievedFromMap(
              widget.formMessage.interactionGoal!, interactionMap);
      if (goalAchieved != isGoalAchieved) {
        isGoalAchieved = goalAchieved;
      }
    }
  }

  _populateResponse() {
    for (int i = 0; i < widget.formMessage.formFields.length; i++) {
      if (widget.formMessage.formFields[i] is BaseInputElement) {
        BaseInputElement inputElement =
            widget.formMessage.formFields[i] as BaseInputElement;

        if (inputElement.response == null &&
            inputElement.defaultValue != null) {
          (widget.formMessage.formFields[i] as BaseInputElement).response =
              (widget.formMessage.formFields[i] as BaseInputElement)
                  .defaultValue;
        }
      }
    }
  }

  Map<String, dynamic>? createResponse() {
    Map<String, dynamic> response = {};
    for (var formField in widget.formMessage.formFields) {
      if (formField.elementType is BaseInputElement) {
        response[formField.elementId] =
            (formField as BaseInputElement).response;
      }
    }
    return response;
  }

  bool validateFields() {
    isValidating = true;

    for (var element in widget.formMessage.formFields) {
      if (element is BaseInputElement) {
        var baseInputElement = element;
        if (!baseInputElement.optional &&
            !baseInputElement.validateResponse()) {
          if (baseInputElement is TextInputElement) {}
          setState(() {});
          return false;
        }
      }
    }

    isValidating = false;
    return true;
  }

  Map<String, dynamic> getCompleteData() {
    Map<String, dynamic> localData = {};
    if (widget.loggedInUser != null) {}
    for (var element in widget.formMessage.formFields) {
      if (element is BaseInputElement) {
        if (element is CheckBoxElement) {
          localData[element.elementId] =
              (element).isChecked?.keys.map((e) => e.toString()).toList();
        } else {
          localData[element.elementId] = (element).response;
        }
      }
    }
    return localData;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.palette.getBackground(),
        shape: BoxShape.rectangle,
        borderRadius: const BorderRadius.all(Radius.circular(4.0)),
        border: Border.all(
          color: theme.palette.getSecondary(),
          width: 4,
        ),
      ),
      child: SingleChildScrollView(
        child: isGoalAchieved == true
            ? Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 65 / 100),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        color: theme.palette.getSecondary(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CometChatQuickView(
                                theme: widget.theme,
                                title: widget.formMessage.sender?.name ?? "",
                                subtitle: widget.formMessage.title,
                                quickViewStyle: widget.quickViewStyle ??
                                    (QuickViewStyle(
                                      background:
                                          widget.quickViewStyle?.background ??
                                              theme.palette.getBackground(),
                                      titleStyle: widget
                                              .quickViewStyle?.titleStyle ??
                                          TextStyle(
                                            fontSize:
                                                theme.typography.text2.fontSize,
                                            fontWeight: theme
                                                .typography.text2.fontWeight,
                                            fontFamily: theme
                                                .typography.text2.fontFamily,
                                            color: theme.palette.getPrimary(),
                                          ),
                                      subtitleStyle: widget
                                              .quickViewStyle?.subtitleStyle ??
                                          TextStyle(
                                            fontSize: theme
                                                .typography.subtitle2.fontSize,
                                            fontWeight: theme.typography
                                                .subtitle2.fontWeight,
                                            fontFamily: theme.typography
                                                .subtitle2.fontFamily,
                                            color: theme.palette.getAccent(),
                                          ),
                                    ))),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                widget.formMessage.goalCompletionText ??
                                    Translations.of(context)
                                        .goalAchievedSuccessfully,
                                style: TextStyle(
                                        color: theme.palette.getAccent(),
                                        fontWeight:
                                            theme.typography.body.fontWeight,
                                        fontSize:
                                            theme.typography.body.fontSize,
                                        fontFamily:
                                            theme.typography.body.fontFamily)
                                    .merge(widget.formBubbleStyle
                                        ?.goalCompletionTextStyle),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                height: widget.formBubbleStyle?.height,
                width: widget.formBubbleStyle?.width,
                decoration: BoxDecoration(
                    color: widget.formBubbleStyle?.gradient == null
                        ? widget.formBubbleStyle?.background ??
                            Colors.transparent
                        : null,
                    gradient: widget.formBubbleStyle?.gradient),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  width: 1,
                                  color: theme.palette.getAccent200()))),
                      child: Text(
                        widget.formMessage.title,
                        style: widget.formBubbleStyle?.titleStyle ??
                            TextStyle(
                                fontSize: theme.typography.name.fontSize,
                                fontWeight: theme.typography.name.fontWeight,
                                fontFamily: theme.typography.name.fontFamily,
                                color: theme.palette.getAccent()),
                      ),
                    ),
                    ...formFields.map((e) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: getWidget(e),
                        )),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: getWidget(widget.formMessage.submitElement,
                          isSubmit: true),
                    )
                  ],
                ),
              ),
      ),
    );
  }

  Widget getWidget(ElementEntity entity, {bool isSubmit = false}) {
    switch (entity.runtimeType) {
      case RadioButtonElement:
        RadioButtonElement radioButton = entity as RadioButtonElement;

        return Container(
          color: widget.formBubbleStyle?.radioButtonStyle?.background,
          width: widget.formBubbleStyle?.radioButtonStyle?.width,
          height: widget.formBubbleStyle?.radioButtonStyle?.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  getLabel(radioButton.label, radioButton.optional),
                  // descriptionWidget(
                  //     e, context, widget.descriptionTextDecoration),
                ],
              ),
              Column(
                children: radioButton.options
                    .map(
                      (option) => RadioListTile(
                        contentPadding: EdgeInsets.zero,
                        visualDensity:
                            const VisualDensity(horizontal: -4, vertical: -4),
                        activeColor: widget.formBubbleStyle?.radioButtonStyle
                                ?.activeColor ??
                            theme.palette.getPrimary(),
                        value: option.value,
                        groupValue: radioButton.response,
                        dense: true,
                        title: Text(
                          option.label,
                          style: TextStyle(
                                  fontSize: theme.typography.subtitle1.fontSize,
                                  fontWeight:
                                      theme.typography.subtitle1.fontWeight,
                                  fontFamily:
                                      theme.typography.subtitle1.fontFamily,
                                  color: theme.palette.getAccent())
                              .merge(widget.formBubbleStyle?.checkBoxStyle
                                  ?.optionTextStyle),
                        ),
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() {
                              radioButton.response = value;
                            });
                          }
                          // setState(() {});
                        },
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      case SingleSelectElement:
        SingleSelectElement singleSelect = entity as SingleSelectElement;
        return Container(
          color: singleSelectStyle.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  getLabel(singleSelect.label, singleSelect.optional),
                  // descriptionWidget(
                  //     e, context, widget.descriptionTextDecoration),
                ],
              ),
              Column(
                children: [
                  CometChatSingleSelect(
                    options: singleSelect.options,
                    selectedValue: singleSelect.response,
                    selectedOptionBackground:
                        singleSelectStyle.selectedOptionBackground,
                    optionBackground: singleSelectStyle.optionBackground,
                    selectedOptionsTextStyle:
                        singleSelectStyle.selectedOptionTextStyle,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          width: 2,
                          color: isValidating == true &&
                                  !singleSelect.optional &&
                                  !singleSelect.validateResponse()
                              ? theme.palette.getError()
                              : theme.palette.getAccent100()),
                    ),
                    optionTextStyle: singleSelectStyle.optionTextStyle,
                    onChanged: (String newResponse) {
                      setState(() {
                        singleSelect.response = newResponse;
                      });
                    },
                  )
                ],
              )
            ],
          ),
        );
      case DropdownElement:
        DropdownElement dropDownModel = entity as DropdownElement;
        return Container(
          color: dropDownElementStyle.background,
          width: dropDownElementStyle.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              getLabel(dropDownModel.label, dropDownModel.optional),
              Container(
                height: dropDownElementStyle.height,
                width: dropDownElementStyle.width ??
                    screenWidth(context: context, mulBy: 0.9),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: widget.formBubbleStyle?.dropDownStyle?.border ??
                      Border.all(
                          width: 2,
                          color: isValidating == true &&
                                  !dropDownModel.optional &&
                                  !dropDownModel.validateResponse()
                              ? theme.palette.getError()
                              : theme.palette.getAccent100()),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: DropdownButton(
                    underline: const SizedBox(),
                    value: dropDownModel.response,
                    hint: Text(
                      Translations.of(context).selectOption,
                      style: dropDownElementStyle.hintTextStyle,
                    ),
                    isExpanded: true,
                    iconSize: 15.0,
                    style: dropDownElementStyle.optionTextStyle,
                    items: dropDownModel.options.map(
                      (val) {
                        return DropdownMenuItem<String>(
                          value: val.value,
                          child: Text(val.label,
                              style: dropDownElementStyle.optionTextStyle),
                        );
                      },
                    ).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        dropDownModel.response = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        );

      case CheckBoxElement:
        CheckBoxElement checkBox = entity as CheckBoxElement;

        if (checkBox.isChecked == null || checkBox.isChecked!.isEmpty) {
          checkBox.isChecked = {};
          for (var element in checkBox.options) {
            if (checkBox.response?.contains(element.value) ?? false) {
              checkBox.isChecked![element.value] = true;
            }
          }
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [getLabel(checkBox.label, checkBox.optional)],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: checkBox.options
                  .map(
                    (option) => CheckboxListTile(
                      side: MaterialStateBorderSide.resolveWith(
                        (states) => BorderSide(
                            width: 1.0,
                            color: isValidating == true &&
                                    !checkBox.optional &&
                                    !checkBox.validateResponse()
                                ? theme.palette.getError()
                                : theme.palette.getAccent100()),
                      ),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      visualDensity:
                          const VisualDensity(horizontal: -4, vertical: -4),
                      checkColor: theme.palette.getBackground(),
                      activeColor: theme.palette.getPrimary(),
                      checkboxShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      title: Transform.translate(
                        offset: const Offset(-10, 0),
                        child: Text(
                          option.label,
                          style: checkBoxElementStyle.optionTextStyle,
                        ),
                      ),
                      value: checkBox.isChecked![option.value] == true,
                      onChanged: (bool? value) {
                        if (value != null) {
                          checkBox.isChecked![option.value] = value;
                          checkBox.response = [];
                          checkBox.isChecked!.forEach((key, value) {
                            if (value == true) checkBox.response?.add(key);
                          });
                          setState(() {});
                        }
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        );

      case TextInputElement:
        TextInputElement inputElement = entity as TextInputElement;

        EdgeInsets padding = const EdgeInsets.only(left: 6.0);

        if (inputElement.maxLines > 1) {
          padding = const EdgeInsets.all(6.0);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                getLabel(inputElement.label, inputElement.optional),
              ],
            ),
            Container(
              height: 38,
              decoration: BoxDecoration(
                color: theme.palette.getBackground(),
                shape: BoxShape.rectangle,
                borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                border: Border.all(
                  color: isValidating == true &&
                          !inputElement.optional &&
                          !inputElement.validateResponse()
                      ? theme.palette.getError()
                      : theme.palette.getAccent100(),
                  width: 2,
                ),
              ),
              alignment: Alignment.centerLeft,
              padding: padding,
              child: TextFormField(
                textCapitalization: TextCapitalization.sentences,
                keyboardAppearance:
                CometChatThemeHelper.getBrightness(context) ==
                    Brightness.dark
                    ? Brightness.dark
                    : Brightness.light,
                decoration: InputDecoration.collapsed(
                  hintText: inputElement.placeholder?.text ??
                      Translations.of(context).enterText,
                  hintStyle: textInputStyle.hintTextStyle,
                ),
                initialValue: inputElement.defaultValue,
                inputFormatters: const [],
                maxLines: inputElement.maxLines,
                autofocus: false,
                onChanged: (value) {
                  setState(() {
                    inputElement.response = value;
                  });
                },
                style: textInputStyle.textStyle,
              ),
            )
          ],
        );

      case DateTimeElement:
        DateTimeElement dateTimeElement = entity as DateTimeElement;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                getLabel(dateTimeElement.label, dateTimeElement.optional),
              ],
            ),
            Container(
              height: 38,
              decoration: BoxDecoration(
                color: theme.palette.getBackground(),
                shape: BoxShape.rectangle,
                borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                border: Border.all(
                  color: isValidating == true &&
                          !dateTimeElement.optional &&
                          !dateTimeElement.validateResponse()
                      ? theme.palette.getError()
                      : theme.palette.getAccent100(),
                  width: 2,
                ),
              ),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 6.0),
              child: CometChatDateTimeFormField(
                theme: theme,
                mode: dateTimeElement.mode,
                formatterString: dateTimeElement.dateTimeFormat,
                value: dateTimeElement.formattedResponse,
                onChanged: (DateTime? dateTime) {
                  dateTimeElement.formattedResponse = dateTime;

                  if (dateTime == null) {
                    dateTimeElement.response = null;
                  } else {
                    if (dateTimeElement.mode ==
                        DateTimeVisibilityMode.dateTime) {
                      dateTimeElement.response = dateTime.toIso8601String();
                    } else if (dateTimeElement.mode ==
                        DateTimeVisibilityMode.date) {
                      DateFormat formatter = DateFormat("yyyy-MM-DD");
                      dateTimeElement.response = formatter.format(dateTime);
                    } else {
                      DateFormat formatter = DateFormat("HH:mm");
                      dateTimeElement.response = formatter.format(dateTime);
                    }
                    if (kDebugMode) {
                      print("response is ${dateTimeElement.response}");
                    }
                  }
                },
              ),
            ),
          ],
        );

      case ButtonElement:
        ButtonElement buttonElement = entity as ButtonElement;

        Color? background = isSubmit == true
            ? submitButtonElementStyle.background
            : buttonElementStyle.background;
        background ??= theme.palette.getPrimary();

        bool isDisabled = checkDisabled(buttonElement);

        if (isDisabled) {
          background = background.withOpacity(0.4);
        }

        return Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: CometChatButtonElement(
            buttonStyle: ButtonElementStyle(
              height: widget.formBubbleStyle?.submitButtonStyle?.height ?? 40,
              background: background,
              buttonTextStyle: isSubmit == true
                  ? submitButtonElementStyle.buttonTextStyle!
                  : buttonElementStyle.buttonTextStyle!,
              borderRadius: isSubmit == true
                  ? submitButtonElementStyle.borderRadius!
                  : buttonElementStyle.borderRadius!,
            ),
            text: buttonElement.buttonText,
            onTap: (BuildContext context) async {
              if (isDisabled) return;
              await buttonOnClick(isSubmit, buttonElement);
            },
          ),
        );

      case LabelElement:
        LabelElement labelElement = entity as LabelElement;
        return Padding(
          padding: const EdgeInsets.fromLTRB(6.0, 14.0, 6, 6),
          child: Text(
            labelElement.text,
            style: labelStyle,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  bool checkDisabled(BaseInteractiveElement element) {
    if (interactionMap[element.elementId] != null &&
        element.disableAfterInteracted == true) {
      return true;
    } else if (isSentByMe == true &&
        widget.formMessage.allowSenderInteraction == false) {
      return true;
    }

    return false;
  }

  Widget getLabel(String label, bool? isOptional) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: theme.typography.text1.fontSize,
              fontWeight: theme.typography.subtitle1.fontWeight,
              fontFamily: theme.typography.text1.fontFamily,
              color: theme.palette.getAccent(),
            ).merge(widget.formBubbleStyle?.titleStyle),
          ),
          if (isOptional == false) getMandatoryMark()
        ],
      ),
    );
  }

  Widget iconContainer(image) {
    return image == null
        ? Container()
        : Container(
            padding: const EdgeInsets.all(10),
            child: Image.asset(
              image,
              height: 20,
            ),
          );
  }

  Widget getMandatoryMark() {
    return Padding(
      padding: const EdgeInsets.only(left: 2.0),
      child: Text(
        "*",
        style: TextStyle(
          fontSize: theme.typography.text1.fontSize,
          fontWeight: theme.typography.text1.fontWeight,
          fontFamily: theme.typography.text1.fontFamily,
          color: theme.palette.getAccent(),
        ).merge(widget.formBubbleStyle?.titleStyle),
      ),
    );
  }

  markInteracted(BaseInteractiveElement interactiveElement) async {
    InteractiveMessageUtils.markInteracted(
        interactiveElement, widget.formMessage, interactionMap,
        onSuccess: (bool matched) {
      _checkInteractionGoals();
      setState(() {});
    });
  }

  buttonOnClick(bool isSubmit, ButtonElement buttonElement) async {
    if (isSubmit == true) {
      if (validateFields() == false) {
        setState(() {});
        return;
      }
      if (widget.onSubmitTap != null) {
        widget.onSubmitTap!(getCompleteData());
        return;
      }
    }

    if ((widget.onSubmitTap == null && isSubmit == true) ||
        (isSubmit != true)) {
      bool status = await ActionElementUtils.performAction(
        element: buttonElement,
        body: InteractiveMessageUtils.getInteractiveRequestData(
            message: widget.formMessage,
            element: buttonElement,
            interactionTimezoneCode: CometChatUIKit.localTimeZoneIdentifier,
            interactedBy: widget.loggedInUser?.uid ?? "",
            body: {"formData": getCompleteData()}),
        messageId: widget.formMessage.id,
        context: context,
        theme: theme,
      );

      if (status == true) {
        markInteracted(buttonElement);
      }
    }
  }
}
