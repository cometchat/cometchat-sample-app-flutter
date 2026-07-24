# cometchat_chat_uikit example

A minimal app that initializes the UI Kit, logs a user in, and renders a
conversation list that opens into a full chat screen.

## Run it

Get your **App ID**, **Region** and **Auth Key** from the
[CometChat dashboard](https://app.cometchat.com), then:

```bash
flutter run \
  --dart-define=APP_ID=your_app_id \
  --dart-define=REGION=your_region \
  --dart-define=AUTH_KEY=your_auth_key
```

Every CometChat app is created with a `cometchat-uid-1` test user, which this
example logs in as by default. Point it at another user with
`--dart-define=UID=some_other_uid`.

## What it shows

| Step | Where |
|---|---|
| Initialize the UI Kit | `CometChatUIKit.init` in `main()` |
| Log a user in | `CometChatUIKit.login` in `LoginGate` |
| List conversations | `CometChatConversations` in `ConversationsScreen` |
| A full chat screen | `CometChatMessageHeader` + `CometChatMessageList` + `CometChatMessageComposer` in `MessagesScreen` |

`MaterialApp.localizationsDelegates` must include
`Translations.localizationsDelegates` — the UI Kit's widgets read their strings
from it.

## A note on auth

`CometChatUIKit.login` takes the auth key and is meant for prototyping. In
production, keep the auth key on your server, mint an auth token there, and
call `CometChatUIKit.loginWithAuthToken` instead.
