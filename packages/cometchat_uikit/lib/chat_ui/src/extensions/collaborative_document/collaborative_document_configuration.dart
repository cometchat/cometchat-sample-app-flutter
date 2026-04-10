import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

///[CollaborativeDocumentConfiguration] is a data class that has configuration properties
///to customize the functionality and appearance of [CollaborativeDocumentExtension]
///
/// ```dart
///  CollaborativeDocumentConfiguration(
///    title: "Collaborative Editing",
///    subtitle: "Open a document to edit together",
///    buttonText: "Open",
///    optionTitle: "Collaborative Document",
///    optionIcon: Icon(Icons.edit),
///    optionStyle: CollaborativeDocumentOptionStyle(
///    background: Colors.green,
///    iconTint: Colors.red,
///    titleStyle: TextStyle(color: Colors.white)
///    )
///   );
/// ```
class CollaborativeDocumentConfiguration {
  CollaborativeDocumentConfiguration({
    this.title,
    this.subtitle,
    this.icon,
    this.buttonText,
    this.style,
    this.optionTitle,
    this.collaborativeDocumentOptionStyle,
    this.optionIcon,
  });

  ///[title] title to be displayed , default is 'Collaborative Document'
  final String? title;

  ///[subtitle] subtitle to be displayed , default is 'Open document to edit content together'
  final String? subtitle;

  ///[icon] document icon to be shown on bubble
  final Widget? icon;

  ///[buttonText] button text to be shown , default is 'Open Document'
  final String? buttonText;

  ///[style] document bubble styling properties
  final CometChatCollaborativeBubbleStyle? style;

  ///[optionTitle] is the name for the option for this extension
  final String? optionTitle;

  ///[optionIcon] is the icon for the option for this extension
  final Widget? optionIcon;

  ///[collaborativeDocumentOptionStyle] provides style to the option that generates a collaborative document
  final CollaborativeDocumentOptionStyle? collaborativeDocumentOptionStyle;
}
