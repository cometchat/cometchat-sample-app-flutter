import 'package:flutter/material.dart';
import '../../../../../../cometchat_chat_uikit.dart';

/// [CometChatStickerKeyboard] renders a keyboard consisting of stickers provided by the extension
///
/// ```dart
/// CometChatStickerKeyboard(
///   theme: CometChatTheme(),
///   onStickerTap: (sticker) {
///     print('Sticker tapped: ${sticker.id}');
///   },
///   errorIcon: Icon(Icons.error),
///   emptyStateView: (context) => Center(child: Text('No stickers')),
///   errorStateView: (context) => Center(child: Text('Error fetching stickers')),
///   loadingStateView: (context) => Center(child: CircularProgressIndicator()),
///   errorStateText: 'Failed to load stickers',
///   emptyStateText: 'No stickers available',
///   keyboardStyle: StickerKeyboardStyle(),
/// );
///
/// ```
class CometChatStickerKeyboard extends StatefulWidget {
  const CometChatStickerKeyboard({
    super.key,
    this.onStickerTap,
    this.loadingStateView,
    this.errorStateView,
    this.emptyStateView,
  });

  ///[onStickerTap] takes the call back function on tap of some sticker
  final void Function(Sticker)? onStickerTap;

  ///[emptyStateView] to be shown when there are no stickers
  final WidgetBuilder? emptyStateView;

  ///[errorStateView] is shown when some error occurs on loading the stickers
  final WidgetBuilder? errorStateView;

  ///[loadingStateView] view at loading state
  final WidgetBuilder? loadingStateView;

  @override
  State<CometChatStickerKeyboard> createState() =>
      _CometChatStickerKeyboardState();
}

class _CometChatStickerKeyboardState extends State<CometChatStickerKeyboard> {
  Map<int, List<Sticker>> defaultStickersMap = {};
  List<int> stickerSets = [];
  late int selectedSet;
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();

    CometChat.callExtension(
        ExtensionConstants.stickers, 'GET', ExtensionUrls.stickers, null,
        onSuccess: (Map<String, dynamic> map) {
      _getStickers(map);
    }, onError: (CometChatException excep) {
      debugPrint('$excep');
      isError = true;
      isLoading = false;
      setState(() {});
    });
  }

  _getStickers(Map<String, dynamic> map) {
    List<Map<String, dynamic>> defaultStickers =
        List<Map<String, dynamic>>.from(map["data"]['defaultStickers']);
    List<Map<String, dynamic>> customStickers =
        List<Map<String, dynamic>>.from(map["data"]['customStickers']);
    for (Map<String, dynamic> sticker in defaultStickers) {
      if (defaultStickersMap
          .containsKey(int.parse(sticker["stickerSetOrder"]))) {
        defaultStickersMap[int.parse(sticker["stickerSetOrder"])]
            ?.add(Sticker.fromJson(sticker));
      } else {
        defaultStickersMap[int.parse(sticker["stickerSetOrder"])] = [
          Sticker.fromJson(sticker)
        ];
      }
    }

    int defaultCategories = defaultStickersMap.keys.toList().length;

    for (Map<String, dynamic> sticker in customStickers) {
      if (defaultStickersMap.containsKey(
          int.parse(sticker["stickerSetOrder"]) + defaultCategories)) {
        defaultStickersMap[
                int.parse(sticker["stickerSetOrder"]) + defaultCategories]
            ?.add(Sticker(
                modifiedAt: sticker['modifiedAt'],
                stickerOrder: int.parse(sticker['stickerOrder']),
                stickerSetId: sticker['stickerSetId'],
                stickerUrl: sticker['stickerUrl'],
                createdAt: sticker['createdAt'],
                stickerSetName: sticker['stickerSetName'],
                id: sticker['id'],
                stickerSetOrder: int.parse(sticker['stickerSetOrder']),
                stickerName: sticker['stickerName']));
      } else {
        defaultStickersMap[
            int.parse(sticker["stickerSetOrder"]) + defaultCategories] = [
          Sticker(
              modifiedAt: sticker['modifiedAt'],
              stickerOrder: int.parse(sticker['stickerOrder']),
              stickerSetId: sticker['stickerSetId'],
              stickerUrl: sticker['stickerUrl'],
              createdAt: sticker['createdAt'],
              stickerSetName: sticker['stickerSetName'],
              id: sticker['id'],
              stickerSetOrder: int.parse(sticker['stickerSetOrder']),
              stickerName: sticker['stickerName'])
        ];
      }
    }

    stickerSets = defaultStickersMap.keys.toList();
    stickerSets.sort();
    selectedSet = stickerSets[0];
    isLoading = false;
    setState(() {});
  }

  Widget _getOnError(
    BuildContext context,
    CometChatColorPalette colorPalette,
    CometChatSpacing spacing,
    CometChatTypography typography,
  ) {
    if (widget.errorStateView != null) {
      return Center(child: widget.errorStateView!(context));
    } else {
      return Container(
        height: 296,
        width: double.infinity,
        color: colorPalette.background1,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: spacing.padding2 ?? 0,
            horizontal: spacing.padding3 ?? 0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: spacing.padding2 ?? 0,
                ),
                child: Text(
                  "Sticker pack name",
                  style: TextStyle(
                    fontSize: typography.body?.regular?.fontSize,
                    fontWeight: typography.body?.regular?.fontWeight,
                    fontFamily: typography.body?.regular?.fontFamily,
                    color: colorPalette.textTertiary,
                  ),
                ),
              ),
              SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    "${Translations.of(context).looksLikeSomethingWrong} \n ${Translations.of(context).pleaseTryAgain}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: typography.body?.regular?.fontSize,
                      fontWeight: typography.body?.regular?.fontWeight,
                      fontFamily: typography.body?.regular?.fontFamily,
                      color: colorPalette.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _getEmptyView(
    BuildContext context,
    CometChatColorPalette colorPalette,
    CometChatSpacing spacing,
    CometChatTypography typography,
  ) {
    if (widget.emptyStateView != null) {
      return Center(child: widget.emptyStateView!(context));
    } else {
      return Container(
        height: 296,
        width: double.infinity,
        color: colorPalette.background1,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: spacing.padding2 ?? 0,
            horizontal: spacing.padding3 ?? 0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: spacing.padding2 ?? 0,
                ),
                child: Text(
                  "Sticker pack name",
                  style: TextStyle(
                    fontSize: typography.body?.regular?.fontSize,
                    fontWeight: typography.body?.regular?.fontWeight,
                    fontFamily: typography.body?.regular?.fontFamily,
                    color: colorPalette.textTertiary,
                  ),
                ),
              ),
              SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: spacing.padding3 ?? 0,
                        ),
                        child: Image.asset(
                          AssetConstants.stickerFilled,
                          package: UIConstants.packageName,
                          height: 60,
                          width: 60,
                          color: colorPalette.iconTertiary,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: spacing.padding1 ?? 0,
                        ),
                        child: Text(
                          "No Stickers Available",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: typography.heading4?.bold?.fontSize,
                            fontWeight: typography.heading4?.bold?.fontWeight,
                            fontFamily: typography.heading4?.bold?.fontFamily,
                            color: colorPalette.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        "You don’t have any stickers yet.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: typography.body?.regular?.fontSize,
                          fontWeight: typography.body?.regular?.fontWeight,
                          fontFamily: typography.body?.regular?.fontFamily,
                          color: colorPalette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _getLoadingIndicator(
    CometChatColorPalette colorPalette,
    CometChatSpacing spacing,
    CometChatTypography typography,
  ) {
    if (widget.loadingStateView != null) {
      return Center(child: widget.loadingStateView!(context));
    } else {
      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: spacing.padding2 ?? 0,
            horizontal: spacing.padding3 ?? 0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: spacing.padding2 ?? 0,
                ),
                child: Text(
                  "Sticker pack name",
                  style: TextStyle(
                    fontSize: typography.body?.regular?.fontSize,
                    fontWeight: typography.body?.regular?.fontWeight,
                    fontFamily: typography.body?.regular?.fontFamily,
                    color: colorPalette.textTertiary,
                  ),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                itemCount: 6,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: spacing.padding5 ?? 0,
                  crossAxisSpacing: spacing.padding5 ?? 0,
                ),
                itemBuilder: (context, index) {
                  return CometChatShimmerEffect(
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          spacing.radius2 ?? 0,
                        ),
                        color: colorPalette.background1,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final typography = CometChatThemeHelper.getTypography(context);
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final spacing = CometChatThemeHelper.getSpacing(context);
    return Container(
      height: 296,
      decoration: BoxDecoration(
        color: colorPalette.background1,
      ),
      child:
          //---loading widget---
          isLoading
              ? _getLoadingIndicator(
                  colorPalette,
                  spacing,
                  typography,
                )
              //---on error---
              : isError
                  ? _getOnError(
                      context,
                      colorPalette,
                      spacing,
                      typography,
                    )
                  : stickerSets.isEmpty
                      ? _getEmptyView(
                          context,
                          colorPalette,
                          spacing,
                          typography,
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: spacing.padding3 ?? 0,
                                  right: spacing.padding3 ?? 0,
                                  top: spacing.padding2 ?? 0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: spacing.padding2 ?? 0,
                                      ),
                                      child: Text(
                                        defaultStickersMap[selectedSet]![0]
                                            .stickerSetName,
                                        style: TextStyle(
                                          fontSize: typography
                                              .body?.regular?.fontSize,
                                          fontWeight: typography
                                              .body?.regular?.fontWeight,
                                          fontFamily: typography
                                              .body?.regular?.fontFamily,
                                          color: colorPalette.textTertiary,
                                        ),
                                      ),
                                    ),
                                    //---stickers---
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: spacing.padding4 ?? 0,
                                        ),
                                        child: GridView.count(
                                          crossAxisCount: 3,
                                          mainAxisSpacing: 8,
                                          crossAxisSpacing: 8,
                                          children: [
                                            for (Sticker sticker
                                                in defaultStickersMap[
                                                        selectedSet] ??
                                                    [])
                                              GestureDetector(
                                                onTap: () {
                                                  if (widget.onStickerTap !=
                                                      null) {
                                                    widget
                                                        .onStickerTap!(sticker);
                                                  }
                                                },
                                                child: Image.network(
                                                  sticker.stickerUrl,
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    return loadingProgress ==
                                                            null
                                                        ? child
                                                        : Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                              color: colorPalette
                                                                  .iconPrimary,
                                                            ),
                                                          );
                                                  },
                                                  errorBuilder: (context,
                                                      object, stackTrace) {
                                                    return Image.asset(
                                                      AssetConstants
                                                          .imagePlaceholder,
                                                      package: UIConstants
                                                          .packageName,
                                                    );
                                                  },
                                                ),
                                                // FadeInImage(
                                                //   placeholder: CircularProgressIndicator(
                                                //     color: colorPalette.iconPrimary,
                                                //   ),
                                                //   fit: BoxFit.cover,
                                                //   fadeInDuration:
                                                //       const Duration(
                                                //           milliseconds: 100),
                                                //   fadeOutDuration:
                                                //       const Duration(
                                                //           milliseconds: 100),
                                                //   placeholderFit: BoxFit.cover,
                                                //   imageErrorBuilder: (context,
                                                //       object, stackTrace) {
                                                //     return Image.asset(
                                                //       AssetConstants
                                                //           .imagePlaceholder,
                                                //       package: UIConstants
                                                //           .packageName,
                                                //     );
                                                //   },
                                                //   image: NetworkImage(
                                                //     "sticker.stickerUrl",
                                                //   ),
                                                // ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: colorPalette.background1,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(
                                  spacing.padding2 ?? 0,
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: stickerSets.map(
                                      (stickerSetOrder) {
                                        final containerColor = selectedSet ==
                                                stickerSetOrder
                                            ? colorPalette.extendedPrimary100
                                            : colorPalette.background1;

                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedSet = stickerSetOrder;
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(
                                              spacing.padding2 ?? 0,
                                            ),
                                            decoration: BoxDecoration(
                                              color: containerColor,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      spacing.radiusMax ?? 0),
                                            ),
                                            child: Center(
                                              child: Image.network(
                                                defaultStickersMap[
                                                        stickerSetOrder]![0]
                                                    .stickerUrl,
                                                height: 28,
                                                width: 28,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return const Icon(Icons.image_not_supported); // Show fallback image
                                                  }
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
    );
  }
}

///[Sticker] is the model data class for storing the fetched stickers
class Sticker {
  final String? modifiedAt;
  final int stickerOrder;
  final String stickerSetId;
  final String stickerUrl;
  final String? createdAt;
  final String stickerSetName;
  final String id;
  final int stickerSetOrder;
  final String stickerName;

  const Sticker(
      {this.modifiedAt,
      required this.stickerOrder,
      required this.stickerSetId,
      required this.stickerUrl,
      this.createdAt,
      required this.stickerSetName,
      required this.id,
      required this.stickerSetOrder,
      required this.stickerName});

  factory Sticker.fromJson(Map<String, dynamic> json) {
    return Sticker(
        modifiedAt: json['modifiedAt'],
        stickerOrder: int.parse(json['stickerOrder']),
        stickerSetId: json['stickerSetId'],
        stickerUrl: json['stickerUrl'],
        createdAt: json['createdAt'],
        stickerSetName: json['stickerSetName'],
        id: json['id'],
        stickerSetOrder: int.parse(json['stickerSetOrder']),
        stickerName: json['stickerName']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['modifiedAt'] = modifiedAt;
    data['stickerOrder'] = stickerOrder;
    data['stickerSetId'] = stickerSetId;
    data['stickerUrl'] = stickerUrl;
    data['createdAt'] = createdAt;
    data['stickerSetName'] = stickerSetName;
    data['id'] = id;
    data['stickerSetOrder'] = stickerSetOrder;
    data['stickerName'] = stickerName;
    return data;
  }
}
