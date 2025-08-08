import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:flutter/material.dart';


///[CometChatChangeScope] is a stateful widget which allows user to change the scope of a group member
///
/// ```dart
/// CometChatChangeScope(
///  group: group,
///  member: member,
///  onSave: (group, member, newScope, oldScope) async {
///  // code to save the new scope
///  },
///  style: CometChatChangeScopeStyle(
///  backgroundColor: Colors.white,
///  iconColor: Colors.black,
///  iconBackgroundColor: Colors.grey.shade100,
///  titleTextStyle: TextStyle(
///  color: Colors.black,
///  fontSize: 20,
///  fontWeight: FontWeight.bold,
///  ),
///  ),
/// );
/// ```
class CometChatChangeScope extends StatefulWidget {
  const CometChatChangeScope({
    super.key,
    required this.group,
    required this.member,
    this.onSave,
    this.style,
    this.padding
  });

  ///[group] is the group for which scope is to be changed
  final Group group;

  ///[member] is the member for which scope is to be changed
  final GroupMember member;

  ///[onSave] is a callback which will be called when scope is changed
  final Future<void> Function(
      Group group, GroupMember member, String newScope, String oldScope)? onSave;

  ///[style] to be used to style this widget
  final CometChatChangeScopeStyle? style;

  final EdgeInsetsGeometry? padding;

  @override
  State<CometChatChangeScope> createState() => _CometChatChangeScopeState();
}

class _CometChatChangeScopeState extends State<CometChatChangeScope> {

  List<String> scopes = ['Admin', 'Moderator', 'Participant'];
  late String? selectedScope;

  late CometChatColorPalette colorPalette;
  late CometChatTypography typography;
  late CometChatSpacing spacing;
  late CometChatChangeScopeStyle style;

  @override
  void initState() {
    selectedScope=widget.member.scope ?? "";
    super.initState();
  }

  @override
  void didChangeDependencies() {
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    typography = CometChatThemeHelper.getTypography(context);
    spacing = CometChatThemeHelper.getSpacing(context);
    style= CometChatThemeHelper.getTheme<CometChatChangeScopeStyle>(context: context, defaultTheme: CometChatChangeScopeStyle.of).merge(widget.style);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {

    return ClipRRect(
      borderRadius: style.borderRadius ?? BorderRadius.only(
        topLeft: Radius.circular(spacing.radius5 ?? 0),
        topRight: Radius.circular(spacing.radius5 ?? 0),
      ),
      child: Container(
        padding: widget.padding ?? EdgeInsets.fromLTRB(spacing.padding5 ?? 0,spacing.padding9 ?? 0,spacing.padding5 ?? 0,spacing.padding5 ?? 0),
        decoration: BoxDecoration(
          color: style.backgroundColor ?? colorPalette.background1,
          border: style.border,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(spacing.radius5 ?? 0),
            topRight: Radius.circular(spacing.radius5 ?? 0),
          ),
        ),
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          Container(
          padding: EdgeInsets.all(spacing.padding4 ?? 0),
          decoration: BoxDecoration(
            color: style.iconBackgroundColor ?? Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child:
              Image.asset(
                AssetConstants.changeScope96px,
                package: UIConstants.packageName,
                height: 48,
                width: 48,
                color: style.iconColor,
              )
        ),
            const SizedBox(height: 20),
             Text(
              Translations.of(context).changeScope,
              style: TextStyle(
                fontSize: typography.heading2?.medium?.fontSize,
                fontWeight: typography.heading2?.medium?.fontWeight,
                fontFamily: typography.heading2?.medium?.fontFamily,
                color: colorPalette.textPrimary,
              ).merge(style.titleTextStyle),
            ),
            const SizedBox(height: 8),
             Padding(
               padding: EdgeInsets.symmetric(horizontal: spacing.padding10 ?? 0),
               child: Text(
                Translations.of(context).changeScopeSubtitle,
                style: TextStyle(
                  fontSize: typography.body?.regular?.fontSize,
                  fontWeight: typography.body?.regular?.fontWeight,
                  fontFamily: typography.body?.regular?.fontFamily,
                  color: colorPalette.textSecondary,
                ).merge(style.subtitleTextStyle),
                textAlign: TextAlign.center,
                         ),
             ),
            const SizedBox(height: 12),
            Container(
              // padding: EdgeInsets.all(0.5),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                border: style.scopeSectionBorder ?? Border.all(
                  color: colorPalette.borderLight ?? Colors.transparent,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(spacing.radius2 ?? 0),
              ),
              child:
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
          for(int i=0;i<scopes.length;i++)
            _buildScopeTile(i,style, colorPalette, typography, spacing)

                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: spacing.padding2 ?? 0,
                      ),
                      child: TextButton(
                        onPressed:() {
                              Navigator.of(context).pop();
                            },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            style.cancelButtonBackgroundColor,
                          ),
                          side: WidgetStateProperty.all(
                            style.cancelButtonBorder ?? BorderSide(
                              color: colorPalette.borderDark ??
                                  Colors.transparent,
                              width: 1,
                            ),
                          ),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              side:style.cancelButtonBorder ?? BorderSide(
                                color: colorPalette.borderDark ??
                                    Colors.transparent,
                                width: 1,
                              ),
                              borderRadius:style.cancelButtonBorderRadius ?? BorderRadius.all(
                                Radius.circular(
                                  spacing.radius2 ?? 0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        child: Text(
                             Translations.of(context).cancel,
                              style: TextStyle(
                                fontSize: typography.button?.medium?.fontSize,
                                fontWeight:
                                typography.button?.medium?.fontWeight,
                                fontFamily:
                                typography.button?.medium?.fontFamily,
                                color:
                                    colorPalette.textPrimary,
                              ).merge(style.cancelButtonTextStyle),
                            ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: TextButton(
                      onPressed: () async{
                        if (selectedScope != null) {
                          String oldScope = widget.member.scope ?? "";
                          if (oldScope == selectedScope) return;
                          if (widget.onSave != null) {
                            try {
                              await widget.onSave!(
                                  widget.group, widget.member, selectedScope!, oldScope);
                            } catch (_) {}
                          }
                        }
                            if(context.mounted){
                              Navigator.of(context).pop();
                            }
                          },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          style.saveButtonBackgroundColor ??  ((widget.member.scope == selectedScope) ? colorPalette.neutral300 : colorPalette.buttonBackground),
                        ),
                        side: WidgetStateProperty.all(
                          style.saveButtonBorder ?? BorderSide(
                            color:((widget.member.scope == selectedScope) ? colorPalette.neutral300 :
                            colorPalette.borderHighlight)?? Colors.transparent,
                            width: 1,
                          ),
                        ),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            side: style.saveButtonBorder ?? BorderSide(
                              color: colorPalette.borderDark ??
                                  Colors.transparent,
                              width: 1,
                            ),
                            borderRadius:style.saveButtonBorderRadius ?? BorderRadius.all(
                              Radius.circular(
                                spacing.radius2 ?? 0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      child: Text(
                            Translations.of(context).save,
                            style: TextStyle(
                              fontSize: typography.button?.medium?.fontSize,
                              fontWeight:
                              typography.button?.medium?.fontWeight,
                              fontFamily:
                              typography.button?.medium?.fontFamily,
                              color:
                              // confirmDialogStyle.confirmButtonTextColor ??
                                  colorPalette.white,
                            ).merge(style.saveButtonTextStyle)
                          )
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScopeTile(int index,CometChatChangeScopeStyle style, CometChatColorPalette colorPalette, CometChatTypography typography, CometChatSpacing spacing){
    bool isSelected = scopes[index].toLowerCase() == selectedScope;
    final tile = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isSelected? (style.selectedTileColor ?? colorPalette.borderLight):(style.tileColor ?? colorPalette.background1),
            borderRadius: BorderRadius.only(
              topLeft: index==0?Radius.circular(spacing.radius2 ?? 0):Radius.zero,
              topRight: index==0?Radius.circular(spacing.radius2 ?? 0):Radius.zero,
              bottomLeft: index==scopes.length-1?Radius.circular(spacing.radius2 ?? 0):Radius.zero,
              bottomRight: index==scopes.length-1?Radius.circular(spacing.radius2 ?? 0):Radius.zero,
            ),
      ),
      child: ListTile(
        title: Text(scopes[index],
        style: TextStyle(
          color: isSelected? colorPalette.textPrimary:colorPalette.textSecondary,
          fontSize: typography.body?.medium?.fontSize,
          fontWeight: typography.body?.medium?.fontWeight,
          fontFamily: typography.body?.medium?.fontFamily,
        ).merge(isSelected? style.selectedScopeTextStyle:style.scopeTextStyle),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: spacing.padding4 ?? 0,
        ),
        // minLeadingWidth: 0,
        minVerticalPadding: 0,
        selected: isSelected,
        trailing: Transform.scale(
          scale: 1.2,
          origin: const Offset(-10, 0),
          child: Radio(

            value: scopes[index].toLowerCase(),
            groupValue: selectedScope,
            fillColor: WidgetStatePropertyAll(isSelected? (style.radioButtonSelectedColor ?? colorPalette.borderHighlight):(style.radioButtonColor ?? colorPalette.borderDefault)),
            onChanged: (String? value) {

              setState(() {
                selectedScope = value?.toLowerCase();
              });
            },
          ),
        ),
      ),
    );

    return tile;
  }
}