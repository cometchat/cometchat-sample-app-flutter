import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

///[CometChatWebView] is widget that renders a WebView
class CometChatWebView extends StatefulWidget {
  const CometChatWebView(
      {super.key,
      required this.title,
      required this.webViewUrl,
      this.backIcon,
      this.appBarColor,
      this.webViewStyle,
      });

  ///[title] of the page
  final String title;

  ///WebView package use [webViewUrl] to render page
  final String webViewUrl;

  ///[backIcon] displays back  Icon
  final Icon? backIcon;

  ///[appBarColor] , default is Color(0xffFFFFFF)
  final Color? appBarColor;

  ///[webViewStyle] , web view styling properties
  final WebViewStyle? webViewStyle;

  @override
  State<CometChatWebView> createState() => _CometChatWebViewState();
}

class _CometChatWebViewState extends State<CometChatWebView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.appBarColor ?? const Color(0xffFFFFFF),
        elevation: 0,
        toolbarHeight: 56,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: widget.backIcon ??
              Icon(
                Icons.close,
                size: 24,
                color: widget.webViewStyle?.backIconColor ??
                    const Color(0xff3399FF),
              ),
        ),
        title: Text(
          widget.title,
          style: widget.webViewStyle?.titleStyle ??
              const TextStyle(
                  color: Color(0xff141414),
                  fontSize: 20,
                  fontWeight: FontWeight.w500),
        ),
      ),
      body: Stack(children: <Widget>[
        WebViewWidget(
            controller: WebViewController()
              ..loadRequest(Uri.parse(widget.webViewUrl))
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
            // javascriptMode: ,
            ),
      ]),
    );
  }
}
