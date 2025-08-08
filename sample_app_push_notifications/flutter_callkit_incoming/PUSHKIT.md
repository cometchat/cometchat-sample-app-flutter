# Flutter Callkit Incoming

## Setup Pushkit for IOS.

If you are making VoIP application than you definitely want to update your application in the background state as well as wake your application when any VoIP call is being received.

## 🚀&nbsp; Setup


Make sure when you create Bundle ID(https://developer.apple.com/account/resources/identifiers) for app you have checked `Push Notifications`


1. Enable Voice over IP Setting
  * Xcode Project > Capabilities

    ![image info](https://raw.githubusercontent.com/hiennguyen92/flutter_callkit_incoming/master/images/Setting.png)

  <br>

  * VoIP Services Certificate

    Go to https://developer.apple.com/account/resources/certificates/add
    ![image info](https://raw.githubusercontent.com/hiennguyen92/flutter_callkit_incoming/master/images/VoIPServicesCertificate.png)

    Download the certificate and install it into the Keychain Access app(download .cer and double click to install).

  <br>
    
  * Export .p12

    ![image info](https://raw.githubusercontent.com/hiennguyen92/flutter_callkit_incoming/master/images/KeychainAccess.png)

  <br>
    
  * Convert .p12 to .pem (VOIP.pem)

    ```console
      openssl pkcs12 -in YOUR_CERTIFICATES.p12 -out VOIP.pem -nodes -clcerts
    ```
<br>

2. Configure VoIP Push Notifications in Xcode project (Swift)

* Setup VoIP

  ![image info](https://raw.githubusercontent.com/hiennguyen92/flutter_callkit_incoming/master/images/Xcode-S1.png)

<br>

* DeviceToken and handle incoming pushs
  ![image info](https://raw.githubusercontent.com/hiennguyen92/flutter_callkit_incoming/master/images/Xcode-S2.png)

<br>

* Start call from Recent history on click (add if necessary)

  ![image info](https://raw.githubusercontent.com/hiennguyen92/flutter_callkit_incoming/master/images/Xcode-S3.png)

<br>

* Example

  https://github.com/hiennguyen92/flutter_callkit_incoming/blob/master/example/ios/Runner/AppDelegate.swift
<br>
<br>
3. Testing

  * Using App
    https://github.com/onmyway133/PushNotifications

    ![image info](https://raw.githubusercontent.com/hiennguyen92/flutter_callkit_incoming/master/images/TestingApp.png)

<br>

  * Using Curl
    ```
    curl -v \
    -d '{"aps":{"alert":"Hien Nguyen Call"},"id":"44d915e1-5ff4-4bed-bf13-c423048ec97a","nameCaller":"Hien Nguyen","handle":"0123456789","isVideo":true}' \
    -H "apns-topic: com.hiennv.testing.voip" \
    -H "apns-push-type: voip" \
    --http2 \
    --cert VOIP.pem:'<passphrase>' \
    https://api.development.push.apple.com/3/device/<device token>
    ```

  * NOTE

    To be able to testing in Terminated State
    `Xcode -> Edit Schema -> Wait for the executable to be launched`
