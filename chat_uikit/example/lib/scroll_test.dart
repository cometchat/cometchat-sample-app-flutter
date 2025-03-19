import 'package:flutter/material.dart';

class MyScrollTestWidget extends StatefulWidget {
  @override
  _MyWidgetState createState()
  => _MyWidgetState();
}

class _MyWidgetState extends State<MyScrollTestWidget>  with SingleTickerProviderStateMixin
{
final _focusNode = FocusNode();
late Animation<double> paddingAnimation;

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    paddingAnimation = Tween<double>(begin: 0.0, end: 100.0).animate(CurvedAnimation(
      parent: AnimationController(
        duration: const Duration(milliseconds: 250),
        vsync: this,
      ),
      curve: Curves.easeInOut,
    ));
  }

@override
void dispose() {
_focusNode.dispose();
super.dispose();
}

@override
  Widget build(BuildContext context) {
 final bottomInset = MediaQuery.of(context).viewInsets.bottom;
  print("bottom insets: ${MediaQuery.of(context).viewInsets.bottom}");
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Container(
                  // height: 200,
                  color: Colors.blue,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: bottomInset>50?bottomInset-50:0),
                child: TextField(
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    print('Tapped outside');
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter text',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}