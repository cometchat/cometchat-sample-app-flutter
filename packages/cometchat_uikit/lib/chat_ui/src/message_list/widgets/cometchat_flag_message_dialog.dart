import 'package:flutter/material.dart';
import '../../../../shared_ui/cometchat_uikit_shared.dart';

/// Style class for the Flag Message dialog.
class CometChatFlagMessageStyle extends ThemeExtension<CometChatFlagMessageStyle> {
  const CometChatFlagMessageStyle({
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.titleTextColor,
    this.titleTextStyle,
    this.closeIconTint,
    this.subTitleTextColor,
    this.subTitleTextStyle,
    this.chipBackgroundColor,
    this.chipBorder,
    this.chipBorderRadius,
    this.chipTitleTextStyle,
    this.chipTitleTextColor,
    this.chipActiveBackgroundColor,
    this.chipActiveTitleTextColor,
    this.chipActiveTitleTextStyle,
    this.chipActiveBorder,
    this.remarkFieldBackgroundColor,
    this.remarkFieldHintTextColor,
    this.remarkFieldHintTextStyle,
    this.remarkFieldTextColor,
    this.remarkFieldTextStyle,
    this.remarkFieldTitleTextColor,
    this.remarkFieldTitleTextStyle,
    this.cancelButtonBackgroundColor,
    this.cancelButtonTextStyle,
    this.cancelButtonTextColor,
    this.reportButtonBackgroundColor,
    this.reportButtonActiveBackgroundColor,
    this.reportButtonTextStyle,
    this.reportButtonTextColor,
    this.errorTextColor,
    this.errorTextStyle,
    this.remarkFieldSubTitleTextColor,
    this.remarkFieldSubTitleTextStyle,
  });

  final Color? backgroundColor;
  final BorderSide? border;
  final BorderRadiusGeometry? borderRadius;
  final Color? titleTextColor;
  final TextStyle? titleTextStyle;
  final Color? closeIconTint;
  final Color? subTitleTextColor;
  final TextStyle? subTitleTextStyle;
  final Color? chipBackgroundColor;
  final BoxBorder? chipBorder;
  final BorderRadiusGeometry? chipBorderRadius;
  final TextStyle? chipTitleTextStyle;
  final Color? chipTitleTextColor;
  final Color? chipActiveBackgroundColor;
  final Color? chipActiveTitleTextColor;
  final TextStyle? chipActiveTitleTextStyle;
  final BoxBorder? chipActiveBorder;
  final Color? remarkFieldBackgroundColor;
  final Color? remarkFieldHintTextColor;
  final TextStyle? remarkFieldHintTextStyle;
  final Color? remarkFieldTextColor;
  final TextStyle? remarkFieldTextStyle;
  final Color? remarkFieldTitleTextColor;
  final TextStyle? remarkFieldTitleTextStyle;
  final Color? remarkFieldSubTitleTextColor;
  final TextStyle? remarkFieldSubTitleTextStyle;
  final Color? cancelButtonBackgroundColor;
  final TextStyle? cancelButtonTextStyle;
  final Color? cancelButtonTextColor;
  final Color? reportButtonBackgroundColor;
  final Color? reportButtonActiveBackgroundColor;
  final TextStyle? reportButtonTextStyle;
  final Color? reportButtonTextColor;
  final Color? errorTextColor;
  final TextStyle? errorTextStyle;

  static CometChatFlagMessageStyle of(BuildContext context) =>
      const CometChatFlagMessageStyle();

  @override
  CometChatFlagMessageStyle copyWith({
    Color? backgroundColor,
    BorderSide? border,
    BorderRadiusGeometry? borderRadius,
    Color? titleTextColor,
    TextStyle? titleTextStyle,
    Color? closeIconTint,
    Color? subTitleTextColor,
    TextStyle? subTitleTextStyle,
    Color? chipBackgroundColor,
    BoxBorder? chipBorder,
    BorderRadiusGeometry? chipBorderRadius,
    TextStyle? chipTitleTextStyle,
    Color? chipTitleTextColor,
    Color? chipActiveBackgroundColor,
    Color? chipActiveTitleTextColor,
    TextStyle? chipActiveTitleTextStyle,
    BoxBorder? chipActiveBorder,
    Color? remarkFieldBackgroundColor,
    Color? remarkFieldHintTextColor,
    TextStyle? remarkFieldHintTextStyle,
    Color? remarkFieldTextColor,
    TextStyle? remarkFieldTextStyle,
    Color? remarkFieldTitleTextColor,
    TextStyle? remarkFieldTitleTextStyle,
    Color? remarkFieldSubTitleTextColor,
    TextStyle? remarkFieldSubTitleTextStyle,
    Color? cancelButtonBackgroundColor,
    TextStyle? cancelButtonTextStyle,
    Color? cancelButtonTextColor,
    Color? reportButtonBackgroundColor,
    Color? reportButtonActiveBackgroundColor,
    TextStyle? reportButtonTextStyle,
    Color? reportButtonTextColor,
    Color? errorTextColor,
    TextStyle? errorTextStyle,
  }) {
    return CometChatFlagMessageStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      titleTextColor: titleTextColor ?? this.titleTextColor,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      closeIconTint: closeIconTint ?? this.closeIconTint,
      subTitleTextColor: subTitleTextColor ?? this.subTitleTextColor,
      subTitleTextStyle: subTitleTextStyle ?? this.subTitleTextStyle,
      chipBackgroundColor: chipBackgroundColor ?? this.chipBackgroundColor,
      chipBorder: chipBorder ?? this.chipBorder,
      chipBorderRadius: chipBorderRadius ?? this.chipBorderRadius,
      chipTitleTextStyle: chipTitleTextStyle ?? this.chipTitleTextStyle,
      chipTitleTextColor: chipTitleTextColor ?? this.chipTitleTextColor,
      chipActiveBackgroundColor: chipActiveBackgroundColor ?? this.chipActiveBackgroundColor,
      chipActiveTitleTextColor: chipActiveTitleTextColor ?? this.chipActiveTitleTextColor,
      chipActiveTitleTextStyle: chipActiveTitleTextStyle ?? this.chipActiveTitleTextStyle,
      chipActiveBorder: chipActiveBorder ?? this.chipActiveBorder,
      remarkFieldBackgroundColor: remarkFieldBackgroundColor ?? this.remarkFieldBackgroundColor,
      remarkFieldHintTextColor: remarkFieldHintTextColor ?? this.remarkFieldHintTextColor,
      remarkFieldHintTextStyle: remarkFieldHintTextStyle ?? this.remarkFieldHintTextStyle,
      remarkFieldTextColor: remarkFieldTextColor ?? this.remarkFieldTextColor,
      remarkFieldTextStyle: remarkFieldTextStyle ?? this.remarkFieldTextStyle,
      remarkFieldTitleTextColor: remarkFieldTitleTextColor ?? this.remarkFieldTitleTextColor,
      remarkFieldTitleTextStyle: remarkFieldTitleTextStyle ?? this.remarkFieldTitleTextStyle,
      remarkFieldSubTitleTextColor: remarkFieldSubTitleTextColor ?? this.remarkFieldSubTitleTextColor,
      remarkFieldSubTitleTextStyle: remarkFieldSubTitleTextStyle ?? this.remarkFieldSubTitleTextStyle,
      cancelButtonBackgroundColor: cancelButtonBackgroundColor ?? this.cancelButtonBackgroundColor,
      cancelButtonTextStyle: cancelButtonTextStyle ?? this.cancelButtonTextStyle,
      cancelButtonTextColor: cancelButtonTextColor ?? this.cancelButtonTextColor,
      reportButtonBackgroundColor: reportButtonBackgroundColor ?? this.reportButtonBackgroundColor,
      reportButtonActiveBackgroundColor: reportButtonActiveBackgroundColor ?? this.reportButtonActiveBackgroundColor,
      reportButtonTextStyle: reportButtonTextStyle ?? this.reportButtonTextStyle,
      reportButtonTextColor: reportButtonTextColor ?? this.reportButtonTextColor,
      errorTextColor: errorTextColor ?? this.errorTextColor,
      errorTextStyle: errorTextStyle ?? this.errorTextStyle,
    );
  }

  CometChatFlagMessageStyle merge(CometChatFlagMessageStyle? other) {
    if (other == null) return this;
    return copyWith(
      backgroundColor: other.backgroundColor,
      border: other.border,
      borderRadius: other.borderRadius,
      titleTextColor: other.titleTextColor,
      titleTextStyle: other.titleTextStyle,
      closeIconTint: other.closeIconTint,
      subTitleTextColor: other.subTitleTextColor,
      subTitleTextStyle: other.subTitleTextStyle,
      chipBackgroundColor: other.chipBackgroundColor,
      chipBorder: other.chipBorder,
      chipBorderRadius: other.chipBorderRadius,
      chipTitleTextStyle: other.chipTitleTextStyle,
      chipTitleTextColor: other.chipTitleTextColor,
      chipActiveBackgroundColor: other.chipActiveBackgroundColor,
      chipActiveTitleTextColor: other.chipActiveTitleTextColor,
      chipActiveTitleTextStyle: other.chipActiveTitleTextStyle,
      chipActiveBorder: other.chipActiveBorder,
      remarkFieldBackgroundColor: other.remarkFieldBackgroundColor,
      remarkFieldHintTextColor: other.remarkFieldHintTextColor,
      remarkFieldHintTextStyle: other.remarkFieldHintTextStyle,
      remarkFieldTextColor: other.remarkFieldTextColor,
      remarkFieldTextStyle: other.remarkFieldTextStyle,
      remarkFieldTitleTextColor: other.remarkFieldTitleTextColor,
      remarkFieldTitleTextStyle: other.remarkFieldTitleTextStyle,
      remarkFieldSubTitleTextColor: other.remarkFieldSubTitleTextColor,
      remarkFieldSubTitleTextStyle: other.remarkFieldSubTitleTextStyle,
      cancelButtonBackgroundColor: other.cancelButtonBackgroundColor,
      cancelButtonTextStyle: other.cancelButtonTextStyle,
      cancelButtonTextColor: other.cancelButtonTextColor,
      reportButtonBackgroundColor: other.reportButtonBackgroundColor,
      reportButtonActiveBackgroundColor: other.reportButtonActiveBackgroundColor,
      reportButtonTextStyle: other.reportButtonTextStyle,
      reportButtonTextColor: other.reportButtonTextColor,
      errorTextColor: other.errorTextColor,
      errorTextStyle: other.errorTextStyle,
    );
  }

  @override
  ThemeExtension<CometChatFlagMessageStyle> lerp(
      covariant ThemeExtension<CometChatFlagMessageStyle>? other, double t) {
    return this;
  }
}

/// A dialog widget that allows users to flag/report a message.
///
/// Shows a list of reason chips fetched from the backend, an optional
/// remark text field, and cancel/report buttons.
class CometChatFlagMessageDialog extends StatefulWidget {
  const CometChatFlagMessageDialog({
    super.key,
    required this.message,
    this.style,
    this.flagReasonLocalizer,
    this.hideFlagRemarkField,
  });

  /// The message being reported.
  final BaseMessage message;

  /// Style customization for the dialog.
  final CometChatFlagMessageStyle? style;

  /// Custom localizer function for reason IDs.
  final String Function(String reasonId)? flagReasonLocalizer;

  /// Whether to hide the optional remark text field.
  final bool? hideFlagRemarkField;

  @override
  State<CometChatFlagMessageDialog> createState() =>
      _CometChatFlagMessageDialogState();
}

class _CometChatFlagMessageDialogState
    extends State<CometChatFlagMessageDialog> {
  List<FlagReason> _reasons = [];
  int? _selectedReasonIndex;
  final TextEditingController _remarkController = TextEditingController();
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _hasError = false;
  String _errorMessage = '';

  late CometChatColorPalette _colorPalette;
  late CometChatTypography _typography;
  late CometChatSpacing _spacing;
  bool _themeInitialized = false;

  /// Default translations for known reason IDs.
  Map<String, String> _defaultTranslatedReasons = {};

  @override
  void initState() {
    super.initState();
    _remarkController.addListener(_onTextChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_themeInitialized) {
      _colorPalette = CometChatThemeHelper.getColorPalette(context);
      _typography = CometChatThemeHelper.getTypography(context);
      _spacing = CometChatThemeHelper.getSpacing(context);
      _loadDefaultReasonTranslations();
      _themeInitialized = true;
      _fetchReasons();
    }
  }

  void _loadDefaultReasonTranslations() {
    _defaultTranslatedReasons = {
      "spam": Translations.of(context).spam,
      "sexual": Translations.of(context).sexual,
      "harassment": Translations.of(context).harassment,
    };
  }

  void _fetchReasons() {
    setState(() => _isLoading = true);
    CometChat.getFlagReasons(
      onSuccess: (reasons) {
        if (mounted) {
          setState(() {
            _reasons = reasons;
            _isLoading = false;
          });
        }
      },
      onError: (excep) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage =
                Translations.of(context).somethingWentWrongError;
          });
        }
      },
    );
  }

  String _getLocalizedReason(FlagReason reason) {
    if (widget.flagReasonLocalizer != null) {
      return widget.flagReasonLocalizer!(reason.id);
    }
    return _defaultTranslatedReasons[reason.id] ?? reason.name;
  }

  void _onTextChanged() {
    setState(() {});
  }

  void _toggleReason(int index) {
    setState(() {
      if (_selectedReasonIndex == index) {
        _selectedReasonIndex = null;
      } else {
        _selectedReasonIndex = index;
      }
    });
  }

  bool get _isReportEnabled => _selectedReasonIndex != null;

  void _submitReport() {
    if (_selectedReasonIndex == null) return;

    setState(() {
      _isSubmitting = true;
      _hasError = false;
    });

    final detail = FlagDetail(
      reasonId: _reasons[_selectedReasonIndex!].id,
      remark: _remarkController.text.isNotEmpty
          ? _remarkController.text
          : null,
    );

    CometChat.flagMessage(
      widget.message.id,
      detail,
      onSuccess: (result) {
        if (mounted) {
          Navigator.pop(context, true);
          SnackBarUtils.show(
            Translations.of(context).messageReported,
            context,
            snackBarConfiguration: SnackBarConfiguration(
              backgroundColor: _colorPalette.success,
            ),
          );
        }
      },
      onError: (excep) {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
            _hasError = true;
            _errorMessage = excep.details ??
                Translations.of(context).somethingWentWrongError;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _remarkController.removeListener(_onTextChanged);
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? const CometChatFlagMessageStyle();

    return AlertDialog(
      backgroundColor:
          style.backgroundColor ?? _colorPalette.background1,
      shape: RoundedRectangleBorder(
        side: style.border ??
            BorderSide(
              color: _colorPalette.borderLight ?? Colors.transparent,
            ),
        borderRadius: style.borderRadius as BorderRadius? ??
            BorderRadius.circular(_spacing.radius5 ?? 16),
      ),
      titlePadding: EdgeInsets.fromLTRB(
        _spacing.padding5 ?? 20,
        _spacing.padding5 ?? 20,
        _spacing.padding5 ?? 20,
        0,
      ),
      contentPadding: EdgeInsets.fromLTRB(
        _spacing.padding5 ?? 20,
        _spacing.padding3 ?? 12,
        _spacing.padding5 ?? 20,
        0,
      ),
      actionsPadding: EdgeInsets.all(_spacing.padding5 ?? 20),
      title: _buildTitle(style),
      content: _buildContent(style),
      actions: [_buildActions(style)],
    );
  }

  Widget _buildTitle(CometChatFlagMessageStyle style) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                Translations.of(context).reportMessage,
                style: style.titleTextStyle ??
                    TextStyle(
                      color: style.titleTextColor ??
                          _colorPalette.textPrimary,
                      fontFamily: _typography.heading2?.bold?.fontFamily,
                      fontWeight: _typography.heading2?.bold?.fontWeight,
                      fontSize: _typography.heading2?.bold?.fontSize,
                    ),
              ),
            ),
            Semantics(
              label: Translations.of(context).cancel,
              button: true,
              child: GestureDetector(
                onTap: () => Navigator.pop(context, false),
                child: Icon(
                  Icons.close,
                  color: style.closeIconTint ?? _colorPalette.iconPrimary,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: _spacing.padding2 ?? 8),
        Text(
          Translations.of(context).reportChatInfo,
          style: style.subTitleTextStyle ??
              TextStyle(
                color: style.subTitleTextColor ??
                    _colorPalette.textSecondary,
                fontFamily: _typography.button?.regular?.fontFamily,
                fontWeight: _typography.button?.regular?.fontWeight,
                fontSize: _typography.button?.regular?.fontSize,
              ),
        ),
      ],
    );
  }

  Widget _buildContent(CometChatFlagMessageStyle style) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: _spacing.padding3 ?? 12),
          // Reason chips
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          else
            Wrap(
              spacing: _spacing.padding2 ?? 8,
              runSpacing: _spacing.padding2 ?? 8,
              children: List.generate(_reasons.length, (index) {
                final isSelected = _selectedReasonIndex == index;
                return Semantics(
                  label: _getLocalizedReason(_reasons[index]),
                  selected: isSelected,
                  button: true,
                  child: GestureDetector(
                    onTap: () => _toggleReason(index),
                    child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: _spacing.padding1 ?? 4,
                      horizontal: _spacing.padding3 ?? 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (style.chipActiveBackgroundColor ??
                              _colorPalette.extendedPrimary100)
                          : (style.chipBackgroundColor ??
                              _colorPalette.background1),
                      border: isSelected
                          ? (style.chipActiveBorder ??
                              Border.all(
                                color:
                                    _colorPalette.extendedPrimary200 ??
                                        Colors.blue,
                              ))
                          : (style.chipBorder ??
                              Border.all(
                                color: _colorPalette.borderDefault ??
                                    Colors.grey,
                              )),
                      borderRadius: style.chipBorderRadius ??
                          BorderRadius.circular(
                              _spacing.radiusMax ?? 100),
                    ),
                    child: Text(
                      _getLocalizedReason(_reasons[index]),
                      style: isSelected
                          ? (style.chipActiveTitleTextStyle ??
                              TextStyle(
                                color:
                                    style.chipActiveTitleTextColor ??
                                        _colorPalette.textHighlight,
                                fontFamily: _typography
                                    .body?.medium?.fontFamily,
                                fontWeight: _typography
                                    .body?.medium?.fontWeight,
                                fontSize:
                                    _typography.body?.medium?.fontSize,
                              ))
                          : (style.chipTitleTextStyle ??
                              TextStyle(
                                color: style.chipTitleTextColor ??
                                    _colorPalette.textPrimary,
                                fontFamily: _typography
                                    .body?.regular?.fontFamily,
                                fontWeight: _typography
                                    .body?.regular?.fontWeight,
                                fontSize: _typography
                                    .body?.regular?.fontSize,
                              )),
                    ),
                  ),
                  ),
                );
              }),
            ),

          // Remark field
          if (widget.hideFlagRemarkField != true) ...[
            SizedBox(height: _spacing.padding4 ?? 16),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${Translations.of(context).reason} ',
                    style: style.remarkFieldTitleTextStyle ??
                        TextStyle(
                          color: style.remarkFieldTitleTextColor ??
                              _colorPalette.textPrimary,
                          fontFamily:
                              _typography.body?.medium?.fontFamily,
                          fontWeight:
                              _typography.body?.medium?.fontWeight,
                          fontSize: _typography.body?.medium?.fontSize,
                        ),
                  ),
                  TextSpan(
                    text: '(${Translations.of(context).optional})',
                    style: style.remarkFieldSubTitleTextStyle ??
                        TextStyle(
                          color: style.remarkFieldHintTextColor ??
                              _colorPalette.textTertiary,
                          fontFamily:
                              _typography.body?.regular?.fontFamily,
                          fontWeight:
                              _typography.body?.regular?.fontWeight,
                          fontSize:
                              _typography.body?.regular?.fontSize,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(height: _spacing.padding2 ?? 8),
            TextField(
              controller: _remarkController,
              maxLines: 6,
              minLines: 3,
              decoration: InputDecoration(
                hintText:
                    Translations.of(context).additionalContext,
                hintStyle: style.remarkFieldHintTextStyle ??
                    TextStyle(
                      color: style.remarkFieldHintTextColor ??
                          _colorPalette.textTertiary,
                      fontFamily:
                          _typography.body?.regular?.fontFamily,
                      fontWeight:
                          _typography.body?.regular?.fontWeight,
                      fontSize: _typography.body?.regular?.fontSize,
                    ),
                filled: true,
                fillColor: style.remarkFieldBackgroundColor ??
                    _colorPalette.background2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      _spacing.radius2 ?? 8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.all(
                    _spacing.padding3 ?? 12),
              ),
              style: style.remarkFieldTextStyle ??
                  TextStyle(
                    color: style.remarkFieldTextColor ??
                        _colorPalette.textPrimary,
                    fontFamily:
                        _typography.body?.regular?.fontFamily,
                    fontWeight:
                        _typography.body?.regular?.fontWeight,
                    fontSize: _typography.body?.regular?.fontSize,
                  ),
            ),
          ],

          // Error text
          if (_hasError) ...[
            SizedBox(height: _spacing.padding2 ?? 8),
            Text(
              _errorMessage,
              style: style.errorTextStyle ??
                  TextStyle(
                    color: style.errorTextColor ?? _colorPalette.error,
                    fontFamily:
                        _typography.caption1?.regular?.fontFamily,
                    fontWeight:
                        _typography.caption1?.regular?.fontWeight,
                    fontSize:
                        _typography.caption1?.regular?.fontSize,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(CometChatFlagMessageStyle style) {
    return Row(
      children: [
        // Cancel button
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context, false),
            style: ElevatedButton.styleFrom(
              backgroundColor: style.cancelButtonBackgroundColor ??
                  _colorPalette.background1,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(_spacing.radius2 ?? 8),
                side: BorderSide(
                  color: _colorPalette.borderDefault ?? Colors.grey,
                ),
              ),
              padding: EdgeInsets.symmetric(
                  vertical: _spacing.padding3 ?? 12),
            ),
            child: Text(
              Translations.of(context).cancel,
              style: style.cancelButtonTextStyle ??
                  TextStyle(
                    color: style.cancelButtonTextColor ??
                        _colorPalette.textPrimary,
                    fontFamily: _typography.button?.medium?.fontFamily,
                    fontWeight: _typography.button?.medium?.fontWeight,
                    fontSize: _typography.button?.medium?.fontSize,
                  ),
            ),
          ),
        ),
        SizedBox(width: _spacing.padding3 ?? 12),
        // Report button
        Expanded(
          child: ElevatedButton(
            onPressed: _isReportEnabled && !_isSubmitting
                ? _submitReport
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isReportEnabled
                  ? (style.reportButtonActiveBackgroundColor ??
                      _colorPalette.primary)
                  : (style.reportButtonBackgroundColor ??
                      _colorPalette.background4),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(_spacing.radius2 ?? 8),
              ),
              padding: EdgeInsets.symmetric(
                  vertical: _spacing.padding3 ?? 12),
            ),
            child: _isSubmitting
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: style.reportButtonTextColor ??
                          _colorPalette.white,
                    ),
                  )
                : Text(
                    Translations.of(context).report,
                    style: style.reportButtonTextStyle ??
                        TextStyle(
                          color: style.reportButtonTextColor ??
                              _colorPalette.white,
                          fontFamily:
                              _typography.button?.medium?.fontFamily,
                          fontWeight:
                              _typography.button?.medium?.fontWeight,
                          fontSize:
                              _typography.button?.medium?.fontSize,
                        ),
                  ),
          ),
        ),
      ],
    );
  }
}
