import 'package:flutter/material.dart';

class SectionSeparator extends StatelessWidget {
  const SectionSeparator(
      {super.key,
      this.height = 32,
      required this.text,
      this.dividerColor,
      this.textStyle});

  final double height;

  final String text;

  final Color? dividerColor;

  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: height),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Divider(
            height: 1,
            thickness: 1,
            color: dividerColor ?? const Color(0xff141414).withOpacity(0.1),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: textStyle ??
                TextStyle(
                    color: const Color(0xff141414).withOpacity(0.5),
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }
}
