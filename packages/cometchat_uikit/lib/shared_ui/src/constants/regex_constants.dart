///[RegexConstants] is a utility contains patterns or verifying selective text inputs
class RegexConstants {
  static const emailRegexPattern =
      r'(mailto:)?[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}';
  static const urlRegexPattern =
      r'(?:https?|ftp):\/\/[^\s<>\[\]]+|www\.[^\s<>\[\]]+\.[a-zA-Z]{2,}[^\s<>\[\]]*';
  static const phoneNumberRegexPattern =
      r'\b(\+?( |-|\.)?\d{1,2}( |-|\.)?)?(\(?\d{3}\)?|\d{3})( |-|\.)?(\d{3}( |-|\.)?\d{4})\b';

  static const mentionRegexPattern = r'<@(uid|all):(.+?)>';
}
