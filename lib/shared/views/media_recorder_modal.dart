import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:cometchat_flutter_sample_app/utils/widget_card.dart';
import 'package:flutter/material.dart';

WidgetProps getMediaRecorderModal(BuildContext context) {
  return WidgetProps(
    leadingImageURL: "assets/icons/mic.png",
    title: "Media Recorder",
    description:
        "CometChatMediaRecorder is a class that allows users to record and send audio messages. It has a start button to start recording, a stop button to stop recording, a play button to play the recorded message, a pause button to pause the recorded message, a submit button to submit the recorded message and a close button to close the media recorder.",
    onTap: () {
      CometChatMediaRecorder _cometChatMediaRecorder = CometChatMediaRecorder(
        onSubmit: (context, String path) {
          Navigator.pop(context);
        },
        onClose: () {
          Navigator.pop(context);
        },
      );

// open the CometChatMediaRecorder widget in a modal sheet
      showModalBottomSheet<void>(
          isDismissible: true,
          context: context,
          backgroundColor: Colors.transparent,
          builder: (BuildContext context) {
            return _cometChatMediaRecorder;
          });
    },
  );
}
