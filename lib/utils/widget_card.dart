import 'package:flutter/material.dart';

class WidgetCard extends StatelessWidget {
  final List<WidgetProps> widgets;
  const WidgetCard({Key? key, required this.widgets}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 4.0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
            children: List<Widget>.generate(
                widgets.length, (index) => getTile(index))));
  }

  getTile(int index) {
    WidgetProps _property = widgets[index];
    return ListTile(
      dense: true,
      leading: Image.asset(
        _property.leadingImageURL,
        height: _property.leadingImageDimensions,
        width: _property.leadingImageDimensions,
      ),
      title: Text(
        _property.title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_property.description),
            if (index != widgets.length - 1)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Divider(
                  color: Colors.black,
                ),
              )
          ],
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        color: Colors.black,
      ),
      onTap: _property.onTap,
    );
  }
}

class WidgetProps {
  String title;
  String leadingImageURL;
  double? leadingImageDimensions;
  String description;
  Function() onTap;

  WidgetProps(
      {required this.title,
      required this.leadingImageURL,
      this.leadingImageDimensions,
      required this.description,
      required this.onTap});
}
