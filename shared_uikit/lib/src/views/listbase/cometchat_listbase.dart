import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

///[CometChatListBase] is a top level container widget
///used internally by components like [CometChatUsers], [CometChatGroups], [CometChatConversations], [CometChatGroupMembers]
/// ```dart
///   CometChatListBase(
///        title: "title",
///        container: Container(),
///        style: ListBaseStyle(),
///    );
/// ```
class CometChatListBase extends StatefulWidget {
  /// Creates a widget that that gives CometChat ListBase UI
  const CometChatListBase({
    super.key,
    this.style = const ListBaseStyle(),
    this.backIcon,
    this.title,
    this.hideSearch = false,
    this.searchBoxIcon,
    required this.container,
    this.showBackButton = false,
    this.onSearch,
    this.menuOptions,
    this.placeholder,
    this.searchText,
    this.onBack,
    this.hideAppBar = false,
    this.searchPadding,
    this.searchBoxHeight,
    this.searchContentPadding,
    this.titleSpacing,
    this.titleView,
    this.leadingWidth,
    this.leadingIconPadding,
  });

  ///[style] styling properties
  final ListBaseStyle style;

  ///[showBackButton] show back button
  final bool? showBackButton;

  ///[placeholder] hint text to be shown in search box
  final String? placeholder;

  ///[backIcon] back button icon
  final Widget? backIcon;

  ///[title] title string
  final String? title;

  ///[hideSearch] show the search box
  final bool? hideSearch;

  ///[searchBoxIcon] search box prefix icon
  final Widget? searchBoxIcon;

  ///[container] listview of users
  final Widget container;

  ///[menuOptions] list of widgets options to be shown
  final List<Widget>? menuOptions;

  ///[onSearch] onSearch callback
  final void Function(String val)? onSearch;

  ///[searchText] initial text to be searched
  final String? searchText;

  ///[onBack] callback triggered on closing a screen
  final VoidCallback? onBack;

  ///[theme] to specify custom theme
  final bool? hideAppBar;

  ///[searchPadding] to specify padding for search box
  final EdgeInsetsGeometry? searchPadding;

  ///[searchBoxHeight] to specify height of search box
  final double? searchBoxHeight;

  ///[searchContentPadding] to specify content padding for search box
  final EdgeInsetsGeometry? searchContentPadding;

  ///[titleSpacing] to specify title spacing
  final double? titleSpacing;

  ///[titleView] to specify title view
  final Widget? titleView;

  ///[leadingWidth] to specify leading width
  final double? leadingWidth;

  ///[leadingIconPadding] to specify leading icon padding
  final EdgeInsetsGeometry? leadingIconPadding;

  @override
  State<CometChatListBase> createState() => _CometChatListBaseState();
}

class _CometChatListBaseState extends State<CometChatListBase> {
  late TextEditingController _searchController;

  /// returns back button to be shown in appbar
  Widget? getBackButton(context) {
    Widget? backButton;
    if (widget.showBackButton != null && widget.showBackButton == true) {
      backButton = IconButton(
        onPressed: widget.onBack ??
            () {
              Navigator.pop(context);
            },
        padding: widget.leadingIconPadding ?? EdgeInsets.zero,
        color: widget.style.backIconTint,
        icon: widget.backIcon ??
            Image.asset(
              AssetConstants.back,
              package: UIConstants.packageName,
              color: widget.style.backIconTint,
              height: 24,
              width: 24,
            ),
      );
    }
    return backButton;
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchText ?? '');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.style.borderRadius ?? BorderRadius.zero,
      child: Container(
        decoration: BoxDecoration(
          gradient: widget.style.gradient,
          border: widget.style.border,
          borderRadius: widget.style.borderRadius,
        ),
        child: Scaffold(
          //appbar with back button and menu options

          appBar: widget.hideAppBar == true
              ? null
              : AppBar(
                  elevation: 0,
                  toolbarHeight: 56,
                  title: widget.titleView ??
                      Text(
                        widget.title ?? "",
                        style: widget.style.titleStyle,
                      ),
                  shape: widget.style.appBarShape,
                  backgroundColor: widget.style.appBarBackground ?? widget.style.background,
                  leading: getBackButton(context),
                  leadingWidth: widget.leadingWidth ??
                      (widget.showBackButton == true ? 40 : 0),
                  automaticallyImplyLeading: widget.showBackButton ?? false,
                  actions: widget.menuOptions ?? [],
                  centerTitle: false,
                  titleSpacing: widget.titleSpacing,
                ),

          backgroundColor: widget.style.background,
          body: Padding(
            padding: widget.style.padding ??
                const EdgeInsets.only(left: 0, right: 0),
            child: SizedBox(
              height: widget.style.height,
              width: widget.style.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //-----------------------------------
                  //----------show search box----------
                  if (widget.hideSearch == false)
                    Padding(
                      padding: widget.searchPadding ?? const EdgeInsets.all(0),
                      child: SizedBox(
                        height: widget.searchBoxHeight,
                        child: Center(
                          child: TextField(
                            keyboardAppearance:
                                CometChatThemeHelper.getBrightness(context) ==
                                        Brightness.dark
                                    ? Brightness.dark
                                    : Brightness.light,
                            key: widget.key,
                            //--------------------------------------
                            //----------on search callback----------
                            controller: _searchController,
                            onChanged: widget.onSearch,
                            style: widget.style.searchTextStyle,
                            //-----------------------------------------
                            //----------search box decoration----------
                            decoration: InputDecoration(
                              contentPadding: widget.searchContentPadding ??
                                  const EdgeInsets.all(0),
                              hintText: widget.placeholder ??
                                  Translations.of(context).search,
                              prefixIcon: widget.searchBoxIcon ??
                                  Icon(
                                    Icons.search,
                                    color: widget.style.searchIconTint,
                                    size: 24,
                                  ),
                              prefixIconColor: widget.style.searchIconTint,
                              hintStyle: widget.style.searchPlaceholderStyle,

                              //-------------------------------------
                              //----------search box border----------
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    widget.style.borderSide ?? BorderSide.none,
                                borderRadius:
                                    widget.style.searchTextFieldRadius ??
                                        BorderRadius.circular(28),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    widget.style.borderSide ?? BorderSide.none,
                                borderRadius:
                                    widget.style.searchTextFieldRadius ??
                                        BorderRadius.circular(
                                          28,
                                        ),
                              ),
                              border: OutlineInputBorder(
                                borderSide:
                                    widget.style.borderSide ?? BorderSide.none,
                                borderRadius:
                                    widget.style.searchTextFieldRadius ??
                                        BorderRadius.circular(
                                          28,
                                        ),
                              ),

                              //-----------------------------------------
                              //----------search box fill color----------
                              fillColor: widget.style.searchBoxBackground,
                              filled: true,
                            ),
                          ),
                        ),
                      ),
                    ),

                  //--------------------------------
                  //----------showing list----------
                  Expanded(child: widget.container)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
