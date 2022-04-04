import 'package:cometchat/cometchat_sdk.dart';
import 'package:flutter/material.dart';
import 'package:sdk_tutorial/constants.dart';
import 'package:sdk_tutorial/pages/login.dart';

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
              Wrap(
                children: const [
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Padding(
                          padding: EdgeInsets.fromLTRB(2.0, 20.0, 0, 10.0),
                          child: Text(
                            'UID',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        SizedBox()
                      ],
                    ),
                    TextFormField(
                      cursorColor: Colors.grey,
                      onSaved: (val) => uid = val,
                      validator: (String? arg) {
                        if (arg == null) {
                          return 'User ID must not be Blank';
                        } else if (arg.trim() == "") {
                          return 'User ID must not be Blank';
                        }
                        return null;
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Padding(
                          padding: EdgeInsets.fromLTRB(2.0, 20.0, 0, 10.0),
                          child: Text(
                            'Name',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        SizedBox()
                      ],
                    ),
                    TextFormField(
                      cursorColor: Colors.grey,
                      onSaved: (val) => name = val,
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
                            registerUser();
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
  registerUser() async {
    String authKey =
        CometChatAuthConstants.authKey; //Replace with the auth key of app
    User user =
        User(uid: uid!, name: name!); //Replace with name and uid of user

    CometChat.createUser(user, authKey, onSuccess: (User user) {
      debugPrint("User Created Successfully");
    }, onError: (CometChatException e) {
      debugPrint("Create User Failed with exception ${e.message}");
    });

    //Or u can do it like this
    //User? retUser = await CometChat.createUser(user,  authKey, onSuccess: (_){}, onError: (_){});
  }
}
