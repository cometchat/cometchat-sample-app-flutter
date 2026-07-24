import Flutter
import UIKit
import Foundation
import AVFoundation
import CoreLocation
import QuickLook
import MobileCoreServices
// For iOS 14+
import UniformTypeIdentifiers


var globalRegistrar: FlutterPluginRegistrar?
var docController : UIDocumentInteractionController?
var viewController :  UIViewController?
var globalResult:  FlutterResult?

public class CometchatChatUikitPlugin: NSObject, FlutterPlugin , QLPreviewControllerDataSource, QLPreviewControllerDelegate, UINavigationControllerDelegate
{
    
    lazy var previewItem = NSURL()
    static var interactionController: UIDocumentInteractionController?
    static var uiViewController: UIViewController?
    
    
    


    
    
public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "cometchat_chat_uikit", binaryMessenger: registrar.messenger())
      let instance = CometchatChatUikitPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    globalRegistrar = registrar
    
  }
    
    override init() {
        super.init()
    }

    
    
    
    /// Invoked when the Quick Look preview controller needs to know the number of preview items to include in the preview navigation list.
    /// - Parameter controller: A specialized view for previewing an item.
    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int { return 1 }
    
    
    /// Invoked when the Quick Look preview controller needs the preview item for a specified index position.
    /// - Parameters:
    ///   - controller: A specialized view for previewing an item.
    ///   - index: The index position, within the preview navigation list, of the item to preview.
    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return self.previewItem as QLPreviewItem
    }
    
   
    
    
    func createTemporaryURLforVideoFile(url: NSURL) -> NSURL {
        /// Create the temporary directory.
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        /// create a temporary file for us to copy the video to.
        let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(url.lastPathComponent ?? "")
        /// Attempt the copy.
        do {
            try FileManager().copyItem(at: url.absoluteURL!, to: temporaryFileURL)
        } catch {
            print("There was an error copying the video file to the temporary location.")
        }

        return temporaryFileURL as NSURL
    }
      
    
    
  
    private func presentQuickLook() {
        DispatchQueue.main.async { [weak self] in
            let previewController = QLPreviewController()
            previewController.modalPresentationStyle = .popover
            previewController.dataSource = self
            previewController.navigationController?.title = ""
           
            if let controller = self?.getTopViewController() {
                controller.present(previewController, animated: true, completion: nil)
            }
        }
    }
    
    private func getTopViewController() -> UIViewController? {
        if #available(iOS 13.0, *) {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            let window = windowScene?.windows.first(where: { $0.isKeyWindow })
            return window?.rootViewController
        } else {
            return UIApplication.shared.keyWindow?.rootViewController
        }
    }
    
    
  
    

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      let args = call.arguments as? [String: Any] ?? [String: Any]();
                        switch call.method {
                        default:
                            result(FlutterMethodNotImplemented)
                        }
  }
    
    
    func toInt(duration : Double) -> Int? {
        if duration >= Double(Int.min) && duration < Double(Int.max) {
            return Int(duration)
        } else {
            return nil
        }
    }
    
    
}

