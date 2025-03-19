import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../cometchat_uikit_shared.dart';

enum FileType { image, video, audio, any, custom }

class PickedFile {
  PickedFile(
      {required this.name,
      required this.path,
      this.size,
      this.extension,
      this.fileType});

  final String name;
  final String path;
  final int? size;
  final String? extension;
  final String? fileType;
}

class MediaPicker {
  static final ImagePicker _picker = ImagePicker();

  static Future<PickedFile?> takePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      return PickedFile(name: image.name, path: image.path);
    } else {
      return null;
    }
  }

  static Future<PickedFile?> pickAnyFile() async {
    return await _getFilesFromMethodChannel(type: "any");
  }

  // static pickCustomFile() async {
  //   try {
  //     var result = await UIConstants.channel.invokeListMethod("pickFile",
  //         {"allowMultipleSelection": true, "withData": false, "type": "any"});
  //     print(result);
  //     if (result != null && result.first["path"] != null) {
  //       Map<String, dynamic> file = Map<String, dynamic>.from(result.first);
  //       return PickedFile(
  //         name: file["name"],
  //         path: file["path"],
  //         size: file["size"],
  //       );
  //     } else {
  //       return null;
  //     }
  //   } on PlatformException catch (e, stack) {
  //     debugPrint("$stack");
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  static Future<PickedFile?> pickImage() async {
    if(Platform.isAndroid) {
      return _getFilesFromMethodChannel(type: "image");
    }
    return await _getFilesFromMethodChannel(
        type: Platform.isIOS ? "image" : "custom",
        allowedExtensions: imageExtensions + videoExtensions);
  }

  static Future<PickedFile?> pickVideo() async {
    if(Platform.isAndroid) {
      return _getFilesFromMethodChannel(type: "video");
    }
    return await _getFilesFromMethodChannel(
        type: Platform.isIOS ? "video" : "custom",
        allowedExtensions: imageExtensions + videoExtensions);
  }

  static Future<PickedFile?> pickAudio() async {
    return _getFilesFromMethodChannel(type: "audio");
  }

  static List<String> videoExtensions = [
    "mp4",
    "avi",
    "mov",
    "mkv",
    "flv",
    "wmv",
    "webm",
    "mpg",
    "mpeg",
    "3gp",
    "mts",
    "m2ts",
    "vob",
    "mxf",
    "f4v"
  ];
  static List<String> imageExtensions = [
    "jpg",
    "jpeg",
    "png",
    "gif",
    "bmp",
    "svg",
    "webp",
    "tiff",
    "psd",
    "heif",
    "heic",
    "icns",
    "eps"
  ];
  static  List<String> audioExtensions = [
    "mp3",
    "wav",
    "ogg",
    "flac",
    "aac",
    "wma",
    "aiff",
    "m4a",
    "mid",
    "midi",
    "opus",
    "amr"
  ];
  static Future<PickedFile?> pickImageVideo() async {
    return await _getFilesFromMethodChannel(
        type: Platform.isIOS ? "imagevideo" : "custom",
        allowedExtensions: imageExtensions + videoExtensions);
  }

  static Future<PickedFile?> _getFilesFromMethodChannel(
      {String type = "any",
      bool? allowMultipleSelection = false,
      bool? withData = false,
      List<String>? allowedExtensions}) async {
    try {
      var result = await UIConstants.channel.invokeListMethod("pickFile", {
        "allowMultipleSelection": allowMultipleSelection,
        "withData": withData,
        "type": type,
        "allowedExtensions": allowedExtensions
      });
      if (result != null && result.first["path"] != null) {
        Map<String, dynamic> file = Map<String, dynamic>.from(result.first);
        String name = file["name"];
        String extension =
            name.substring(name.lastIndexOf(".") + 1).toLowerCase();
        String? fileType = _getFileType(extension);
        String path = file["path"];
        if (Platform.isIOS && path.contains(" ")) {
          path = Uri.encodeFull(path);
        }
        return PickedFile(
            name: name,
            path: path,
            size: file["size"],
            extension: extension,
            fileType: fileType);
      } else {
        return null;
      }
    } on PlatformException catch (e, stack) {
      debugPrint("$stack");
    } catch (e) {
      rethrow;
    }
    return null;
  }

  static String? _getFileType(String extension) {
    if (imageExtensions.contains(extension)) {
      return MessageTypeConstants.image;
    } else if (videoExtensions.contains(extension)) {
      return MessageTypeConstants.video;
    } else if (audioExtensions.contains(extension)) {
      return MessageTypeConstants.audio;
    } else {
      return null;
    }
  }
}
