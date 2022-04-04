import 'package:cometchat/cometchat_sdk.dart';
import 'package:flutter/material.dart';

import '../../Utils/custom_toast.dart';
import '../../Utils/loading_indicator.dart';
import '../../constants.dart';

class CreateUser extends StatefulWidget {
  const CreateUser({Key? key}) : super(key: key);

  @override
  _CreateUserState createState() => _CreateUserState();
}

class _CreateUserState extends State<CreateUser> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController uidTextController = TextEditingController();
  TextEditingController nameTextController = TextEditingController();
  TextEditingController avatarTextController = TextEditingController();
  TextEditingController linkTextController = TextEditingController();
  TextEditingController roleTextController = TextEditingController();
  TextEditingController statusMessageTextController = TextEditingController();

  createUser() async {
    showLoadingIndicatorDialog(context);

    String authKey = CometChatAuthConstants.authKey;

    User user = User(
      uid: uidTextController.text,
      name: nameTextController.text,
      // avatar: avatarTextController.text,
      // link: linkTextController.text,
      // role: roleTextController.text,
      // statusMessage: statusMessageTextController.text
    );

    await CometChat.createUser(user, authKey, onSuccess: (User user) {
      debugPrint("Create User successful $user");
      showCustomToast(msg: 'User Created Successfully');
    }, onError: (CometChatException e) {
      debugPrint("Create User Failed with exception ${e.message}");
      showCustomToast(msg: 'Something went Wrong');
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create User")),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  controller: uidTextController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'UID',
                    hintText: 'UID: A unique identifier of the User',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  controller: nameTextController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Name',
                    hintText: 'Display name of the user',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  controller: avatarTextController,
                  validator: (value) {
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Avatar',
                    hintText: 'URL to profile picture of the user',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  controller: linkTextController,
                  validator: (value) {
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Link',
                    hintText: 'URL to profile page',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  controller: roleTextController,
                  validator: (value) {
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Role',
                    hintText:
                        'User role of the user for role based access control',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  controller: statusMessageTextController,
                  validator: (value) {
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'statusMessage',
                    hintText:
                        'Any custom status message that needs to be set for a user',
                  ),
                ),
              ),
              MaterialButton(
                  color: Colors.blue,
                  minWidth: 200,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      createUser();
                    }
                  },
                  child: const Text("Create")),
            ],
          ),
        ),
      ),
    );
  }
}
