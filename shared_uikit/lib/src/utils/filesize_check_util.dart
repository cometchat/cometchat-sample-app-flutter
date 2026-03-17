import 'package:flutter/widgets.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

class FileSizeCheckUtil {
  // Private constructor
  FileSizeCheckUtil._();

  // Singleton instance
  static final FileSizeCheckUtil instance = FileSizeCheckUtil._();

  // Whether to hide moderation status (defaults to false)
  String errorMessage = "";

  // Store context for localization access
  BuildContext? _context;

  void setContext(BuildContext context) {
    _context = context;
  }

  // Method to check if exception is shown
  String isFileSizeException(String exception) {
    // Check for MIME type permission error
    if (exception == 'ERR_PERMISSION_DENIED') {
      return _handleMimeTypeError();
    }

    // Existing file size error handling
    String sizeLimit = _extractFileSize(exception);
    
    // Use localized string if context is available
    if (_context != null) {
      errorMessage = Translations.of(_context!).fileSizeExceedsLimit(sizeLimit);
    } else {
      errorMessage = "File exceeds the $sizeLimit limit - try a smaller one.";
    }
    return errorMessage;
  }
  
  // Handle MIME type permission error
  String _handleMimeTypeError() {
    if (_context != null) {
      return Translations.of(_context!).fileTypeNotAllowed;
    }
    return "This file type is not allowed.";
  }

  // Helper method to extract file size from exception message
  String _extractFileSize(String exception) {
    RegExp regex = RegExp(r'(\d+(?:\.\d+)?)\s*(MB|GB|KB|TB)', caseSensitive: false);
    Match? match = regex.firstMatch(exception);

    if (match != null) {
      String number = match.group(1)!;
      String unit = match.group(2)!;
      // Remove trailing .00 decimals (e.g. "100.00" -> "100")
      if (number.contains('.')) {
        double parsed = double.tryParse(number) ?? 0;
        if (parsed == parsed.truncateToDouble()) {
          number = parsed.toInt().toString();
        }
      }
      return '$number $unit';
    }
    return '100 MB';
  }
}
