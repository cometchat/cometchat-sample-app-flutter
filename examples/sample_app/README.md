<p align="center">
  <img alt="CometChat" src="https://assets.cometchat.io/website/images/logos/banner.png">
</p>

# CometChat UIKit Sample App

A sample Flutter app demonstrating the CometChat UIKit components for chat and calling.

## Features

- Login with sample users
- Conversations list
- 1:1 and group messaging
- Message composer with attachments
- User and group info screens
- Call log details
- Contact list
- Group creation and management

## Prerequisites

- Flutter SDK >= 3.27.0
- Dart SDK >= 3.6.0
- iOS 16.0+ / Android 5.0+
- A [CometChat](https://app.cometchat.com/) account

## Setup

1. Install dependencies:

```bash
flutter pub get
```

2. For iOS, install pods:

```bash
cd ios
pod install
cd ..
```

3. Run the app:

```bash
flutter run
```

On first launch, the app will show a credentials screen where you can enter your App ID, Region, and Auth Key. These are saved locally for subsequent launches.

Alternatively, you can hardcode credentials in `lib/app_credentials.dart` to skip the credentials screen:

```dart
class AppCredentials {
  static const String _defaultAppId = 'YOUR_APP_ID';
  static const String _defaultRegion = 'YOUR_REGION';
  static const String _defaultAuthKey = 'YOUR_AUTH_KEY';
}
```

## Project Structure

```
lib/
├── main.dart               # App entry point
├── app_credentials.dart    # CometChat credentials
├── screens/                # App screens
├── services/               # API and service layer
├── models/                 # Data models
├── utils/                  # Utility classes
└── widgets/                # Reusable widgets
```

## Help and Support

For issues running the project, consult our [documentation](https://www.cometchat.com/docs/ui-kit/flutter/v6/overview) or create a [support ticket](https://help.cometchat.com/hc/en-us).
