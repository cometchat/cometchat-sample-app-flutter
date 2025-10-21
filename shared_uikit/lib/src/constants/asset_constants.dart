import 'package:flutter/material.dart';

///[AssetConstants] is a utility class that stores String constants of asset image paths
class AssetConstants {

  ///[_mode] stores the default asset directory according to the brightness mode of the device
  String _mode = "light";
  AssetConstants(Brightness brightness) {
    _mode = brightness == Brightness.light ? "light" : "dark";
  }

  static const spinner = "assets/icons/spinner.png";
  static const close = "assets/icons/close.png";
  static const write = "assets/icons/write.png";
  static const checkmark = "assets/icons/checkmark.png";
  static const delete = "assets/icons/delete.png";
  static const deleteIcon = "assets/icons/delete_icon.png";
  static const messageReceived = "assets/icons/message_received.png";
  static const messageSent = "assets/icons/message_sent.png";
  static const info = "assets/icons/info.png";
  static const imagePlaceholder = "assets/icons/image_placeholder.png";
  static const messagesUnsafe = "assets/icons/messages_unsafe.png";
  static const download = "assets/icons/download.png";
  static const pause = "assets/icons/pause.png";
  static const play = "assets/icons/play.png";
  static const back = "assets/icons/back.png";
  static const add = "assets/icons/add_circle_no_fill.png";
  static const send = "assets/icons/send_fill.png";
  static const heart = "assets/icons/heart.png";
  static const smileys = "assets/icons/smileys.png";
  static const photoLibrary = "assets/icons/photo_library.png";
  static const attachmentFile = "assets/icons/attachment_file.png";
  static const audio = "assets/icons/audio.png";
  static const stop = "assets/icons/stop.png";
  static const edit = "assets/icons/edit.png";
  static const reply = "assets/icons/reply.png";
  static const thread = "assets/icons/thread.png";
  static const share = "assets/icons/share.png";
  static const copy = "assets/icons/copy.png";
  static const forward = "assets/icons/forward.png";
  static const keyboard = "assets/icons/keyboard.png";
  static const smile = "assets/icons/sticker_no_fill.png";
  static const warning = "assets/icons/warning.png";
  static const translate = "assets/icons/translate.png";
  static const polls = "assets/icons/polls.png";
  static const collaborativeWhiteboard =
      "assets/icons/collaborative_whiteboard.png";
  static const collaborativeDocument =
      "assets/icons/collaborative_document.png";
  static const reactionsAdd = "assets/icons/reactions_add.png";
  static const videoCall = "assets/icons/2x/video-call.png";
  static const audioCall = "assets/icons/2x/audio-call.png";
  static const call = "assets/icons/2x/call.png";
  static const compose = "assets/icons/compose.png";
  static const replyPrivately = "assets/icons/2x/reply_message_privately.png";
  static const microphone = "assets/icons/mic_no_fill.png";
  static const stopPlayer = "assets/icons/stop-player.png";
  static const ai = "assets/icons/ai_no_fill.png";
  static const repliesError = "assets/icons/replies_error.png";
  static const repliesEmpty = "assets/icons/replies_empty.png";
  static const incomingCall = "assets/icons/incoming_call.png";
  static const outgoingCall = "assets/icons/outgoing_call.png";
  static const missedCall = "assets/icons/missed_call.png";
  static const message = "assets/icons/message.png";
  static const sideArrow = "assets/icons/side_arrow.png";
  static const audioIncoming = "assets/icons/audio_incoming.png";
  static const audioOutgoing = "assets/icons/audio_outgoing.png";
  static const audioMissed = "assets/icons/phone_missed.png";
  static const videoIncoming = "assets/icons/video_incoming.png";
  static const videoOutgoing = "assets/icons/video_outgoing.png";
  static const videoMissed = "assets/icons/missed_video_call.png";
  static const slotsUnavailable = "assets/icons/2x/slots-unavailable.png";
  static const addReaction = "assets/icons/add_reaction.png";
  static const threadIndicator = "assets/icons/thread_indicator.png";
  static const waitIcon = "assets/icons/hourglass_bottom_half_filled.png";
  static const refreshIcon = "assets/icons/refresh.png";
  static const fileAudio = "assets/icons/file_audio.png";
  static const fileSpreadsheet = "assets/icons/file_csv.png";
  static const fileDoc = "assets/icons/file_doc.png";
  static const fileImage = "assets/icons/file_image.png";
  static const filePdf = "assets/icons/file_pdf.png";
  static const filePresentation = "assets/icons/file_ppt.png";
  static const fileText = "assets/icons/file_txt.png";
  static const fileUnknown = "assets/icons/file_unknown.png";
  static const fileVideo = "assets/icons/file_video.png";
  static const fileZip = "assets/icons/file_zip.png";
  static const videocamNoFill = "assets/icons/videocam_no_fill.png";
  static const callNoFill = "assets/icons/call_no_fill.png";
  static const stickerFilled = "assets/icons/sticker_filled.png";
  static const collaborativeDocumentFilled = "assets/icons/collaborative_document_filled.png";
  static const collaborativeWhiteBoardFilled = "assets/icons/collaborative_whiteboard_filled.png";
  static const shareOutlined = "assets/icons/share_outline.png";
  static const mediaLoading = "assets/icons/media_loading.png";
  static const videoPlaceholder = "assets/icons/video_placeholder.png";
  static const conversationError = "assets/icons/conversation_error.png";
  static const conversationEmpty= "assets/icons/conversation_empty.png";
  static const darkModeConversationEmpty= "assets/dark_mode_icons/conversation_empty.png";
  static const voiceIncoming = "assets/icons/voice_incoming.png";
  static const voiceOutgoing = "assets/icons/voice_outgoing.png";
  static const darkModeConversationError = "assets/icons/conversation_error_dark.png";
  static const whiteBoard = "assets/icons/collaborative.png";
  static const collaborativeWhiteboardPreview = "assets/icons/collaborative_whiteboard_preview.png";
  static const collaborativeDocumentPreview = "assets/icons/collaborative_document_preview.png";
  static const delete48px = "assets/icons/delete_48px.png";
  static const mic96px = "assets/icons/mic_96px.png";
  static const stop48px = "assets/icons/stop_48px.png";
  static const mediaRecorderSendIcon = "assets/icons/media_recorder_send_icon.png";
  static const pause72px = "assets/icons/pause_72px.png";
  static const drag = "assets/icons/drag.png";
  static const changeScope96px= "assets/icons/change_scope_96px.png";
  static const cancel = "assets/icons/cancel.png";
  static const block = "assets/icons/block.png";
  static const incomingAudioCallNoFill = "assets/icons/incoming_audio_no_fill.png";
  static const outgoingAudioCallNoFill = "assets/icons/outgoing_audio_no_fill.png";
  static const incomingVideoCallNoFill = "assets/icons/incoming_video_no_fill.png";
  static const outgoingVideoCallNoFill = "assets/icons/outgoing_video_no_fill.png";
  static const aiConversationSummary = "assets/icons/ai_conversation_summary.png";
  static const aiSuggestReply = "assets/icons/ai_suggest_reply.png";
  static const aiActive = "assets/icons/ai_active.png";
  static const aiInactive = "assets/icons/ai_inactive.png";
  static const aiProfile = "assets/icons/ai_profile.png";
}

///[CometChatAssetConstants] is an extension that provides asset image paths according to the brightness mode of the device
extension CometChatAssetConstants on AssetConstants {
  String get noMessagesFound => "assets/icons/$_mode/no_messages.png";
  String get messagesError => "assets/icons/$_mode/messages_error.png";
  String get conversationEmpty => "assets/icons/$_mode/conversation_empty.png";
  String get emptyGroupList => "assets/icons/$_mode/empty_group_list.png";
  String get emptyUserList => "assets/icons/$_mode/user_empty.png";
}

///[SvgAssetConstants] is a utility class that stores String constants of asset image paths
class SvgAssetConstants {

  ///[_mode] stores the default asset directory according to the brightness mode of the device
  String _mode = "light";
  SvgAssetConstants(Brightness brightness) {
    _mode = brightness == Brightness.light ? "light" : "dark";
  }

  static const videoCall = "assets/icons/svg/calls/video_call.svg";

}
