extension StringFormatUtils on String {

  String removeTabsAndLineBreaks() {
    return replaceAll(RegExp(r'[\t\n\r]'), ' ').trim();
  }

}