import 'package:cometchat_flutter_sample_app/utils/widget_card.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

WidgetProps getFileBubbleContainer(BuildContext context) {
  return WidgetProps(
    leadingImageURL: "assets/icons/folder.png",
    title: "File Bubble",
    description:
        "CometChatFileBubble displays a media message containing a file"
        "To learn more about this component tap here",
    onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 0.5,
                ),
                body: Center(
                    child: CometChatFileBubble(
                  theme: cometChatTheme,
                  fileUrl:
                      'https://data-us.cometchat.io/2379614bd4db65dd/media/1682517934_233027292_069741a92a2f641eb428ba6d12ccb9af.pdf',
                  title: 'File bubble',
                  style: const FileBubbleStyle(borderRadius: 6),
                ))),
          ));
    },
  );
}
