import 'package:flutter/material.dart';

/// Enum representing the type of a composer segment.
enum SegmentType {
  /// A normal text segment that supports rich text formatting.
  normal,
  
  /// A code block segment that displays monospace text without formatting.
  code,
}

/// Represents a single segment in the segmented composer.
/// 
/// Each segment has its own [TextEditingController] and [FocusNode],
/// allowing independent text editing and focus management.
/// 
/// Normal segments use [RichTextEditingController] for WYSIWYG formatting,
/// while code segments use plain [TextEditingController].
class ComposerSegment {
  /// Creates a new composer segment.
  /// 
  /// [id] must be unique within the composer.
  /// [type] determines whether this is a normal or code segment.
  /// [controller] manages the text content.
  /// [focusNode] manages focus for this segment.
  /// [language] is an optional language hint for code segments.
  /// [isInsideBlockquote] indicates if this segment is inside a blockquote context.
  ComposerSegment({
    required this.id,
    required this.type,
    required this.controller,
    required this.focusNode,
    this.language = '',
    this.isInsideBlockquote = false,
  });

  /// Unique identifier for this segment (e.g., "seg0", "seg1").
  final String id;

  /// The type of this segment (normal or code).
  final SegmentType type;

  /// The text editing controller for this segment.
  final TextEditingController controller;

  /// The focus node for this segment.
  final FocusNode focusNode;

  /// Optional language hint for code segments (e.g., "dart", "javascript").
  /// Defaults to empty string.
  final String language;

  /// Indicates if this segment is inside a blockquote context.
  /// 
  /// When true, the code block is rendered with blockquote styling
  /// (left border) and the final markdown includes the blockquote prefix.
  final bool isInsideBlockquote;

  /// Returns true if this segment has focus.
  bool get hasFocus => focusNode.hasFocus;

  /// Returns the text content of this segment.
  String get text => controller.text;

  /// Returns true if this segment's text is empty.
  bool get isEmpty => controller.text.isEmpty;

  /// Returns true if this segment's text is not empty.
  bool get isNotEmpty => controller.text.isNotEmpty;

  /// Disposes the controller and focus node.
  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }

  @override
  String toString() => 'ComposerSegment(id: $id, type: $type, text: "${text.length > 20 ? '${text.substring(0, 20)}...' : text}")';
}
