import 'package:cometchat_flutter_sample_app/utils/background_card.dart';
import 'package:cometchat_flutter_sample_app/utils/label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_kit/flutter_chat_ui_kit.dart';

class BadgeContainer extends StatelessWidget {
  const BadgeContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BackGroundCard(
        title: "Badge Count",
        description:
            "CometChtBadgeCount is a custom component which is used to display the unread message count. "
            "It can be used in places like ConversationListItem , etc .",
        child: BadgeView());
  }
}

class BadgeView extends StatefulWidget {
  const BadgeView({Key? key}) : super(key: key);

  @override
  _BadgeViewState createState() => _BadgeViewState();
}

class _BadgeViewState extends State<BadgeView> {
  List<Color> colorList = [
    Colors.red,
    Colors.green,
    Colors.yellow,
    Colors.black,
    Colors.blue
  ];
  Color? selectedColor;
  int _count = 2;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CometChatBadge(
          count: _count,
          style: BadgeStyle(
            background: selectedColor,
          ),
        ),
        TextFormField(
          decoration: const InputDecoration(
              hintText: "Enter Count", labelText: "Count"),
          keyboardType: TextInputType.number,
          onChanged: (val) {
            try {
              setState(() {
                _count = int.parse(val);
              });
            } catch (_) {}
          },
        ),
        const Label(text: "Background :"),
        Row(
          children: List.generate(
            colorList.length,
            (index) => getBackGroundColorContainer(colorList[index]),
          ),
        ),
      ],
    );
  }

  getBackGroundColorContainer(Color color) {
    return Flexible(
      flex: 1,
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedColor = color;
          });
        },
        child: Container(
          height: 30,
          color: color,
        ),
      ),
    );
  }
}
