# Multiple Attachment Support — Flutter UIKit Feature Reference

> Consolidated from Linear project resources:
> [Project](https://linear.app/cometchat/project/multiple-attachment-support-better-attached-preview-before-uploading-61b4c58f72fc/overview)

---

## Overview

Enable users to attach, preview, and send multiple files (images, videos, audio, documents) in a single message. Includes caption support, grouped message rendering, drag & drop (web), copy-paste (all platforms), and per-file upload progress via presigned S3 uploads.

**Status:** Frontend In Progress
**Lead:** Jitvar Patil
**Priority:** High
**Team:** Engineering

---

## Linked Resources

| Resource | URL |
|----------|-----|
| FN — Multiple Attachment Share Support | https://linear.app/cometchat/document/fn-multiple-attachment-share-support-718112a28e23 |
| FrontEnd Requirements Document | https://linear.app/cometchat/document/frontend-requirements-document-863b085fcb9b |
| Front END Design Document | https://linear.app/cometchat/document/front-end-design-document-multiple-attachment-support-9a93aca27ce2 |
| API Design Document | https://linear.app/cometchat/document/api-design-document-a4d8b7a2c038 |
| Design Doc (Figma links) | https://linear.app/cometchat/document/design-doc-af69e6274996 |
| Bubble Prototype | https://claude.ai/public/artifacts/d6874c25-9bc3-4610-a1e0-c4ce6aa6deb7 |

### Figma Designs

| Platform | Link |
|----------|------|
| Web Desktop | https://www.figma.com/design/zIrO2980WJQtvm3lU7Ep7H/Web-Chat--UI-Kits?node-id=2260-222465 |
| Web Mobile | https://www.figma.com/design/zIrO2980WJQtvm3lU7Ep7H/Web-Chat--UI-Kits?node-id=2689-447194 |
| Android | https://www.figma.com/design/SPRWwnReOmwu6suACMrsRv/Android-Chat--UI-Kits?node-id=5082-128416 |
| iOS | https://www.figma.com/design/0OYM7O5nbapkRtJ0TsemIe/iOS-Chat--UI-Kits?node-id=5082-440421 |
| Prototype | https://www.figma.com/proto/zIrO2980WJQtvm3lU7Ep7H/Web-Chat--UI-Kits?node-id=12593-2058902 |

### Featurebase Posts

- https://cometchat.featurebase.app/p/support-clipboard-paste-and-drag-and-drop-image-upload-in
- https://cometchat.featurebase.app/p/need-progress-indicator-on-the-receiver-end-that-the-video
- https://cometchat.featurebase.app/p/need-progress-indicates-the-status-of-the-video-being-uploaded
- https://cometchat.featurebase.app/p/file-upload-persistence-when-navigating-away-from-chat-screen

---

## Requirements Summary

### Req 1: Multiple File Selection
- Attachment picker allows multi-select for images, videos, documents, audio
- Camera capture appends to existing selection (doesn't replace)
- Selection count indicator shown
- SDK validates count limit when `uploadFiles` is called

### Req 2: Attachment Preview Before Sending
- Horizontal scrollable strip above composer (48×48 cells, 12px gap)
- Thumbnails for images/videos, file icons for documents/audio
- Per-item remove button, total size display
- Item states: Default, Selected, Hover, Loading %, Failed, Disallowed
- Detail bar below strip shows file info when item tapped

### Req 3: Sending Multiple Attachments
- Single `MediaMessage` with all attachments
- Upload starts immediately on selection via `CometChat.uploadFiles()` (presigned S3)
- Send button disabled during upload, enabled when all complete
- User can type caption while uploads happen
- Per-file progress via `MediaCallbackListener.onProgress`
- Per-file retry on failure

### Req 4: Displaying in Message List
- Visual media (image/\*, video/\*) → `MediaGridBubble` (grid layout)
  - 1 → full-width (160px), 2 → side-by-side (114px), 3 → 1+2, 4 → 2×2, 5+ → 2×2 with "+N"
  - Fixed bubble width: 240px, grid gap: 2px, outer radius: 12px, 4px inner padding
- Files (audio/\*, application/\*, text/\*, etc.) → `FileListBubble` (vertical card stack)
  - 4+ files: first 3 visible + "+N more" expandable
  - Connected card radius: first 10px top, middle 4px, last 10px bottom
- Rendering order: media grid on top, file list below
- Both sub-bubbles in same message container

### Req 5: Mixed Media Type Support
- Any combination of file types in single selection
- Two-category grouping: visual media vs files
- Videos show play button overlay + duration badge

### Req 6: Configuration & Limits
- `maxAttachmentCount`: default 10
- `maxIndividualFileSize`: platform default
- `maxTotalFileSize`: platform default
- `allowMultipleSelection`: default true
- `allowedMimeTypes`: default all media types
- SDK validates, UIKit displays errors

### Req 7: Backward Compatibility
- `getAttachment()` returns first attachment (unchanged)
- `getAttachments()` returns full list
- `setAttachment()` replaces all with single
- Single-attachment messages use existing bubble
- `sendMediaMessage` with local files still uploads internally (legacy path)

### Req 8: Real-time Updates
- `onMediaMessageReceived` delivers all attachments
- `onMessageEdited` updates attachment info
- Thumbnails auto-update via `onMessageEdited` listener

### Req 9: Error Handling
- Individual file too large → SDK error → UIKit displays
- Total size exceeded → SDK error → UIKit displays
- Unsupported MIME type → SDK error → UIKit displays
- Network loss → pause uploads, show connectivity error
- Per-file retry on failure
- Attachment load failure in bubble → placeholder + retry

### Req 10: Accessibility
- Accessible labels for each attachment (name + type)
- Grid/list announces total count
- Screen reader announces position (i of N)
- Remove button label identifies which attachment

### Req 11: Drag-and-Drop (Web) & Clipboard Paste (All)
- Drop zone overlay on drag-enter (web only)
- Paste detects media content, adds to selection
- Text-only paste handled normally
- Partial addition when exceeding limit (add up to limit, error on rest)

### Req 12: Message Interactions
- Edit: caption-only (no attachment changes); hidden if no caption
- Reply/quote: first attachment thumbnail + "📎 N attachments"
- Action menu: entire bubble group, not per sub-bubble
- Copy: caption text only; hidden if no caption
- Share: hidden for multi-attachment (available in full-screen viewer)
- Message type: `file` for multi-attachment, specific type for single
- Attachment order preserved end-to-end

### Req 14: Conversation List Preview
- Multi-attachment last message → "📎 N attachments"
- Single-attachment file → existing "📄 File" preview

### Req 15: VCB Sharing Restrictions
- Check each file MIME type against VCB flags after selection
- Disallowed files show error state in preview, not uploaded
- Send disabled while any file is disallowed

---

## Architecture

### Upload Flow (Presigned S3)

```
1. User selects files → UIKit calls CometChat.uploadFiles() immediately
2. SDK requests presigned URLs: POST /v3.0/files/upload-url
3. SDK uploads each file directly to S3, reports per-file progress
4. All uploads complete → UIKit enables Send button
5. User taps Send → sendMediaMessage() with pre-uploaded Attachment objects + caption
```

- UIKit manages concurrency: max 3 concurrent `uploadFiles()` calls, queues rest
- SDK handles presigned URL expiry (30s buffer, re-requests if near expiry)
- `MediaUploadHandle.cancel()` aborts in-flight uploads

### API Endpoint

`POST /v3.0/files/upload-url`

Request:
```json
{
  "receiver": "cometchat-uid-1",
  "receiverType": "user",
  "files": {
    "fileId1": { "fileId": "fileId1", "name": "test.jpg", "size": 93842, "mimeType": "image/jpeg" }
  }
}
```

Response per file:
```json
{
  "request": { "url": "https://s3...", "method": "POST", "body": { "key": "...", ... } },
  "attachment": { "url": "https://data.cometchat.com/...", "name": "test.jpg", "size": 93842, "mimeType": "image/jpeg", "extension": ".jpg" },
  "expiresAt": 1738800000
}
```

### Receiving Flow

```
1. WebSocket: new MediaMessage received
2. Check message.getAttachments().size()
3. Single → existing single bubble
4. Multiple → group into visual media + files → render MediaGridBubble + FileListBubble
```

### Category Grouping Algorithm

```dart
bool isVisualMedia(String mimeType) =>
    mimeType.startsWith('image/') || mimeType.startsWith('video/');

AttachmentGroups groupAttachments(List<Attachment> attachments) {
  final media = <Attachment>[];
  final files = <Attachment>[];
  for (final a in attachments) {
    if (isVisualMedia(a.mimeType)) media.add(a);
    else files.add(a);
  }
  return AttachmentGroups(media: media, files: files);
}
```

---

## Data Models (Flutter)

### UploadState
```dart
enum UploadState { none, uploading, completed, failed, disallowed }
```

### SelectedAttachment (UIKit-only, not persisted)
```dart
class SelectedAttachment {
  final String id;              // Unique ID (used as fileId in API)
  final dynamic localFile;      // Platform file reference
  final String fileName;
  final int fileSize;
  final String mimeType;
  final String? thumbnailUri;   // Local thumbnail (images/videos)
  UploadState uploadState;      // none → uploading → completed/failed
  double uploadProgress;        // 0.0 → 1.0
  Attachment? remoteAttachment; // Populated from upload response
  String? errorMessage;
}
```

### AttachmentPickerConfiguration
```dart
class AttachmentPickerConfiguration {
  final int maxAttachmentCount;           // Default: 10
  final int maxIndividualFileSize;        // Platform default
  final int maxTotalFileSize;             // Platform default
  final bool allowMultipleSelection;      // Default: true
  final List<String> allowedMimeTypes;    // Default: all media
}
```

### AttachmentGroups
```dart
class AttachmentGroups {
  final List<Attachment> media;  // image/* + video/*
  final List<Attachment> files;  // everything else
}
```

---

## New UI Components

### AttachmentPreview
- Horizontal scrollable strip, 48×48 cells, 8px radius, 12px gap
- Image/video: thumbnail fill; File/audio: 32×32 centered icon
- States: Default (1px #E8E8E8), Selected (2px primary), Hover (dark overlay + cancel), Loading (overlay + spinner + %), Failed (overlay + retry), Disallowed (overlay + error)
- Detail bar below: "filename • size • extension" + close icon

### MediaGridBubble
- Fixed 240px width
- Grid layouts: 1→full, 2→side-by-side, 3→1+2, 4→2×2, 5+→2×2+"+N"
- 2px gap, 12px outer radius, 4px inner padding
- Videos: play button overlay + duration badge
- Caption below 1px divider if present
- Timestamp: overlay on media if no caption/files, footer otherwise

### FileListBubble
- 32×32 file-type icon + name + meta ("2.4 MB • PDF")
- Connected card radius (first 10px top, middle 4px, last 10px bottom)
- 4+ files: first 3 + "+N more" expandable

### FullScreenAttachmentViewer
- Swipe navigation across all attachments
- Image zoom/pan, video playback, audio controls, document download

---

## Style Classes

### MediaGridBubbleStyle
```dart
bubbleWidth: 240, gridGap: 2, outerCornerRadius: 12, innerPadding: 4,
overlayBackgroundColor, overlayTextColor, overlayTextFont,
maxVisibleAttachments: 4, playButtonIcon, durationBadgeFont,
captionDividerColor, sentBackgroundColor: #6C5CE7, receivedBackgroundColor: #EEEEEE
```

### FileListBubbleStyle
```dart
fileIconSize: 32, cardCornerRadiusOuter: 10, cardCornerRadiusInner: 4,
fileNameFont, fileNameColor, metaFont, metaColor,
expandButtonFont, expandButtonColor, maxVisibleFiles: 3,
sentBackgroundColor: #6C5CE7, receivedBackgroundColor: #EEEEEE
```

### AttachmentPreviewStyle
```dart
itemSize: 48, itemCornerRadius: 8, itemSpacing: 12, containerPadding: 12,
defaultBorderColor: #E8E8E8, defaultBorderWidth: 1,
selectedBorderColor: #6852D6, selectedBorderWidth: 2,
fileIconSize: 32, cancelIconBackgroundColor: #434343,
loadingOverlayColor: rgba(0,0,0,0.5), progressTextColor: white,
detailBarTextColor: #727272
```

---

## Flutter-Specific Implementation Notes

### SDK Method (Dart)
```dart
MediaUploadHandle CometChat.uploadFiles(
  List<FileMetadata> files, {
  Function(List<Attachment>)? onSuccess,
  Function(CometChatException)? onError,
  Function(String fileName, int bytesUploaded, int totalBytes)? onProgress,
});
```

### Upload Concurrency (UIKit manages)
```
Time 0: uploadFiles([F1]), uploadFiles([F2]), uploadFiles([F3])
        Queue: F4, F5, F6, ...
Time 1: F1 done → uploadFiles([F4])
...until all complete
```

### Cancel via `MediaUploadHandle`
```dart
handle.cancel(); // Cancels dio CancelToken, triggers onError(ERR_UPLOAD_CANCELLED)
```

### HTTP Progress (dio)
```dart
dio.post(url, onSendProgress: (sent, total) => onProgress(fileName, sent, total));
```

---

## Bubble Factory Integration

Register in `DefaultBubbleFactories.getDefaults()`:
```dart
// When message.getAttachments().size() > 1 and type == 'file'
_key(MessageCategoryConstants.message, 'multi_attachment'): MultiAttachmentBubbleFactory(),
```

Or handle in MessageList: check `message.getAttachments().size() > 1` before factory lookup, render MediaGridBubble + FileListBubble directly.

---

## Folder Structure (Clean Architecture + BLoC)

```
chat_uikit/lib/chat_ui/src/multi_attachment/
├── bloc/
│   ├── multi_attachment_bloc.dart
│   ├── multi_attachment_event.dart
│   ├── multi_attachment_state.dart
│   └── bloc.dart
├── data/
│   ├── datasources/
│   │   └── upload_remote_datasource.dart
│   ├── repositories/
│   │   └── upload_repository_impl.dart
│   └── data.dart
├── domain/
│   ├── repositories/
│   │   └── upload_repository.dart
│   ├── usecases/
│   │   ├── upload_files_usecase.dart
│   │   └── cancel_upload_usecase.dart
│   └── domain.dart
├── di/
│   ├── multi_attachment_service_locator.dart
│   └── di.dart
├── models/
│   ├── selected_attachment.dart
│   ├── upload_state.dart
│   ├── attachment_groups.dart
│   └── attachment_picker_configuration.dart
├── utils/
│   ├── attachment_grouping_utils.dart
│   └── mime_type_utils.dart
├── widgets/
│   ├── attachment_preview/
│   │   ├── attachment_preview.dart
│   │   ├── attachment_preview_item.dart
│   │   ├── attachment_detail_bar.dart
│   │   └── attachment_preview_style.dart
│   ├── media_grid_bubble/
│   │   ├── media_grid_bubble.dart
│   │   ├── media_grid_bubble_style.dart
│   │   └── media_grid_cell.dart
│   ├── file_list_bubble/
│   │   ├── file_list_bubble.dart
│   │   ├── file_list_bubble_style.dart
│   │   └── file_card.dart
│   ├── full_screen_viewer/
│   │   └── full_screen_attachment_viewer.dart
│   ├── drop_zone_overlay.dart          # Web only
│   ├── clipboard_paste_handler.dart    # All platforms
│   └── widgets.dart
└── multi_attachment.dart               # Barrel export
```

---

## Design Decisions

1. Upload decoupled from send — files upload immediately on selection
2. Grid layout with "+N" overflow (WhatsApp/Telegram pattern)
3. SDK validates, UIKit displays errors (no duplicate validation)
4. Backward compatible — `getAttachment()` still returns first
5. Direct-to-S3 presigned uploads (bypass API server)
6. `MediaCallbackListener` on `uploadFiles`, not `sendMediaMessage`
7. Edit is caption-only; no attachment modification
8. Reply/quote shows first attachment + count
9. No link preview in multi-attachment captions
10. No offline upload support
11. Server-generated thumbnails in bubbles
12. Per-file retry on failure
13. Message type is `file` for multi-attachment
14. Attachment order preserved end-to-end
15. No image/video compression
16. Copy/Share restricted for multi-attachment messages

---

## Error Codes

| Code | HTTP | Description |
|------|------|-------------|
| ERR_BAD_REQUEST | 400 | File validation failed (size, count, format) |
| ERR_TOTAL_SIZE_EXCEEDED | 400 | Sum of file sizes exceeds limit |
| ERR_PERMISSION_DENIED | 403 | RBAC MIME type not allowed |
| ERR_S3_UNAVAILABLE | 503 | Storage service temporarily down |
| ERR_OPERATION_FAILED | 500 | Internal server error |
| ERR_UPLOAD_CANCELLED | — | User cancelled upload |
| ERR_FILE_TOO_LARGE | — | SDK client-side: individual file too large |
| ERR_ATTACHMENT_LIMIT_EXCEEDED | — | SDK client-side: too many files |
| ERR_UNSUPPORTED_FILE_TYPE | — | SDK client-side: MIME type not allowed |

S3 errors (XML): AccessDenied, EntityTooLarge, EntityTooSmall, ExpiredToken, ServiceUnavailable, SlowDown

---

## Out of Scope (v1)

- Message forwarding
- AI / Smart replies for multi-attachment
- Offline upload queuing
- Shared Media panel multi-attachment handling
- Push notification text format (pending PM)
- RBAC enforcement in UIKit (backend only)
