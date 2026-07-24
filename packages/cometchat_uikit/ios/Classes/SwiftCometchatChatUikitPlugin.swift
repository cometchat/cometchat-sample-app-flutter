import Flutter
import UIKit
import Foundation
import AVFoundation
import CoreLocation
import QuickLook
import MobileCoreServices
import UniformTypeIdentifiers

enum Sound {
    case incomingCall
    case incomingMessage
    case incomingMessageForOther
    case outgoingCall
    case outgoingMessage
}

public var audioPlayer: AVAudioPlayer?
var globalRegistrar: FlutterPluginRegistrar?
var globalResult: FlutterResult?

public class CometchatChatUikitPlugin: NSObject,
FlutterPlugin,
FlutterStreamHandler,
QLPreviewControllerDataSource,
QLPreviewControllerDelegate,
UIDocumentPickerDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate {

    lazy var previewItem = NSURL()
    static var uiViewController: UIViewController?
    
    // Keyboard height tracking
    private var keyboardHeightEventSink: FlutterEventSink?

    var documentPicker = UIDocumentPickerViewController(
        documentTypes: [
            "public.data",
            "public.content",
            "public.audiovisual-content",
            "public.movie",
            "public.video",
            "public.audio",
            "public.text",
            "public.zip-archive",
            "com.pkware.zip-archive"
        ],
        in: .import
    )

    var imagePicker = UIImagePickerController()
    var filePickerResult: FlutterResult?
    private var audioRecorder: AudioRecorder?

    // Retains the export ("Save as") picker's delegate for its lifetime. Kept
    // separate from `filePickerResult`/the import picker so the two flows never
    // cross-talk through the shared UIDocumentPickerDelegate methods.
    private var pendingSaveDelegate: SaveAsPickerDelegate?

    // MARK: - Plugin Register
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "cometchat_chat_uikit",
            binaryMessenger: registrar.messenger()
        )

        let rootVC = UIApplication.shared.delegate?.window??.rootViewController
        let instance = CometchatChatUikitPlugin(viewController: rootVC)

        registrar.addMethodCallDelegate(instance, channel: channel)
        globalRegistrar = registrar
        
        // Keyboard height event channel
        let keyboardHeightChannel = FlutterEventChannel(
            name: "com.cometchat.keyboard_height_channel",
            binaryMessenger: registrar.messenger()
        )
        keyboardHeightChannel.setStreamHandler(instance)
    }

    init(viewController: UIViewController?) {
        super.init()
        CometchatChatUikitPlugin.uiViewController = viewController
        documentPicker.delegate = self
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = ["public.image", "public.movie"]
    }
    
    // MARK: - Keyboard Height Stream Handler
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        keyboardHeightEventSink = events
        registerKeyboardObservers()
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        keyboardHeightEventSink = nil
        unregisterKeyboardObservers()
        return nil
    }
    
    private func registerKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func unregisterKeyboardObservers() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo,
           let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            // Get safe area bottom inset
            var safeAreaBottom: CGFloat = 0
            if #available(iOS 11.0, *) {
                if let window = UIApplication.shared.windows.first {
                    safeAreaBottom = window.safeAreaInsets.bottom
                }
            }
            
            // Send both keyboard height and safe area as a dictionary
            let data: [String: Any] = [
                "keyboardHeight": keyboardFrame.height,
                "safeAreaBottom": safeAreaBottom
            ]
            keyboardHeightEventSink?(data)
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        // Get safe area bottom inset
        var safeAreaBottom: CGFloat = 0
        if #available(iOS 11.0, *) {
            if let window = UIApplication.shared.windows.first {
                safeAreaBottom = window.safeAreaInsets.bottom
            }
        }
        
        // Send both keyboard height (0) and safe area as a dictionary
        let data: [String: Any] = [
            "keyboardHeight": 0.0,
            "safeAreaBottom": safeAreaBottom
        ]
        keyboardHeightEventSink?(data)
    }

    // MARK: - Method Call Handler
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any] ?? [:]

        switch call.method {
        case "pickFile":
            pickFile(args: args, result: result)
        case "startRecordingAudio":
            startRecordingAudio(args: args, result: result)
        case "stopRecordingAudio":
            stopRecordingAudio(args: args, result: result)
        case "playRecordedAudio":
            audioRecorder?.startPlaying()
            result(true)
        case "pausePlayingRecordedAudio":
            audioRecorder?.pausePlaying()
            result(true)
        case "resumePlayingRecordedAudio":
            let success = audioRecorder?.resumePlaying() ?? false
            result(success)
        case "seekRecordedAudio":
            let position = args["position"] as? Int ?? 0
            let success = audioRecorder?.seekTo(positionMs: position) ?? false
            result(success)
        case "getPlaybackStatus":
            let status = audioRecorder?.getPlaybackStatus() ?? ["isPlaying": false, "currentPosition": 0, "duration": 0]
            result(status)
        case "extractWaveform":
            let sampleCount = args["sampleCount"] as? Int ?? 50
            audioRecorder?.extractWaveform(sampleCount: sampleCount) { amplitudes in
                result(amplitudes)
            }
        case "extractWaveformFromFile":
            let filePath = args["filePath"] as? String
            let sampleCount = args["sampleCount"] as? Int ?? 40
            if let path = filePath, !path.isEmpty {
                extractWaveformFromFile(filePath: path, sampleCount: sampleCount) { amplitudes in
                    result(amplitudes)
                }
            } else {
                result([Double]())
            }
        case "pauseRecordingAudio":
            audioRecorder?.pauseRecording()
            result(true)
        case "resumeRecordingAudio":
            audioRecorder?.resumeRecording(result: result)
        case "releaseMediaResources":
            audioRecorder?.releaseMediaResources()
            audioRecorder = nil
            result(true)
        case "deleteFile":
            deleteFile(args: args, result: result)
        case "playCustomSound":
            playCustomSound(args: args, result: result)
        case "stopPlayer":
            audioPlayer?.stop()
            result(true)
        case "getClipboardImage":
            result(getClipboardImage())
        case "saveFileWithPicker":
            saveFileWithPicker(args: args, result: result)
        case "open_file":
            openFile(args: args)
            result(true)
        case "shareMessage":
            shareMessage(args: args)
            result(true)
        case "checkCameraPermission":
            checkCameraPermission(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    /// Reads a file off the system pasteboard (e.g. copied from Files or
    /// Photos) — image, video, audio OR document. Prefers original PNG/JPEG
    /// bytes for images; otherwise maps the first concrete pasteboard type to
    /// its MIME/extension and returns its data. Plain-text/URL types are
    /// skipped so a normal text paste isn't captured. Returns
    /// `["bytes": FlutterStandardTypedData, "mimeType": String, "fileName": String]`
    /// or nil when the pasteboard holds no file.
    private func getClipboardImage() -> [String: Any]? {
        let pasteboard = UIPasteboard.general
        if let png = pasteboard.data(forPasteboardType: "public.png") {
            return ["bytes": FlutterStandardTypedData(bytes: png), "mimeType": "image/png", "fileName": "pasted_image.png"]
        }
        if let jpeg = pasteboard.data(forPasteboardType: "public.jpeg") {
            return ["bytes": FlutterStandardTypedData(bytes: jpeg), "mimeType": "image/jpeg", "fileName": "pasted_image.jpg"]
        }
        // General path: the first pasteboard type carrying real data whose UTI
        // maps to a concrete MIME (video/audio/pdf/etc.). Text/URL are skipped.
        if #available(iOS 14.0, *) {
            for uti in pasteboard.types {
                guard let type = UTType(uti) else { continue }
                if type.conforms(to: .plainText) || type.conforms(to: .utf8PlainText)
                    || type.conforms(to: .url) || type.conforms(to: .text) {
                    continue
                }
                guard let mime = type.preferredMIMEType,
                      let ext = type.preferredFilenameExtension,
                      let data = pasteboard.data(forPasteboardType: uti),
                      !data.isEmpty else { continue }
                let base = mime.hasPrefix("video/") ? "pasted_video"
                    : mime.hasPrefix("audio/") ? "pasted_audio"
                    : mime.hasPrefix("image/") ? "pasted_image" : "pasted_file"
                return ["bytes": FlutterStandardTypedData(bytes: data), "mimeType": mime, "fileName": "\(base).\(ext)"]
            }
        }
        if pasteboard.hasImages, let image = pasteboard.image, let png = image.pngData() {
            return ["bytes": FlutterStandardTypedData(bytes: png), "mimeType": "image/png", "fileName": "pasted_image.png"]
        }
        return nil
    }

    // MARK: - File Picker
    private func pickFile(args: [String: Any], result: @escaping FlutterResult) {
        filePickerResult = result
        let type = args["type"] as? String ?? "file"
        let allowMultiple = args["allowMultipleSelection"] as? Bool ?? false

        DispatchQueue.main.async {
            guard let controller = CometchatChatUikitPlugin.uiViewController else { return }

            if type == "image" {
                self.imagePicker.mediaTypes = ["public.image"]
                controller.present(self.imagePicker, animated: true)
            } else if type == "video" {
                self.imagePicker.mediaTypes = ["public.movie"]
                controller.present(self.imagePicker, animated: true)
            } else if type == "imagevideo" {
                self.imagePicker.mediaTypes = ["public.image", "public.movie"]
                controller.present(self.imagePicker, animated: true)
            } else {
                // Multi-select for documents/audio — the delegate already
                // returns every picked URL.
                self.documentPicker.allowsMultipleSelection = allowMultiple
                controller.present(self.documentPicker, animated: true)
            }
        }
    }

    public func documentPicker(_ controller: UIDocumentPickerViewController,
    didPickDocumentsAt urls: [URL]) {
        var files = [[String: String]]()
        for url in urls {
            // Security-scoped resource: copy to app's tmp dir so the file
            // remains accessible after the picker dismisses.
            let accessing = url.startAccessingSecurityScopedResource()
            defer { if accessing { url.stopAccessingSecurityScopedResource() } }

            let tmpDir = FileManager.default.temporaryDirectory
            let dest = tmpDir.appendingPathComponent(url.lastPathComponent)
            // Remove stale copy if present
            try? FileManager.default.removeItem(at: dest)
            do {
                try FileManager.default.copyItem(at: url, to: dest)
                files.append([
                    "path": dest.path,
                    "name": dest.lastPathComponent
                ])
            } catch {
                // Fallback to original path if copy fails
                files.append([
                    "path": url.path,
                    "name": url.lastPathComponent
                ])
            }
        }
        filePickerResult?(files)
        filePickerResult = nil
    }

    public func imagePickerController(_ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var file: [String: String] = [:]

        if let url = info[.imageURL] as? URL {
            let copied = copyToAppTmp(url)
            file = ["path": copied.path, "name": copied.lastPathComponent]
        } else if let url = info[.mediaURL] as? URL {
            let copied = copyToAppTmp(url)
            file = ["path": copied.path, "name": copied.lastPathComponent]
        } else if let image = info[.originalImage] as? UIImage {
            // Fallback: .imageURL is nil (e.g. HEIC from iCloud) — write to tmp
            let tmpDir = FileManager.default.temporaryDirectory
            let dest = tmpDir.appendingPathComponent("picked_\(Int(Date().timeIntervalSince1970 * 1000)).jpg")
            if let data = image.jpegData(compressionQuality: 0.9) {
                try? data.write(to: dest)
                file = ["path": dest.path, "name": dest.lastPathComponent]
            }
        }

        picker.dismiss(animated: true)
        filePickerResult?([file])
        filePickerResult = nil
    }

    /// Copy a picker URL into the app's own tmp directory so it survives
    /// after the picker's sandbox is torn down.
    private func copyToAppTmp(_ url: URL) -> URL {
        let tmpDir = FileManager.default.temporaryDirectory
        let dest = tmpDir.appendingPathComponent(url.lastPathComponent)

        // Guard against same-path destruction.
        //
        // When `UIImagePickerController` returns a picked image, the URL is
        // already inside the app's own `tmp/` directory
        // (e.g. `.../Application/<APP>/tmp/<UUID>.png`). In that case
        // `dest == url`, so the `removeItem` below would delete the source
        // file — and the subsequent `copyItem` would throw because its
        // source no longer exists. The `catch` branch then returns the
        // original `url`, but the file at that path is gone, producing a
        // path that points to nothing and a silent upload failure.
        //
        // Resolve symlinks on both sides before comparing because on iOS
        // `NSTemporaryDirectory()` may return a `/var/...` path that the
        // system later aliases to `/private/var/...` (and vice-versa).
        if url.resolvingSymlinksInPath().path ==
           dest.resolvingSymlinksInPath().path {
            return url
        }

        try? FileManager.default.removeItem(at: dest)
        do {
            try FileManager.default.copyItem(at: url, to: dest)
            return dest
        } catch {
            return url // fallback to original
        }
    }

    // MARK: - Audio Recording
    private func startRecordingAudio(args: [String: Any], result: @escaping FlutterResult) {
        let permission = AVAudioSession.sharedInstance().recordPermission

        if permission == .granted {
            audioRecorder = AudioRecorder(binaryMessenger: globalRegistrar!.messenger())
            audioRecorder?.setupRecorder(result: result)
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.audioRecorder = AudioRecorder(binaryMessenger: globalRegistrar!.messenger())
                        self.audioRecorder?.setupRecorder(result: result)
                    } else {
                        result(false)
                    }
                }
            }
        }
    }

    private func stopRecordingAudio(args: [String: Any], result: @escaping FlutterResult) {
        let path = audioRecorder?.stopRecording(success: true)
        audioRecorder = nil
        result(path)
    }

    // MARK: - Audio Playback
    private func playCustomSound(args: [String: Any], result: @escaping FlutterResult) {
        guard
        let assetPath = args["assetAudioPath"] as? String,
        let key = globalRegistrar?.lookupKey(forAsset: assetPath),
        let path = Bundle.main.path(forResource: key, ofType: nil)
        else {
            result(false)
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer?.play()
            result(true)
        } catch {
            result(false)
        }
    }

    // MARK: - File Preview
    private func openFile(args: [String: Any]) {
        guard let path = args["file_path"] as? String else { return }
        previewItem = NSURL(fileURLWithPath: path)

        let preview = QLPreviewController()
        preview.dataSource = self
        CometchatChatUikitPlugin.uiViewController?.present(preview, animated: true)
    }

    // MARK: - Save As (document export)
    /// "Save as" — presents the system location picker (export mode) so the user
    /// chooses where the file lands. Uses the cached local copy when present,
    /// else downloads the URL to a temp file first. Result to Flutter: a
    /// non-empty string on success, or nil on cancel/failure.
    private func saveFileWithPicker(args: [String: Any], result: @escaping FlutterResult) {
        let urlStr = args["url"] as? String
        let fileName = (args["fileName"] as? String) ?? "download"
        let localPath = args["path"] as? String

        func present(_ fileURL: URL) {
            DispatchQueue.main.async {
                guard let vc = CometchatChatUikitPlugin.uiViewController else {
                    result(nil)
                    return
                }
                let picker: UIDocumentPickerViewController
                if #available(iOS 14.0, *) {
                    picker = UIDocumentPickerViewController(forExporting: [fileURL], asCopy: true)
                } else {
                    picker = UIDocumentPickerViewController(url: fileURL, in: .exportToService)
                }
                let delegate = SaveAsPickerDelegate { [weak self] saved in
                    self?.pendingSaveDelegate = nil
                    result(saved ? "saved" : nil)
                }
                picker.delegate = delegate
                self.pendingSaveDelegate = delegate
                vc.present(picker, animated: true)
            }
        }

        if let localPath = localPath,
           FileManager.default.fileExists(atPath: localPath) {
            present(URL(fileURLWithPath: localPath))
            return
        }

        guard let urlStr = urlStr, let remote = URL(string: urlStr) else {
            result(nil)
            return
        }
        let task = URLSession.shared.downloadTask(with: remote) { tempURL, response, error in
            guard let tempURL = tempURL, error == nil else {
                DispatchQueue.main.async { result(nil) }
                return
            }
            let dest = FileManager.default.temporaryDirectory
                .appendingPathComponent(fileName)
            try? FileManager.default.removeItem(at: dest)
            do {
                try FileManager.default.moveItem(at: tempURL, to: dest)
                present(dest)
            } catch {
                DispatchQueue.main.async { result(nil) }
            }
        }
        task.resume()
    }

    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }
    public func previewController(_ controller: QLPreviewController,
    previewItemAt index: Int) -> QLPreviewItem {
        previewItem
    }

    // MARK: - Share
    private func shareMessage(args: [String: Any]) {
        let item = args["message"] ?? ""
        let vc = UIActivityViewController(activityItems: [item], applicationActivities: nil)
        CometchatChatUikitPlugin.uiViewController?.present(vc, animated: true)
    }

    // MARK: - Delete File
    private func deleteFile(args: [String: Any], result: @escaping FlutterResult) {
        guard let path = args["filePath"] as? String else {
            result(false)
            return
        }
        try? FileManager.default.removeItem(atPath: path)
        result(true)
    }

    // MARK: - Camera Permission
    private func checkCameraPermission(result: @escaping FlutterResult) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .authorized {
            result(true)
        } else {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    result(granted)
                }
            }
        }
    }
    
    // MARK: - Waveform Extraction
    private func extractWaveformFromFile(filePath: String, sampleCount: Int, completion: @escaping ([Double]) -> Void) {
        let fileUrl = URL(fileURLWithPath: filePath)
        
        guard FileManager.default.fileExists(atPath: filePath) else {
            completion([])
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let audioFile = try AVAudioFile(forReading: fileUrl)
                let format = audioFile.processingFormat
                let frameCount = UInt32(audioFile.length)
                
                guard frameCount > 0 else {
                    DispatchQueue.main.async { completion([]) }
                    return
                }
                
                guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
                    DispatchQueue.main.async { completion([]) }
                    return
                }
                
                try audioFile.read(into: buffer)
                
                guard let floatData = buffer.floatChannelData else {
                    DispatchQueue.main.async { completion([]) }
                    return
                }
                
                let channelData = floatData[0]
                let totalSamples = Int(buffer.frameLength)
                let samplesPerChunk = max(1, totalSamples / sampleCount)
                var amplitudes: [Double] = []
                
                for i in 0..<sampleCount {
                    let startSample = i * samplesPerChunk
                    let endSample = min(startSample + samplesPerChunk, totalSamples)
                    
                    if startSample >= totalSamples {
                        break
                    }
                    
                    // Calculate RMS for this chunk
                    var sum: Float = 0
                    for j in startSample..<endSample {
                        let sample = channelData[j]
                        sum += sample * sample
                    }
                    
                    let rms = sqrt(sum / Float(endSample - startSample))
                    
                    // For silent audio, rms will be very low (< 0.01)
                    // Scale appropriately - silent audio should show flat/low bars
                    var normalizedAmplitude: Double
                    if rms < 0.01 {
                        // Silent or near-silent - show minimal bar
                        normalizedAmplitude = 0.15 + Double(rms) * 5.0
                    } else if rms < 0.1 {
                        // Quiet audio
                        normalizedAmplitude = 0.2 + Double(rms) * 3.0
                    } else if rms < 0.3 {
                        // Normal audio
                        normalizedAmplitude = 0.5 + Double(rms - 0.1) * 2.0
                    } else {
                        // Loud audio
                        normalizedAmplitude = 0.9 + Double(rms - 0.3) * 0.33
                    }
                    
                    amplitudes.append(min(1.0, max(0.15, normalizedAmplitude)))
                }
                
                DispatchQueue.main.async {
                    completion(amplitudes)
                }

            } catch {
                DispatchQueue.main.async { completion([]) }
            }
        }
    }
}

/// A dedicated delegate for the "Save as" export picker, kept separate from the
/// plugin's own `UIDocumentPickerDelegate` (which drives the import/pickFile
/// flow) so the two never cross-talk. Reports exactly once whether the user
/// picked a destination.
final class SaveAsPickerDelegate: NSObject, UIDocumentPickerDelegate {
    private let onDone: (Bool) -> Void
    private var finished = false

    init(onDone: @escaping (Bool) -> Void) {
        self.onDone = onDone
    }

    private func finish(_ saved: Bool) {
        if finished { return }
        finished = true
        onDone(saved)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController,
                        didPickDocumentsAt urls: [URL]) {
        finish(!urls.isEmpty)
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        finish(false)
    }
}
