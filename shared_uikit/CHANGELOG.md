## 5.0.4

## Enhancements
- Optimized mentions functionality to improve tagging accuracy and performance during message composition.

## Fixes
- Fixed an issue where CometChatSDK.framework was missing a dSYM file during iOS build uploads, causing upload failures.
- Fixed the behavior where deleting a mention would remove it character by character instead of as a complete tag.
- Resolved an issue where the app was rejected due to the use of deprecated media permissions. The permissions have been updated to comply with current platform requirements.

## 5.0.3

## New
- Introduced the `DateTimeFormatterCallback`, enabling developers to customize the display format for date and time elements within the CometChat UI Kit. This feature supports tailoring formats like "today," "yesterday," and specific time expressions to match the application's locale or specific design requirements.
- Added localization support for additional languages and regions:
  - English (United Kingdom) – `en_GB`
  - Japanese – `ja`
  - Korean – `ko`
  - Dutch – `nl`
  - Turkish – `tr`
- Enabled the ability to override existing localizations and add support for new languages, giving developers more control over language customization in the UI.

## Enhancements
- Updated `cometchat_sdk` to version `4.0.23`.
- Enabled default image zoom functionality when tapping a ImageBubbleView in Flutter, enhancing media interaction.

## Fixes
- Resolved a bug causing the voice recording animation to become scrollable after tapping the stop button.
- Fixed an issue where the ringtone continued ringing even after the call had ended following a single ring.
- Addressed a UI bug where the previously selected emoji category would flash instead of remaining on the final selected category.

## 5.0.2

## Fixes
- Fixed an issue where audio playback for voice messages was routed through the earpiece instead of the speaker after an audio call, improving user experience during message playback.
- Resolved a bug where the `titleTextStyle` and `subtitleTextStyle` properties of `CometChatFileBubbleStyle` were not applying as expected, ensuring consistent styling.

## 5.0.1

## New
- Introduced the `filledColor` property in `CometChatMessageInputStyle` to allow customization of the text input field's background color.

## Enhancements
- Updated `cometchat_sdk` to version `4.0.22`.

## Fixes
- Fixed an issue where users had to click twice to play a video after navigating from a video thumbnail.
- Corrected group avatar display to properly show group name or emoji instead of a question mark.
- Corrected inconsistent timestamp formats by standardizing to 24-hour format.
- Fixed flickering of the voice recording UI for a few seconds after recording ended.
- Corrected timestamp section display issues in dark mode.
- Resolved an issue where voice recording UI displayed incorrectly when selecting a non-audio attachment.
- Resolved an inconsistency where mentioning a single user in the composer did not behave as expected compared to multiple mentions.
- Fixed an issue where partially deleting a mention by clicking between characters and using the remove button left behind a fragment instead of removing the entire mention.
- Corrected the backspace behavior to ensure mentions are removed as a complete block instead of character by character.
- Fixed a bug where mentioning five or more users in a group caused the send button to become unresponsive, preventing the message from being sent.

## 5.0.0

## Enhancements
- Updated properties for all components to improve flexibility, customization, and overall usability.
- Enhanced the **Call Logs Component** with refined properties for better filtering and call log management.
- Improved the **Incoming Call Component** by introducing configurable properties for handling call notifications.
- Optimized the **Call Buttons Component**, allowing better control over button actions and styles.
- Upgraded the **Outgoing Call Component** with new properties to support call customization.
- Enhanced the **User Component** by refining properties for better profile representation and interaction.
- Improved the **Groups Component** with additional properties for group visibility and management.
- Updated the **Group Members Component**, allowing for better user role management within groups.
- Refined the **Thread Header Component** with improved customization options.
- Enhanced the **Message Header Component**, offering better control over display settings.
- Improved the **Message List Component** by adding new properties for message styling and rendering.
- Updated the **Message Composer Component** with enhanced properties for message input control.

## Fixes
- **Resolved Flutter UI Kit Build Failure**: Fixed an issue causing build failures when using Flutter version 3.29.0.
- **Last Message Not Updating for Group Action Messages**: Addressed a problem where the last message did not update if it was a group action message.
- **Deleting Mentioned Names in Messages**: Fixed an issue where deleting a mentioned name in a message resulted in character-by-character deletion instead of removing the full mention.

## 5.0.0-beta.2

## Fixes
- **Resolved Flutter UI Kit Build Failure**: Fixed an issue causing build failures when using Flutter version 3.29.0.
- **Last Message Not Updating for Group Action Messages**: Addressed a problem where the last message did not update if it was a group action message.
- **Deleting Mentioned Names in Messages**: Fixed an issue where deleting a mentioned name in a message resulted in character-by-character deletion instead of removing the full mention.

## 5.0.0-beta.1

## New
- **Revamped UI**: Experience a fresh, modern design for improved visual appeal and consistency. The updated look enhances usability and engagement.
- **Restructured Components**: Enjoy a redesigned component architecture that improves scalability, making it easier to build and maintain modular designs.

## Enhancements
- **Optimized User Experience**: Interactions have been streamlined to provide a smoother, more intuitive experience, reducing friction during use.
- **Advanced Styling and Theming**: Gain greater flexibility with enhanced customization options, allowing you to tailor appearances to suit your brand effortlessly.
- **Simplified Integration**: Set up faster and with ease thanks to a more intuitive, streamlined integration process.

## Fixes
- None

## Removals
- **Style Props Removed**: Style-specific props have been deprecated to encourage the use of modern theming practices, which offer more robust and scalable customization options.

## 5.0.0-alpha.1

## New
- **Revamped UI**: Experience a fresh, modern design for improved visual appeal and consistency. The updated look enhances usability and engagement.
- **Restructured Components**: Enjoy a redesigned component architecture that improves scalability, making it easier to build and maintain modular designs.

## Enhancements
- **Optimized User Experience**: Interactions have been streamlined to provide a smoother, more intuitive experience, reducing friction during use.
- **Advanced Styling and Theming**: Gain greater flexibility with enhanced customization options, allowing you to tailor appearances to suit your brand effortlessly.
- **Simplified Integration**: Set up faster and with ease thanks to a more intuitive, streamlined integration process.

## Fixes
- None

## Removals
- **Style Props Removed**: Style-specific props have been deprecated to encourage the use of modern theming practices, which offer more robust and scalable customization options.

## 4.4.9

**New**
- Added event listeners `onMessagesDeliveredToAll` and `onMessagesReadByAll` to notify sender of a message when their group messages are delivered or read by every other member in the group.

**Enhancements**
- Updated `cometchat_sdk` to version `4.0.17`.

**Fixes**
- Fixed an issue where the actual height of `CometChatAvatar` was being restricted by `CometChatListItem`.


## 4.4.8

**Fixes**
- Fixed an issue where the `sendCustomInteractiveMessage()` function was missing.
- Fixed an issue where the `listItemStyle` was not working in `CometChatReactionList`.


## 4.4.7:

**Removals**
- Removed unnecessary location permission.


## 4.4.6

**Enhancements**
- Updated `cometchat_sdk` to version `4.0.16`.

**Fixes**
- Resolved an issue where component colors weren't applied to the safe area, ensuring seamless visual consistency.
- Fixed an issue where height was not being applied to `SectionSeparator` shown in `CometChatUsersWithMessages`.

## 4.4.5

**Fixes**
- Resolved an issue where overriding the `inputTextStyle` in the `messageComposerStyle` prop was not functioning correctly.
- Resolved an issue where `border` and `border-radius` style were not being applied to the `CometChatListBase` component.

## 4.4.4

**Enhancements**
- Introduced an enum `MentionsVisibility` in `CometChatMentionsFormatter` to control the visibility of the list of users who can be mentioned.
- Updated `cometchat_sdk` to version `4.0.14`.

**Fixes**
- Fixed an issue where `separatorColor` was not overriding in `CometChatListItem`.

## 4.4.3

**Enhancements**
- Updated `cometchat_sdk` to version `4.0.13`

**Fixes**
- Fixed a problem where auto logging the user into the app did not reload the call extensions and default extensions. This fix ensures that all necessary extensions are loaded correctly upon login, enhancing the app's reliability and user experience.

## 4.4.2

**New**
- Introduced real-time updates for the last message and unread count in conversations based on App setting configured via dashboard, ensuring up-to-date information is displayed.

**Enhancements**
- Updated `cometchat_sdk` to version `4.0.12`

## 4.4.1

**Fixes**
- Rectified a critical issue that was causing the scheduler bubble to crash, enhancing stability.

## 4.4.0
**Enhancements**
- Updated all 3rd-party plugins versions.
- Resolved all static Dart Analyser suggestions
- Added namespaces in build.gradle to avoid conflicts.

**Fixes**
- Fixed a critical issue that was causing the app to crash within the scheduler message bubble.

## 4.3.0
**New**
- Text Formatters:
    - Introduced `CometChatMentionsFormatter` to format a text if it contains a mention of a user.
    - Introduced `CometChatUrlFormatter` to format a text if it contains a URL.
    - Introduced `CometChatEmailFormatter` to format a text if it contains an email.
    - Introduced `CometChatPhoneNumberFormatter` to format a text if it contains a phone number.
    - Introduced `CometChatTextFormatter` an abstract class that structure for creating custom text formatters to format text in the message composer and message bubbles and last message of conversations in conversation list.
    - Added `CustomTextEditingController` to handle custom formatting of text in the message composer.
    - Added `AttributedText` to handle custom formatting of text wherever formatting is required.

**Enhancements**
- Updated `cometchat_sdk` to version `4.0.10`
- Added method `getConversationSubtitle()` in Data Source which returns a Widget that would be displayed as the subtitle for conversations shown in `CometChatConversations`
- Introduced a new parameter `additionalConfigurations` in the methods `getTextMessageContentView()` and `getTextMessageBubble()` to enable developers to customize the formatting of text in `CometChatTextBubble` by passing a list of `CometChatTextFormatter` objects to the `textFormatters` property of `AdditionalConfigurations`.

## 4.2.10
**Fixes**
- Addressed a usability issue by removing the View Profile button in User Profile for streamlined navigation.
- Resolved an issue related to incorrect timezone display for Daylight Saving Time to ensure timely and correct information.

## 4.2.9
**Enhancements**
- Reordered the message options, such as react, reply, delete, etc., to improve the overall usability and user experience.
- Updated `cometchat_sdk` to version `4.0.8`

## 4.2.8
**New**
- Added support for the Hungarian Language in the localization feature.

**Enhancements**
- All `send*Message()` methods of the `CometChatUIkit` class now automatically set the logged-in user as the `sender` for the message object provided as an argument, regardless of any other value set as the sender.
- All `send*Message()` methods of the `CometChatUIkit` class will now automatically set a random `muid` if it is not already set with the message object.

## 4.2.7
**New**
- Added refresh icon in `CometChatImageBubble` and `ImageViewer`
- Introduced a placeholder in `ImageViewer`

**Fixes**
- Addressed a problem where the image view state was not refreshing from the error state, ensuring a smooth viewing experience.

## 4.2.6
**New**
- Added property `loadingIcon` in `CometChatReactionList` and `ReactionsConfiguration` to override the default icon shown when the reactions are being fetched
- Added properties `margin` and `padding` in `ReactionsStyle`

**Fixes**
- Fixed pixelation of AI features icon shown in `CometChatMessageComposer`

## 4.2.5
**New**
- Added `CometChatReactions` component to display reactions in `CometChatMessageBubble`,  using `ReactionCount` provided with the Reactions feature from `cometchat_sdk: ^4.0.7` 
- Added `ReactionsStyle` to customize the UI of this `CometChatReactions`, and `ReactionsConfiguration` to further configure the appearance and behavior of this component
- Added `CometChatReactionList` component to fetch and display reactions made on a particular message, using `ReactionsRequest` provided with the Reactions feature from `cometchat_sdk: ^4.0.7` 
- Added `ReactionListStyle` to customize the UI of this component, and `ReactionListConfiguration` to further configure the appearance and behavior of this component
- Added `icon` property in `CometChatButton`

̆**Enhancements**
- Upgraded `cometchat_sdk` to version `4.0.7`

## 4.2.4
**Fixed**
- `CET` and `GMT` TimeZone fix while initializing time zone

## 4.2.3
**Fixed**
- Media picker crash on Android devices when `targetSdkVersion` is 33 and above
- `CometChatMediaRecorder` emitting events even after being disposed on Android devices

## 4.2.2
**Added**
- New Widgets: `CometChatSchedulerBubble` for scheduling events, `CometChatTimeSlotSelector` for generating time slots
- New style classes: `SchedulerBubbleStyle`, `TimeSlotSelectorStyle`
- Support for selecting date time in `CometChatFormBubble` and updated overall UI of `CometChatFormBubble`

**Changed**
- [CometChat Chat SDK](https://pub.dev/packages/cometchat_sdk) dependency upgraded to `cometchat_sdk: ^4.0.5`

**Fixed**
- Fixed issue of captions and tags not being passed in `MediaMessage` when using media picker on iOS devices

## 4.1.0
**Added**
- Support for downloading videos in  `CometChatCallLogRecordings` widget of [cometchat_calls_uikit](https://pub.dev/packages/cometchat_calls_uikit)
- Methods `copyWith` and `merge` in `DateStyle`

**Changed**
- [CometChat Chat SDK](https://pub.dev/packages/cometchat_sdk) dependency upgraded to `cometchat_sdk: ^4.0.4`

## 4.0.5
**Fixed**
- Removed permission.MANAGE_EXTERNAL_STORAGE

## 4.0.4
**Added**
- Added support for Interactive messages 
- New Widgets: `CometChatQuickView`, `CometChatSingleSelect`, `CometChatFormBubble`
- New style classes: `QuickViewStyle`, `FormBubbleStyle`
- Introduced margin and padding in `CometChatListItem` via `ListItemStyle`

**Changed**
- [CometChat Chat SDK](https://pub.dev/packages/cometchat_sdk) dependency upgraded to `cometchat_sdk: ^4.0.3`

**Fixed**
- Message sending failed when file path contains space when using media picker on iOS devices

## 4.0.3
**Changed**
- Name of class `AiExtension` changed to `AIExtension`. `AIExtension` is the protocol layer for enabling the AI features in the CometChat Chat UI Kit.

## 4.0.2
**Added**
- Support for ai features in `AiExtension`
- New ui events `ccComposeMessage` and `onAiFeatureTapped`  in `CometChatUIEvents`, and its listeners in `CometChatUIEventListener`

**Changed**
- [CometChat Chat SDK](https://pub.dev/packages/cometchat_sdk) dependency upgraded to `cometchat_sdk: ^4.0.2`

## 4.0.1
**Added**
- Code level documentation

## 4.0.0
**Added**
- Properties in `UIKitSettings` to override admin and client host urls
- Methods `addExtension` and `getExtensionId` in `ExtensionsDataSource`
- Localized Strings

**Changed**
- [CometChat Chat SDK](https://pub.dev/packages/cometchat_sdk) dependency upgraded to `cometchat_sdk: ^4.0.1`
- [GetX](https://pub.dev/packages/get) dependency upgraded to `get: ^4.6.5`
- Order of options shown for a message
- `SoundManager` converted to a singleton class

**Removed**
- Unused imports
- Dead code

**Fixed**
- Size of media recorder icon in message composer

## 4.0.0-beta.1
- Initial release
