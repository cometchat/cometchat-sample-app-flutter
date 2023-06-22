import 'package:cometchat_flutter_sample_app/utils/animated_toggle.dart';
import 'package:cometchat_flutter_sample_app/utils/background_card.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

class AvatarContainer extends StatelessWidget {
  const AvatarContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BackGroundCard(
        title: "Avatar",
        description:
            "CometChatAvatar component displays an image or user/group avatar with fallback to the first two letters of the "
            "user name/group name .",
        child: AvatarView());
  }
}

class AvatarView extends StatefulWidget {
  const AvatarView({Key? key}) : super(key: key);

  @override
  _AvatarViewState createState() => _AvatarViewState();
}

class _AvatarViewState extends State<AvatarView> {
  List<Color> colorList = [
    Colors.red,
    Colors.green,
    Colors.yellow,
    Colors.black,
    Colors.blue
  ];
  Color? selectedColor;
  bool _showImage = true;
  List<String> options = ["image", "Name"];
  double _cornerRadius = 5;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Name : Shantanu Khare"),
        const SizedBox(
          height: 10,
        ),
        Center(
          child: CometChatAvatar(
            image: _showImage == true
                // ? "https://data-us.cometchat.io/assets/images/avatars/spiderman.png"
                ? 'https://data-us.cometchat.io/208434241880dc4d/media/1676951632_1179067617_0bb4ab5734e38db8b6fce07a5a912b84.jpg'
                : null,
            name: "Shantanu",
            style: AvatarStyle(
              background: selectedColor,
              outerBorderRadius: _cornerRadius,
              borderRadius: _cornerRadius,
              outerViewWidth: 5,
              height: 50,
              width: 50,
            ),
          ),
        ),
        TextFormField(
          decoration: const InputDecoration(
            labelText: "Corner Radius",
            hintText: "Enter Corner Radius here",
          ),
          keyboardType: const TextInputType.numberWithOptions(),
          onChanged: (String val) {
            try {
              setState(() {
                _cornerRadius = double.parse(val.trim());
              });
            } catch (_) {}
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Avatar"),
            AnimatedToggle(
                values: options,
                onToggleCallback: (val) {
                  if (val == "image") {
                    _showImage = true;
                  } else {
                    _showImage = false;
                  }

                  setState(() {});
                },
                width: 250)
          ],
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
