"message_image" → ImageBubbleFactory                              │    │
│  │  - "custom_extension_poll" → PollBubbleFactory                       │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
```
                │    │
│  │  2. factory = bubbleFactories[factoryKey]                            │    │
│  │  3. contentWidget = factory.build(context, message, alignment)       │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Internal bubbleFactories: Map<String, BubbleFactory>                │    │
│  │  - "message_text" → TextBubbleFactory                                │    │
│  │  - et?                                           │    │
│  │  - threadView: Widget?                                               │    │
│  │  - footerView: Widget?                                               │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  Smart Content Resolution (when message is provided):                │    │
│  │  1. factoryKey = BubbleFactory.getFactoryKey(message)
│  │  Accepts Widgets DIRECTLY (not callbacks):                           │    │
│  │  - leadingView: Widget?                                              │    │
│  │  - headerView: Widget?                                               │    │
│  │  - replyView: Widget?                                                │    │
│  │  - contentView: Widget? ← OR auto-set via message + factories        │    │
│  │  - bottomView: Widget?                                               │    │
│  │  - statusInfoView: Widgessage, alignment)              │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                      CometChatMessageBubble                                  │
│  ┌─────────────────────────────────────────────────────────────────────┐    │ provider with message                                │    │
│  │    2. Pass Widgets directly to CometChatMessageBubble                │    │
│  │    3. Call messageBubble.setMessage(mt) → Widget?
│  │  - statusInfoViewProvider: ...                                       │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                    │                                         │
│                                    ▼                                         │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  For each message in ListView.builder:                               │    │
│  │    1. Call eachssageBubble

## Architecture Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         CometChatMessageList                                 │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  BubbleViewProvider Callbacks (set by developer)                     │    │
│  │  - headerViewProvider: (BuildContext, BaseMessage, BubbleAlignment) → Widget?
│  │  - leadingViewProvider: (BuildContext, BaseMessage, BubbleAlignmenle architecture to Flutter, making `CometChatMessageBubble` a smart component that automatically creates appropriate content views based on message category and type using a `BubbleFactory` registry.

## Key Architecture Clarification

- **CometChatMessageBubble** accepts Widgets directly for slots (NOT callbacks)
- **CometChatMessageList** accepts `BubbleViewProvider` callbacks that receive message and return Widgets
- Flow: MessageList has providers → calls providers with message → passes returned Widget to Me# Smart CometChatMessageBubble Architecture - Flutter Design

## Overview

This document adapts the Android Smart CometChatMessageBubb