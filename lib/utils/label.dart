import 'package:flutter/material.dart';

class Label extends StatelessWidget {
  final String text;

  const Label({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        child: Text(
          text,
        ),
      ),
    );
  }
}
