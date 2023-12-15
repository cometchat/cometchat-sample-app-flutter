import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:cometchat_flutter_sample_app/utils/module_card.dart';
import 'package:flutter/material.dart';

class CallLogsDashboard extends StatefulWidget {
  const CallLogsDashboard({Key? key}) : super(key: key);

  @override
  State<CallLogsDashboard> createState() => _CallLogsDashboardState();
}

class _CallLogsDashboardState extends State<CallLogsDashboard> {
  User? loggedInUser;
  CallLog? callLog;

  @override
  void initState() {
    // TODO: implement initState
    initialize();
    super.initState();
  }

  initialize() async {
    loggedInUser = await CometChat.getLoggedInUser();
    setState(() {});
    createCallLog();
  }

  createCallLog() {
    if (loggedInUser != null) {
      callLog = CallLog(
        initiator: CallUser(
          name: loggedInUser?.name,
          avatar: loggedInUser?.avatar,
          uid: loggedInUser?.uid,
        ),
        type: "audio",
        totalDurationInMinutes: 121,
        initiatedAt: 1111111111,
        status: "busy",
        receiver: CallUser(
          name: "Kevin",
          avatar:
              "https://data-us.cometchat.io/assets/images/avatars/spiderman.png",
          uid: "UID233",
        ),
        participants: [
          Participants(
            uid: loggedInUser?.uid,
            avatar: loggedInUser?.avatar,
            name: loggedInUser?.name,
            totalAudioMinutes: 120,
            totalDurationInMinutes: 120,
            totalVideoMinutes: 60,
            isJoined: true,
            joinedAt: 1212121212,
          ),
          Participants(
            uid: "UID233",
            avatar:
                "https://data-us.cometchat.io/assets/images/avatars/spiderman.png",
            name: "Kevin",
            totalAudioMinutes: 120,
            totalDurationInMinutes: 120,
            totalVideoMinutes: 60,
            isJoined: true,
            joinedAt: 1212121212,
          ),
        ],
        recordings: [
          Recordings(
            startTime: 101,
            rid: "Recording",
            recordingUrl:
                "https://recordings-us.cometchat.io/236497dcc2cd529b/2023-12-15/v1.us.236497dcc2cd529b.170264141733632a2e3171d8a5dcb1f82b743fbc2730422263_2023-12-15-11-57-16.mp4",
            endTime: 101,
            duration: 40,
          ),
          Recordings(
            startTime: 30,
            rid: "Recordings",
            recordingUrl:
                "https://recordings-us.cometchat.io/236497dcc2cd529b/2023-12-15/v1.us.236497dcc2cd529b.170264141733632a2e3171d8a5dcb1f82b743fbc2730422263_2023-12-15-11-57-16.mp4",
            endTime: 101,
            duration: 100,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      "Call Logs",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              ModuleCard(
                title: "Call Logs",
                leading: Image.asset(
                  'assets/icons/audio-call.png',
                  height: 48,
                  width: 48,
                ),
                description:
                    "CometChatCallLogs is a widget which is used to display list of Call Logs",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CometChatCallLogs(),
                    ),
                  );
                },
              ),
              ModuleCard(
                title: "Call Logs With Details",
                leading: Image.asset(
                  'assets/icons/call_details.png',
                  height: 48,
                  width: 48,
                ),
                description:
                    "CometChatCallLogsWithDetails is a widget which is used to display list of Call Logs with an icon to display call details",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CometChatCallLogsWithDetails(),
                    ),
                  );
                },
              ),
              ModuleCard(
                title: "Call Log Details",
                leading: Image.asset(
                  'assets/icons/call_details.png',
                  height: 48,
                  width: 48,
                ),
                description:
                    "CometChatCallLogDetails is a widget which is used to display call detail of a particular callLog",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CometChatCallLogDetails(
                        callLog: callLog ?? CallLog(),
                      ),
                    ),
                  );
                },
              ),
              ModuleCard(
                title: "Call Log Participants",
                leading: Image.asset(
                  'assets/icons/call_participants.png',
                  height: 48,
                  width: 48,
                ),
                description:
                    "CometChatCallLogParticipants is a widget that displays list of participants for a particular Call.",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CometChatCallLogParticipants(
                        callLog: callLog ?? CallLog(),
                      ),
                    ),
                  );
                },
              ),
              ModuleCard(
                title: "Call Log Recordings",
                leading: Image.asset(
                  'assets/icons/Call_recording.png',
                  height: 48,
                  width: 48,
                ),
                description:
                    "CometChatCallLogRecordings is a widget that displays list of recordings for a particular Call.",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CometChatCallLogRecordings(
                        callLog: callLog ?? CallLog(),
                      ),
                    ),
                  );
                },
              ),
              ModuleCard(
                title: "Call Log History",
                leading: Image.asset(
                  'assets/icons/call_history.png',
                  height: 48,
                  width: 48,
                ),
                description:
                    "CometChatCallLogHistory is a widget which is used to display list of call history for a particular user or group.",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CometChatCallLogHistory(
                        callUser: CallUser(
                          name: "Kevin",
                          avatar:
                              "https://data-us.cometchat.io/assets/images/avatars/spiderman.png",
                          uid: "UID233",
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
