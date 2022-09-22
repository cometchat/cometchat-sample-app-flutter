import 'package:flutter/material.dart';

class ModuleCard extends StatelessWidget {
  final String title;
  final String description;
  final Function() onTap;
  final Widget? leading;

  const ModuleCard(
      {Key? key,
      required this.title,
      required this.description,
      required this.onTap,
      this.leading})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(1, 4, 1, 4),
      child: Card(
        elevation: 4.0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        margin: const EdgeInsets.fromLTRB(4, 4, 4, 4),
        child: ListTile(
          contentPadding: const EdgeInsets.all(8.0),
          leading: leading,
          title: Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ),
          onTap: onTap,
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
