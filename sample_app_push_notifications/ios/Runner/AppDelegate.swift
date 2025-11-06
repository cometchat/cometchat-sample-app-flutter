import Flutter
import CallKit
import flutter_callkit_incoming
import UIKit
import PushKit
import Firebase
import AVFoundation

func createUUID(sessionid: String) -> String {
    let components = sessionid.components(separatedBy: ".")
    if let lastComponent = components.last {
        let truncatedString = String(lastComponent.prefix(32)) // Discard extra characters
        let uuid = truncatedString.replacingOccurrences(of:
                                                            "(\\w{8})(\\w{4})(\\w{4})(\\w{4})(\\w{12})", with: "$1-$2-$3-$4-$5", options:
                .regularExpression, range: nil).uppercased()
        return uuid;
    }
    return UUID().uuidString;
}

func convertDictionaryToJsonString(dictionary: [String: Any]) -> String? {
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options:
                .sortedKeys)
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
    } catch {
        print("Error converting dictionary to JSON: \(error.localizedDescription)")
    }
    return nil
}

@main
@objc class AppDelegate: FlutterAppDelegate, PKPushRegistryDelegate, CXProviderDelegate{
    var pushRegistry: PKPushRegistry!
    var callController: CXCallController?
    var callKitProvider: CXProvider?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey:
                                                        Any]?
    ) -> Bool {
        // Initialize Firebase first
//        if FirebaseApp.app() == nil {
            FirebaseApp.configure()  // Ensure Firebase is initialized
            FirebaseConfiguration.shared.setLoggerLevel(.debug)
//        }
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let appInfoChannel = FlutterMethodChannel(name: "com.cometchat.sampleapp.flutter.ios",
            binaryMessenger: controller.binaryMessenger)

        appInfoChannel.setMethodCallHandler({
              (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
              if call.method == "getAppInfo" {
                var appInfo: [String: String] = [:]
                appInfo["bundleId"] = Bundle.main.bundleIdentifier
                appInfo["version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                result(appInfo)
              } else if call.method == "endCall" {
                  if let args = call.arguments as? [String: Any],
                     let sessionId = args["sessionId"] as? String {
                      
                      print("📞 endCall called from Flutter with sessionId: \(sessionId)")
                      
                      let callUUIDString = createUUID(sessionid: sessionId)
                      
                      if let callUUID = UUID(uuidString: callUUIDString) {
                          print("📞 Generated UUID: \(callUUIDString)")
                          self.endCall(callUUID: callUUID)
                          result(true)
                      } else {
                          print("❌ Failed to create valid UUID from sessionId")
                          result(FlutterError(
                            code: "INVALID_UUID",
                            message: "Failed to create valid UUID from session ID",
                            details: nil
                          ))
                      }
                  } else if let activeCall = self.activeCallSession {
                      SwiftFlutterCallkitIncomingPlugin.sharedInstance?.endCall(activeCall)
                      result(true)
                  } else {
                      result(FlutterError(
                        code: "MISSING_SESSION_ID",
                        message: "Session ID is required",
                        details: nil
                      ))
                  }
              } else {
                result(FlutterMethodNotImplemented)
              }
            })
        
        // Register the Flutter plugins (only once)
        GeneratedPluginRegistrant.register(with: self)

        // PushKit setup (unchanged)
        pushRegistry = PKPushRegistry(queue: DispatchQueue.main)
        pushRegistry.delegate = self
        pushRegistry.desiredPushTypes = Set([.voIP])

        // CallKit setup (unchanged)
        let providerConfiguration = CXProviderConfiguration(localizedName: "Master App")
        providerConfiguration.supportsVideo = true
        providerConfiguration.maximumCallGroups = 1
        providerConfiguration.maximumCallsPerCallGroup = 1
        providerConfiguration.supportedHandleTypes = [.phoneNumber]

        callKitProvider = CXProvider(configuration: providerConfiguration)
        callKitProvider?.setDelegate(self, queue: nil)

        callController = CXCallController()


        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func endCall(callUUID: UUID) {
            print("🔥 endCall - Starting call cleanup for UUID: \(callUUID.uuidString)")
            
            callKitProvider?.reportCall(with: callUUID, endedAt: Date(), reason: .remoteEnded)
            print("✅ Reported call ended to CallKit provider")
            
            let endCallAction = CXEndCallAction(call: callUUID)
            let transaction = CXTransaction(action: endCallAction)
            
            callController?.request(transaction) { error in
                if let error = error {
                    print("❌ Failed to end call via controller: \(error.localizedDescription)")
                } else {
                    print("✅ Call ended successfully via controller")
                }
            }
            
            if let activeCall = self.activeCallSession,
               activeCall.uuid == callUUID.uuidString {
                self.activeCallSession = nil
                print("✅ Cleared active call session")
            }
            
        if let activeCall = self.activeCallSession, activeCall.uuid == callUUID.uuidString {
                SwiftFlutterCallkitIncomingPlugin.sharedInstance?.endCall(activeCall)
                print("✅ Ended FlutterCallkitIncoming session")
            }
        }

    // PKPushRegistryDelegate method to handle updates to push credentials
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials:
                      PKPushCredentials, for type: PKPushType) {
        print("VoIP token: \(credentials.token)") // Make sure you see the token in the logs
        let deviceToken = credentials.token.map { String(format: "%02x", $0) }.joined()
        print("Device Token (hex): \(deviceToken)") // Print the token in hex format
        // Send token to Flutter plugin
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP(deviceToken)
    }

    // PKPushRegistryDelegate method to handle token invalidation
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type:
                      PKPushType) {
        print("didInvalidatePushTokenFor")
        // Clear the device token if it gets invalidated
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP("")
    }

    var activeCallSession: flutter_callkit_incoming.Data?
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload:
                      PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        // Check if the app is in the foreground
        if UIApplication.shared.applicationState == .active {
            // App is in the foreground, do nothing or perform any desired action
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                completion()
            }
            return
        }
        guard type == .voIP else {
            print("Received non-VoIP push, ignoring.")
            completion()
            return
        }
        if let payloadData = payload.dictionaryPayload as? [String : Any] {
            let category = payloadData["type"] as! String
            switch category {
            case "chat": break
            case "action": break
            case "custom": break
            case "call":
                let callAction = payloadData["callAction"] as! String
                let senderName = payloadData["senderName"] as! String;
                let handle = senderName
                let sessionid = payloadData["sessionId"] as! String;
                let callType = payloadData["callType"] as! String;
                let callUUID = createUUID(sessionid: sessionid)
                let data = flutter_callkit_incoming.Data(id: callUUID, nameCaller:
                                                            senderName, handle: handle, type: callType == "audio" ? 0:1 )
                data.extra = ["message": convertDictionaryToJsonString(dictionary:
                                                                        payloadData)]
                switch callAction {
                case "initiated":
                    data.duration = 55000 // has to be greater than the CometChat duration
                    activeCallSession = data
                    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.showCallkitIncoming(data, fromPushKit:
                                                                                            true)
                    break
                case "unanswered", "cancelled", "rejected":
                    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.endCall(data)
                    break
                default: break
                }
                break
            default: break
            }
        }
        // Ensure the completion is called with a do statement
            do {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    completion()
                }
            }
    }
    
    func handleCallAccepted(_ callUUID: String) {
        print("handleCallAccepted triggered for \(callUUID)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let controller = self.window?.rootViewController as? FlutterViewController {
                let channel = FlutterMethodChannel(
                    name: "com.cometchat.sampleapp.flutter.ios",
                    binaryMessenger: controller.binaryMessenger
                )
                channel.invokeMethod("onCallAcceptedFromNative", arguments: ["uuid": callUUID])
            }
        }
    }

    // MARK: - CXProviderDelegate
    func providerDidReset(_ provider: CXProvider) {
        print("CXProvider reset")
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        print("Call answered from native iOS screen (lock/locked)")

        let callUUID = action.callUUID.uuidString
        handleCallAccepted(callUUID) // 👈 trigger Flutter callback
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        print("Call ended from native iOS screen")

        let callUUID = action.callUUID.uuidString

        // 1️⃣ End the CallKit session
        action.fulfill()

        // 2️⃣ Inform Flutter (via MethodChannel)
        if let controller = self.window?.rootViewController as? FlutterViewController {
            let channel = FlutterMethodChannel(
                name: "com.cometchat.sampleapp.flutter.ios",
                binaryMessenger: controller.binaryMessenger
            )
            channel.invokeMethod("onCallEndedFromNative", arguments: ["uuid": callUUID])
        }

        // 3️⃣ End the FlutterCallkitIncoming session
        if let activeCall = self.activeCallSession {
//            SwiftFlutterCallkitIncomingPlugin.sharedInstance?.endCall(activeCall)
            self.activeCallSession = nil
        }
    }


    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        print("Audio session activated")
    }

    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        print("Audio session deactivated")
    }

}
