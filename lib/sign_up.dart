import 'package:cometchat_flutter_sample_app/dashboard.dart';
import 'package:cometchat_flutter_sample_app/login.dart';
import 'package:cometchat_flutter_sample_app/utils/alert.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';


class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String? uid;
  String? name;
  final formKey = GlobalKey<FormState>();
  final AutovalidateMode _validateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
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
                "Sample App",
                style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20.0,
              ),
              const Wrap(
                children:  [
                  Text(
                    "Sign Up",
                    style: TextStyle(color: Colors.black38, fontSize: 30),
                  )
                ],
              ),
              const SizedBox(
                height: 20.0,
              ),
              const SizedBox(height: 10),
              Form(
                autovalidateMode: _validateMode,
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      cursorColor: Colors.grey,
                      onSaved: (val) => uid = val,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'UID',
                        hintText: 'UID',
                      ),
                      validator: (String? arg) {
                        if (arg == null) {
                          return 'User ID must not be Blank';
                        } else if (arg.trim() == "") {
                          return 'User ID must not be Blank';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      cursorColor: Colors.grey,
                      onSaved: (val) => name = val,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Name',
                        hintText: 'Name',
                      ),
                      validator: (String? arg) {
                        if (arg == null) {
                          return 'Name must not be Blank';
                        } else if (arg.trim() == "") {
                          return 'Name must not be Blank';
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 40.0, 0, 20),
                      child: MaterialButton(
                        height: 40.0,
                        minWidth: MediaQuery.of(context).size.width,
                        color: const Color(0xff131513),
                        onPressed: () async {
                          final FormState form = formKey.currentState!;
                          if (form.validate() == false) {
                          } else {
                            form.save();
                            registerUser(context);
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Register",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have account? "),
                        GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Login()));
                            },
                            child: const Text("Login",
                                style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18)))
                      ],
                    )
                  ],
                ),
              )
            ],
          )),
        ),
      )),
    );
  }

  //Method to register new user
  registerUser(BuildContext context) async {
    Alert.showLoadingIndicatorDialog(context);

    User user = User(uid: uid!, name: name!);

    //ToastContext().init(context); //Replace with name and uid of user

    await CometChatUIKit.createUser(user, onSuccess: (User user) async {
      debugPrint("User Created Successfully");
      // Toast.show("User Created Successfully",
      //     duration: Toast.lengthShort, gravity: Toast.bottom);
      await CometChatUIKit.login(user.uid, onSuccess: (User user) {
        Navigator.of(context).pop();
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const Dashboard()));
      });
    }, onError: (CometChatException e) {
      debugPrint("User could not be created");
      // Toast.show("Error in user creation",
      //     duration: Toast.lengthShort, gravity: Toast.bottom);
    });

    // Navigator.of(context).pop();

    //Or u can do it like this
    //User? retUser = await CometChat.createUser(user,  authKey, onSuccess: (_){}, onError: (_){});
  }
}
