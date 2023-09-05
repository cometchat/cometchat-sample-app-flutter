import 'package:cometchat_flutter_sample_app/dashboard.dart';
import 'package:cometchat_flutter_sample_app/utils/alert.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

class LoginWithUID extends StatefulWidget {
  const LoginWithUID({Key? key}) : super(key: key);

  @override
  _LoginWithUIDState createState() => _LoginWithUIDState();
}

class _LoginWithUIDState extends State<LoginWithUID> {
  String customUidLogin = "";
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Sign In",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Welcome !",
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Kindly enter UID to proceed",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 5,
                ),
                SizedBox(
                  height: 46,
                  child: TextFormField(
                    onChanged: (val) {
                      customUidLogin = val;
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'UID',
                      hintText: 'UID',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        isExtended: true,
        backgroundColor: Colors.blue,
        onPressed: () {
          if (customUidLogin.isNotEmpty) {
            loginUser(customUidLogin, context);
          }
        },
        label: const Text(
          'Login',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  //Login User function must pass userid and authkey should be used only while developing
  loginUser(String userId, BuildContext context) async {
    Alert.showLoadingIndicatorDialog(context);
    // ToastContext().init(context); //Replace with name and uid of user
    User? _user = await CometChat.getLoggedInUser();
    try {
      if (_user != null) {
        await CometChatUIKit.logout();
      }
    } catch (_) {}

    await CometChatUIKit.login(userId, onSuccess: (User loggedInUser) {
      debugPrint("Login Successful : $loggedInUser");
      _user = loggedInUser;
    }, onError: (CometChatException e) {
      debugPrint("Login failed with exception:  ${e.message}");
      // Toast.show("Login failed",
      //     duration: Toast.lengthShort, gravity: Toast.bottom);
    });

    Navigator.of(context).pop();

    //if login is successful
    if (_user != null) {
      //USERID = _user!.uid;
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const Dashboard()));
    }
  }
}
