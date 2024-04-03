import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:cometchat_flutter_sample_app/utils/module_card.dart';
import 'package:flutter/material.dart';

class CallsDashboard extends StatelessWidget {
  const CallsDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User _user = User(
        name: 'Kevin',
        uid: 'UID233',
        avatar:
            "https://data-us.cometchat.io/assets/images/avatars/spiderman.png",
        role: "test",
        status: "online",
        statusMessage: "This is now status");

    Call _call = Call(
        receiverUid: "superhero1",
        type: 'audio',
        callInitiator: _user,
        callStatus: 'initiated',
        receiverType: 'user');

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 2, 10, 2),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.black,
                      ),
                    ),
                    const Text(
                      "Calls",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              ModuleCard(
                title: "Incoming call screen",
                leading: Image.asset(
                  'assets/icons/incoming-call.png',
                  height: 48,
                  width: 48,
                ),
                description:
                    "CometChatIncomingCall is a widget which is used to display incoming call",
                onTap: () {
                  CometChatIncomingCall _cometChatIncomingCall =
                      CometChatIncomingCall(
                    call: _call,
                    user: _user,
                    subtitle: 'Incoming Call',
                    onDecline: (context, call) {
                      Navigator.pop(context);
                    },
                    onAccept: (context, call) {
                      Navigator.pop(context);
                    },
                  );
                  //Launch to a new screen
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => _cometChatIncomingCall));
                },
              ),
              ModuleCard(
                title: "Outgoing call screen",
                leading: Image.asset(
                  'assets/icons/outgoing-call.png',
                  height: 48,
                  width: 48,
                ),
                description:
                    "CometChatOutgoingCall is a widget which is used to show outgoing call screen when the logged-in user calls another user.",
                onTap: () {
                  CometChatOutgoingCall _cometChatOutgoingCall =
                      CometChatOutgoingCall(
                    call: _call,
                    user: _user,
                    subtitle: 'Outgoing Call',
                    onDecline: (context, call) {
                      Navigator.pop(context);
                    },
                  );
                  //Launch to a new screen
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => _cometChatOutgoingCall));
                },
              ),
              ModuleCard(
                title: "Call Buttons",
                leading: Image.asset(
                  'assets/icons/call-buttons.png',
                  height: 48,
                  width: 48,
                ),
                description:
                    "These are button widgets which are used to initiate calls.",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 0.5,
                          title: Text(
                            "Call Buttons",
                            style: TextStyle(
                                color: cometChatTheme.palette.getAccent()),
                          ),
                          actions: [
                            CometChatCallButtons(
                              user: _user,
                              voiceCallIconURL: AssetConstants.audioCall,
                              videoCallIconURL: AssetConstants.videoCall,
                              onVoiceCallClick: (context, user, group) {
                                Navigator.pop(context);
                              },
                              onVideoCallClick: (context, user, group) {
                                Navigator.pop(context);
                              },
                              callButtonsStyle: CallButtonsStyle(
                                videoCallIconTint:
                                    cometChatTheme.palette.getPrimary(),
                                voiceCallIconTint:
                                    cometChatTheme.palette.getPrimary(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              ModuleCard(
                title: "Call Bubble",
                leading: Image.asset(
                  'assets/icons/call_bubble.png',
                  height: 48,
                  width: 48,
                ),
                description:
                    "CometChatCallBubble is a widget that displays the call information and a button to join the call.",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 0.5,
                        ),
                        body: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CometChatCallBubble(
                                        title:
                                            "Iron Man has initiated a group call",
                                        onTap: (context) {
                                          Navigator.pop(context);
                                        },
                                        alignment: BubbleAlignment.left,
                                        callBubbleStyle: CallBubbleStyle(
                                            titleStyle: TextStyle(
                                                color: cometChatTheme.palette
                                                    .getAccent(),
                                                fontSize: cometChatTheme
                                                    .typography.name.fontSize,
                                                fontWeight: cometChatTheme
                                                    .typography
                                                    .name
                                                    .fontWeight),
                                            iconTint: cometChatTheme.palette
                                                .getPrimary(),
                                            background:
                                                cometChatTheme.palette.mode ==
                                                        PaletteThemeModes.light
                                                    ? cometChatTheme.palette
                                                        .getAccent50()
                                                    : cometChatTheme.palette
                                                        .getAccent100(),
                                            borderRadius: 6.18)),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CometChatCallBubble(
                                        title: "You've initiated a call",
                                        onTap: (context) {
                                          Navigator.pop(context);
                                        },
                                        callBubbleStyle: CallBubbleStyle(
                                          titleStyle: TextStyle(
                                              color: cometChatTheme.palette
                                                  .backGroundColor.light,
                                              fontSize: cometChatTheme
                                                  .typography.name.fontSize,
                                              fontWeight: cometChatTheme
                                                  .typography.name.fontWeight),
                                          iconTint: cometChatTheme.palette
                                              .getBackground(),
                                          background: cometChatTheme.palette
                                              .getPrimary(),
                                          borderRadius: 6.18,
                                        )),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
