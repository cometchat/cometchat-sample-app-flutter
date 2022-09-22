import 'package:cometchat_flutter_sample_app/utils/background_card.dart';
import 'package:cometchat_flutter_sample_app/utils/label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_kit/flutter_chat_ui_kit.dart';

class StatusIndicatorContainer extends StatelessWidget {
  const StatusIndicatorContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BackGroundCard(
        title: "StatusIndicator",
        description:
            "StatusIndicator component indicates whether a user is online or offline. ",
        child: StatusIndicatorView());
  }
}

class StatusIndicatorView extends StatefulWidget {
  const StatusIndicatorView({Key? key}) : super(key: key);

  @override
  _StatusIndicatorViewState createState() => _StatusIndicatorViewState();
}

class _StatusIndicatorViewState extends State<StatusIndicatorView> {
  List<Color> colorList = [
    Colors.red,
    Colors.green,
    Colors.yellow,
    Colors.black,
    Colors.blue
  ];
  Color? selectedColor = Colors.green;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CometChatStatusIndicator(
          backgroundColor: selectedColor,
          width: 40,
          height: 40,
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
