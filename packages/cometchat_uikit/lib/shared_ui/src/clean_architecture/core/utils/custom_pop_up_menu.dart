import 'package:flutter/material.dart';

class CustomPopupMenuItem<T> extends PopupMenuEntry<T> {
  final Widget child;
  final T? value;

  const CustomPopupMenuItem({super.key, required this.child, this.value});

  @override
  double get height => 48;

  @override
  bool represents(T? value) => this.value == value;

  @override
  State<StatefulWidget> createState() => _CustomPopupMenuItemState<T>();
}

class _CustomPopupMenuItemState<T> extends State<CustomPopupMenuItem<T>> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context, widget.value);
      },
      child: widget.child,
    );
  }
}