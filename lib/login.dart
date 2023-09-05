import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:cometchat_flutter_sample_app/login_with_uid.dart';
import 'package:cometchat_flutter_sample_app/sign_up.dart';
import 'package:cometchat_flutter_sample_app/utils/alert.dart';
import 'package:cometchat_flutter_sample_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

import 'dashboard.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  List<MaterialButtonUserModel> userModelList = [
    MaterialButtonUserModel(
        "superhero1", "SUPERHERO1", "assets/ironman_avatar.png"),
    MaterialButtonUserModel(
        "superhero2", "SUPERHERO2", "assets/captainamerica_avatar.png"),
    MaterialButtonUserModel(
        "superhero3", "SUPERHERO3", "assets/spiderman_avatar.png"),
    MaterialButtonUserModel(
        "superhero4", "SUPERHERO4", "assets/cyclops_avatar.png"),
  ];

  @override
  void initState() {
    super.initState();

    //CometChat SDk should be initialized at the start of application. No need to initialize it again
    // AppSettings appSettings = (AppSettingsBuilder()
    //       ..subscriptionType = CometChatSubscriptionType.allUsers
    //       ..region = CometChatConstants.region
    //       ..autoEstablishSocketConnection = true)
    //     .build();
    //
    // CometChat.init(CometChatConstants.appId, appSettings,
    //     onSuccess: (String successMessage) {
    //   debugPrint("Initialization completed successfully  $successMessage");
    // }, onError: (CometChatException excep) {
    //   debugPrint("Initialization failed with exception: ${excep.message}");
    // });

    makeUISettings();

    //initialization end
  }

  makeUISettings() {
    UIKitSettings uiKitSettings = (UIKitSettingsBuilder()
          ..subscriptionType = CometChatSubscriptionType.allUsers
          ..region = CometChatConstants.region
          ..autoEstablishSocketConnection = true
          ..appId = CometChatConstants.appId
          ..authKey = CometChatConstants.authKey
      .. callingExtension = CometChatCallingExtension()
    )
        .build();

    CometChatUIKit.init(uiKitSettings: uiKitSettings);
  }

  //Login User function must pass userid and authkey should be used only while developing
  loginUser(String userId, BuildContext context) async {
    Alert.showLoadingIndicatorDialog(context);
    User? _user = await CometChat.getLoggedInUser();

    try {
      if (_user != null) {
        if (_user.uid == userId) {
          Navigator.of(context).pop();

          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const Dashboard()));
          return;
        } else {
          await CometChat.logout(
              onSuccess: (_) {},
              onError:
                  (_) {}); //if logging in user is different from logged in user
        }
      }
    } catch (_) {}

    await CometChatUIKit.login(userId, onSuccess: (User loggedInUser) {
      debugPrint("Login Successful from UI : $loggedInUser");
      Navigator.of(context).pop();
      _user = loggedInUser;
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const Dashboard()));
    }, onError: (CometChatException e) {
      Navigator.of(context).pop();
      debugPrint("Login failed with exception:  ${e.message}");
    });

    // await CometChat.login(userId, CometChatConstants.authKey,
    //     onSuccess: (User loggedInUser) {
    //   debugPrint("Login Successful : $loggedInUser");
    //   Navigator.of(context).pop();
    //   _user = loggedInUser;
    //   Navigator.push(
    //       context, MaterialPageRoute(builder: (context) => const Dashboard()));
    // }, onError: (CometChatException e) {
    //   Navigator.of(context).pop();
    //   debugPrint("Login failed with exception:  ${e.message}");
    // });
  }

  Widget userSelectionButton(
      MaterialButtonUserModel model, BuildContext context) {
    return MaterialButton(
      color: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      onPressed: () {
        loginUser(model.userId, context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Image.asset(
              model.imageURL,
              height: 30,
              width: 30,
            ),
          ),
          Text(
            model.userId,
            style: const TextStyle(color: Colors.white, fontSize: 14.0),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: (Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset("assets/cometchat_logo.png", height: 100, width: 100),
              const Text(
                "CometChat",
                style: TextStyle(
                    color: Colors.black54,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
              const Text(
                "Kitchen Sink App",
                style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Wrap(
                children: const [
                  Text(
                    "Login with one of our sample user",
                    style: TextStyle(color: Colors.black38),
                  )
                ],
              ),
              const SizedBox(
                height: 20.0,
              ),

              //All available user Ids in grid
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 3.0,
                children: List.generate(
                    userModelList.length,
                    (index) =>
                        userSelectionButton(userModelList[index], context)),
              ),
              const SizedBox(height: 20),

              Wrap(
                children: const [
                  Text(
                    "or else continue login with",
                    style: TextStyle(color: Colors.black38),
                  )
                ],
              ),

              const SizedBox(
                height: 5,
              ),
              Center(
                child: MaterialButton(
                  color: Colors.blue,
                  height: 45,
                  minWidth: 200,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginWithUID()));
                  },
                  child: const Text(
                    "Login using UID",
                    style: TextStyle(color: Colors.black, fontSize: 14.0),
                  ),
                ),
              ),

              const SizedBox(height: 100),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("New to cometchat? "),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUp()));
                      },
                      child: const Text("CREATE NEW",
                          style: TextStyle(
                              //decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.blue)))
                ],
              ),

              Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("© 2022 CometChat inc."),
                )
              ])
            ],
          )),
        ),
      )),
    );
  }
}

class MaterialButtonUserModel {
  String username;
  String userId;
  String imageURL;

  MaterialButtonUserModel(this.username, this.userId, this.imageURL);
}
