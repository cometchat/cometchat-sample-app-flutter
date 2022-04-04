import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class LoadingIndicator extends StatelessWidget {
  final double height;
  final double width;
  const LoadingIndicator({Key? key, this.height = 50, this.width = 50})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        child: const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          strokeWidth: 1.0,
        ),
        height: height,
        width: width,
      ),
    );
  }
}

showLoadingIndicatorDialog(BuildContext context) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            height: 220,
            width: 100,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 45,
                  child: Image.asset("assets/cometchat_logo.png"),
                ),
                const Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                )
              ],
            ),
          ),
        );
      });
}
