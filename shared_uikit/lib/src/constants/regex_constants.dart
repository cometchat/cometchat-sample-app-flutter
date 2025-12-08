///[RegexConstants] is a utility contains patterns or verifying selective text inputs
class RegexConstants {
  static const emailRegexPattern =
      r'^(.*?)((mailto:)?[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z][A-Z]+)';
  static const urlRegexPattern =
      r"[(http(s)?|ftp):\/\/(www\.)?a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)";
  static const phoneNumberRegexPattern =
      r'\b(\+?( |-|\.)?\d{1,2}( |-|\.)?)?(\(?\d{3}\)?|\d{3})( |-|\.)?(\d{3}( |-|\.)?\d{4})\b';

  static const mentionRegexPattern = r'<@(uid|all):(.+?)>';
}
