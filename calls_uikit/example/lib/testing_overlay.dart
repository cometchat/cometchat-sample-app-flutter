import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  OverlayEntry? _overlayEntry;

  // Method to show the incoming call notification card
  void showCallNotification() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 40.0, // Position it at the top of the screen
        left: 20.0,
        right: 20.0,
        child: Material(
          color: Colors.transparent,
          child: CometChatIncomingCall(
              user: User(
                name: "Muni Kiran",
                uid: "uid",
              ),
              call:
                  Call(receiverUid: "MK", type: "Audio", receiverType: "User")),
          // IncomingCallNotification(
          //   onAccept: () {
          //     // Handle accept call action
          //     hideCallNotification();
          //     print("Call Accepted");
          //   },
          //   onDecline: () {
          //     // Handle decline call action
          //     hideCallNotification();
          //     print("Call Declined");
          //   },
          // ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  // Method to hide the notification card
  void hideCallNotification() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Screen"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: showCallNotification,
          child: Text("Simulate Incoming Call"),
        ),
      ),
    );
  }
}

class IncomingCallNotification extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  IncomingCallNotification({required this.onAccept, required this.onDecline});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'George Allen',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          color: Colors.grey,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Incoming Voice Call',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                backgroundImage: AssetImage(
                    'assets/profile.jpg'), // Add an image in assets folder
                radius: 24,
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: onDecline,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Decline',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: onAccept,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Accept',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
