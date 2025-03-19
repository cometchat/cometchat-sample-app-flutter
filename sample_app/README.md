
<p align="center">
  <img alt="CometChat" src="https://assets.cometchat.io/website/images/logos/banner.png">
</p>

# Flutter Sample App by CometChat

This is a reference application showcasing the integration of [CometChat's Flutter UI Kit](https://www.cometchat.com/docs/ui-kit/flutter/overview) in a Flutter project. It demonstrates how to implement real-time messaging and voice/video calling features with ease.

<div style="display: flex; align-items: center; justify-content: center">
   <img src="../screenshots/overview_cometchat_screens.png" />
</div>


## Prerequisites

Sign up for a [CometChat](https://app.cometchat.com/) account to obtain your app credentials: _`App ID`_, _`Region`_, and _`Auth Key`_

**iOS**
- XCode
- Pod (CocoaPods) for iOS
- An iOS device or emulator with iOS 12.0 or above.
- Ensure that you have configured the provisioning profile in Xcode to run the app on a physical device.

**Android**
- Android Studio
- Android device or emulator with Android version 5.0 or above.


## Installation

1. Clone the repository:
   ```sh
   git clone https://github.com/cometchat/cometchat-uikit-flutter.git
   ```

2. Checkout v5 branch:
   ```sh
   git checkout v5
   ```

3. Open the project in Android Studio by navigating to the cloned directory.

4. Run `flutter pub get` to fetch all dependencies.

5. `[Optional]` Configure CometChat credentials:
    - Open the `app_credentials.dart` file located at `sample_app/lib/app_credentials.dart` and enter your CometChat _`App ID`_, _`Region`_, and _`Auth Key`_:
      ```dart
      AppCredentials {
         static String _appId = "YOUR_APP_ID";
         static String _authKey = "YOUR_AUTH_KEY";
         static String _region = "REGION";
      }
      ```

6. In the Run/Debug Configurations dropdown (on the top toolbar), select the preconfigured `sample_app` run configuration. Connect a `physical device` or select an `emulator` from the Device Selector dropdown. Click the Run ▶ button to launch the app.

   > **Note:** If the provisioning profile is not set up correctly in Xcode, you may encounter errors when running the app on a physical iOS device. Ensure that you have configured the provisioning profile before proceeding.


## Help and Support

For issues running the project or integrating with our UI Kits, consult our [documentation](https://www.cometchat.com/docs/ui-kit/flutter/getting-started) or create a [support ticket](https://help.cometchat.com/hc/en-us). You can also access real-time support via the [CometChat Dashboard](http://app.cometchat.com/).