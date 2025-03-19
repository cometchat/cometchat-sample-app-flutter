import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

/// [CometChatButtonElement] is a button widget used in [FormMessage].
/// Use this widget along with [ButtonElementStyle] is used to modify the default style.
///
/// ```dart
/// CometChatButton(
///  text: "Button",
///  buttonStyle: ButtonElementStyle(
///  background: Colors.red,
///  ),
///  onTap: (context) {
///  //Action on button tap goes here
///  },
///  );
///  ```
///
class CometChatButtonElement extends StatefulWidget {
  const CometChatButtonElement(
      {super.key,
      required this.text,
      this.buttonStyle,
      this.onTap,
      this.loadingStateChildView});

  ///[text] is a string which sets the text for the button
  final String text;

  ///[buttonStyle] is a object of [ButtonElementStyle] which sets the style for the button
  final ButtonElementStyle? buttonStyle;

  ///[onTap] is a callback which gets called when button is clicked
  final Future<void> Function(BuildContext)? onTap;

  ///[loadingStateChildView] is a callback which shows the loading state view
  final WidgetBuilder? loadingStateChildView;

  @override
  State<CometChatButtonElement> createState() => _CometChatButtonElementState();
}

class _CometChatButtonElementState extends State<CometChatButtonElement> {
  bool isLoading = false;
  // late  Widget _loadingStateChildView;

  @override
  Widget build(BuildContext context) {
    // if(widget.loadingStateChildView!=null){
    //   _loadingStateChildView = widget.loadingStateChildView!(context);
    // }else{
    //   _loadingStateChildView =  Center(
    //     child: Image.asset(
    //       AssetConstants.spinner,
    //       package: UIConstants.packageName,
    //       color: cometChatTheme.palette.getBackground(),
    //     ),
    //   );
    // }

    return Center(
      child: InkWell(
        onTap: () async {
          setState(() {
            isLoading = true;
          });
          if (widget.onTap != null) {
            await widget.onTap!(context);
          }
          //await Future.delayed(Duration(seconds: 2));
          setState(() {
            isLoading = false;
          });
        },
        child: Container(
            padding: const EdgeInsets.all(8.0),
            height: widget.buttonStyle?.height,
            width: widget.buttonStyle?.width,
            decoration: BoxDecoration(
              color: widget.buttonStyle?.background,
              gradient: widget.buttonStyle?.gradient,
              border: widget.buttonStyle?.border,
              borderRadius:widget.buttonStyle?.borderRadius ??
                  BorderRadius.circular(4),
            ),
            child: isLoading == true
                ? Center(
                    child: Image.asset(
                      AssetConstants.spinner,
                      package: UIConstants.packageName,
                    ),
                  )
                : Center(
                    child: Text(
                      widget.text,
                      style: widget.buttonStyle?.buttonTextStyle,
                    ),
                  )),
      ),
    );
  }
}
