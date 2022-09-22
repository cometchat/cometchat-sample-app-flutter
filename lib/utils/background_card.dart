import 'package:flutter/material.dart';

class BackGroundCard extends StatelessWidget {
  final String title;
  final String description;
  final Widget child;

  const BackGroundCard(
      {Key? key,
      required this.title,
      required this.description,
      required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Card(
            elevation: 4.0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(description),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: child,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
