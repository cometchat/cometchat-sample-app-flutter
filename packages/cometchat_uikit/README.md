<p align="center">
  <img alt="CometChat" src="https://assets.cometchat.io/website/images/logos/banner.png">
</p>

# CometChat UIKit for Flutter

CometChat UIKit for Flutter provides pre-built UI components for chat and calling, designed to minimize development effort while offering full customization.

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  cometchat_chat_uikit:
    hosted: https://dart.cloudsmith.io/cometchat/cometchat/
    version: ^6.0.0-beta1
```

Then run:

```bash
flutter pub get
```

## Local Development Setup

If you want to work with the UIKit source locally (e.g., to debug or customize):

1. Clone the repository:

```bash
git clone https://github.com/cometchat/cometchat-uikit-flutter.git
cd cometchat-uikit-flutter
```

2. To use the local UIKit in the sample app or your own project, update the `cometchat_chat_uikit` dependency in `pubspec.yaml` to use a path:

```yaml
dependencies:
  cometchat_chat_uikit:
    path: ../../packages/cometchat_uikit
```

3. Install dependencies:

```bash
cd examples/sample_app/ios
pod install
cd ../../..
```

4. For iOS, install CocoaPods dependencies:

```bash
cd examples/sample_app/ios
pod install
cd ../../..
```

5. Run the sample app to verify everything works:

```bash
cd examples/sample_app
flutter run
```

## Package Structure

```
lib/
├── chat_ui/                    # Chat UI components
├── call_ui/                    # Calling UI components
├── shared_ui/                  # Shared widgets and utilities
├── cometchat_chat_uikit.dart   # Chat UIKit barrel export
└── cometchat_calls_uikit.dart  # Calls UIKit barrel export
```

## Dependencies

- [cometchat_sdk](https://pub.dev/packages/cometchat_sdk) - CometChat core SDK
- [cometchat_calls_sdk](https://dart.cloudsmith.io/cometchat/cometchat/) - CometChat Calls SDK
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) - State management

## Running Tests

```bash
cd packages/cometchat_uikit
flutter test
```

Tests are organized to mirror the `lib/` structure:

```
test/
└── chat_ui/
    ├── conversations/          # BLoC, repository, and use case tests
    └── message_list/           # BLoC, repository, and use case tests
```

## Documentation

Refer to our [official documentation](https://www.cometchat.com/docs/ui-kit/flutter/overview) for detailed usage guides and component references.

## Help and Support

For issues, consult our [documentation](https://www.cometchat.com/docs/ui-kit/flutter/overview) or create a [support ticket](https://help.cometchat.com/hc/en-us) or seek real-time support via the [CometChat Dashboard](https://app.cometchat.com/).
