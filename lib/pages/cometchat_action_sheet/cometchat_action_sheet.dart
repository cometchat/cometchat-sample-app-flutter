import 'package:flutter/material.dart';
import 'action_item.dart';
import 'action_item.dart' as action_alias;

enum actionSheetLayoutMode { list, grid }

class CometChatActionSheet extends StatefulWidget {
  const CometChatActionSheet(
      {Key? key,
      required this.actionItems,
      this.title,
      this.titleStyle,
      this.layoutModeIcon,
      this.isLayoutModeIconVisible,
      this.isTitleVisible,
      this.isGridLayout})
      : super(key: key);

  final List<ActionItem> actionItems;
  final String? title;
  final TextStyle? titleStyle;
  final IconData? layoutModeIcon;
  final bool? isLayoutModeIconVisible;
  final bool? isTitleVisible;
  final bool? isGridLayout;

  @override
  _CometChatActionSheetState createState() => _CometChatActionSheetState();
}

class _CometChatActionSheetState extends State<CometChatActionSheet> {
  bool _isGridLayout = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.isGridLayout == true) _isGridLayout = true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!(widget.isLayoutModeIconVisible == false ||
              widget.isTitleVisible == false))
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.title ?? "Add to Chat",
                      style: widget.titleStyle ??
                          const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isGridLayout = !_isGridLayout;
                      });
                    },
                    child: CircleAvatar(
                      child: Icon(widget.layoutModeIcon ?? Icons.list),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.rectangle,
                color: Color(0xffeeeeee),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: Column(
                children: [
                  if (widget.actionItems.isEmpty)
                    const SizedBox(
                      height: 200,
                    ),
                  _isGridLayout == true
                      ? GridView.count(
                          crossAxisCount: 2,
                          childAspectRatio: 1.8,
                          shrinkWrap: true,
                          children: List.generate(
                              widget.actionItems.length,
                              (index) =>
                                  _getActionWidget(widget.actionItems[index])),
                        )
                      : Column(
                          children: List.generate(
                              widget.actionItems.length,
                              (index) =>
                                  _getActionWidget(widget.actionItems[index])),
                        )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _getActionWidget(ActionItem actionItem) {
    return _isGridLayout == true
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: (){
                Navigator.of(context).pop(actionItem);

              },
              child: Container(

                decoration: const  BoxDecoration(
                  shape: BoxShape.rectangle,
                  color:Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor:Colors.black12,
                        child: Icon(
                          actionItem.icon,
                            color: Colors.black
                        ),
                      ),
                      Text(actionItem.title)
                    ],
                  ),
                ),
              ),
            ),
          )
        : Card(
            color:  Colors.white,
            child: ListTile(
              onTap: () {
                Navigator.of(context).pop(actionItem);
              },
              leading: CircleAvatar(
                backgroundColor:
               Colors.black12,
                child: Icon(actionItem.icon,color: Colors.black,),
              ),
              title: Text(actionItem.title),
            ),
          );
  }
}


///Function to show comeChat action sheet
Future<ActionItem?>? showCometChatActionSheet(
    {required BuildContext context,
    required List<action_alias.ActionItem> actionItems,
    final String? title,
    final TextStyle? titleStyle,
    final IconData? layoutModeIcon,
    final bool? isLayoutModeIconVisible,
    final bool? isTitleVisible,
    final bool? isGridLayout,
    final ShapeBorder? alertShapeBorder}) {
  return showModalBottomSheet<ActionItem>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      enableDrag: true,
      shape: alertShapeBorder ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
      builder: (BuildContext context) => CometChatActionSheet(
          actionItems: actionItems,
          title: title,
          titleStyle: titleStyle,
          layoutModeIcon: layoutModeIcon,
          isLayoutModeIconVisible: isLayoutModeIconVisible,
          isTitleVisible: isTitleVisible,
          isGridLayout: isGridLayout)


      );
}
