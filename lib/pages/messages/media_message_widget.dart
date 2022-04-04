import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cometchat/cometchat_sdk.dart';
import 'package:cometchat/models/action.dart' as c;
import 'package:path_provider/path_provider.dart';
import 'package:sdk_tutorial/Utils/loading_indicator.dart';
import 'package:sdk_tutorial/constants.dart';
import 'package:open_file/open_file.dart';
import 'package:sdk_tutorial/pages/messages/message_receipts.dart';


class MediaMessageWidget extends StatefulWidget {
  final MediaMessage passedMessage;
  const MediaMessageWidget({Key? key, required this.passedMessage})
      : super(key: key);

  @override
  _MediaMessageState createState() => _MediaMessageState();
}

class _MediaMessageState extends State<MediaMessageWidget> {
  String? text;
  bool sentByMe = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool _isDownloading = false;

    if (USERID == widget.passedMessage.sender!.uid) {
      sentByMe = true;
      //print(CometChatInitialValues.CometChat_Default_Date);
    } else {
      sentByMe = false;
    }
    if (widget.passedMessage is TextMessage) {
      text = (widget.passedMessage as TextMessage).text;
    } else if (widget.passedMessage is c.Action) {
      text = (widget.passedMessage as c.Action).message;
    }

    Color background = sentByMe==true?const Color(0xff3399FF).withOpacity(0.92) : const Color(0xffF8F8F8).withOpacity(0.92);
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment:
              sentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (widget.passedMessage.type == CometChatMessageType.image)
              Card(
                color: background,
                child: Column(
                  children: [
                   SizedBox(
                        child: Image.network(
                            widget.passedMessage.attachment!.fileUrl, width: 150,height: 150,fit: BoxFit.fill),
                      ),
                    Text("Fixed Caption")
                  ],
                ),
              ),
            if (widget.passedMessage.type == CometChatMessageType.video)
              FileCard(passedMessage: widget.passedMessage,backgroundColor: background,),
            if (widget.passedMessage.type == CometChatMessageType.file)
              FileCard(passedMessage: widget.passedMessage,backgroundColor: background,),
            if (widget.passedMessage.type == CometChatMessageType.audio)
              FileCard(passedMessage: widget.passedMessage,backgroundColor: background,),
            if (sentByMe == true)
            MessageReceipts(passedMessage: widget.passedMessage)

          ],
        ));
  }



}


class FileCard extends StatefulWidget {
  final MediaMessage passedMessage;
  final Color backgroundColor;
  const FileCard({Key? key, required this.passedMessage,
  required this.backgroundColor
  }) : super(key: key);

  @override
  _FileCardState createState() => _FileCardState();
}

class _FileCardState extends State<FileCard> {
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {

      return Card(
        color: widget.backgroundColor,
      child: Column(
        children: [
          SizedBox(
            height: 100,
            width: 150,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: Text(widget.passedMessage.attachment!.fileName),),
            ),
          ),
          GestureDetector(
            onTap: ()async {
              setState(() {
                _isDownloading = true;
              });
              File ab = await _downloadFile(
                  widget.passedMessage.attachment!.fileUrl,
                  widget.passedMessage.attachment!.fileName);
              print(ab.path);
              setState(() {
                _isDownloading = false;
              });

              OpenFile.open(ab.path);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if(_isDownloading)const  Padding(
                  padding:  EdgeInsets.all(8.0),
                  child:  LoadingIndicator(
                    height: 10,
                    width: 10,
                  ),
                ),

                const Text("Download")
              ],
            ),
          )
        ],
      ),
    );
  }


  static var httpClient = HttpClient();

  int byteCount = 0;

  Future<File> _downloadFile(String url, String filename) async {
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = Platform.isIOS
        ? (await getApplicationSupportDirectory()).path
        : (await getExternalStorageDirectory())!.path;
    File file = new File('$dir/$filename');
    print('$dir/$filename');
    await file.writeAsBytes(bytes);
    print("File Done");
    return file;
  }

}

