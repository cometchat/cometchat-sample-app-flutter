import 'package:cometchat/cometchat_sdk.dart';
import 'package:flutter/material.dart';

import '../../Utils/custom_toast.dart';
import '../../Utils/loading_indicator.dart';
import '../../constants.dart';

class UpdateUser extends StatefulWidget {
  const UpdateUser(
      {Key? key, required this.user, required this.updateLoggedInUser})
      : super(key: key);
  final User user;
  final bool updateLoggedInUser;

  @override
  _UpdateUserState createState() => _UpdateUserState();
}

class _UpdateUserState extends State<UpdateUser> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController uidTextController = TextEditingController();
  TextEditingController nameTextController = TextEditingController();
  TextEditingController avatarTextController = TextEditingController();
  TextEditingController linkTextController = TextEditingController();
  TextEditingController roleTextController = TextEditingController();
  TextEditingController statusMessageTextController = TextEditingController();
  late User? user;

  @override
  void initState() {
    super.initState();

    uidTextController.text = widget.user.uid;
    nameTextController.text = widget.user.name;
    avatarTextController.text = widget.user.avatar ?? '';
    linkTextController.text = widget.user.link ?? '';
    roleTextController.text = widget.user.role ?? '';
    statusMessageTextController.text = widget.user.statusMessage ?? '';
  }

  //-----updating logged in user-----
  updateLoggedInUser() async {
    showLoadingIndicatorDialog(context);
    User user = User(
        name: nameTextController.text,
        avatar: avatarTextController.text,
        link: linkTextController.text,
        role: roleTextController.text,
        statusMessage: statusMessageTextController.text);

    await CometChat.updateCurrentUserDetails(user,
        onSuccess: (User updatedUser) {
      debugPrint("Updated User: $updatedUser");
      showCustomToast(msg: 'Updated Successfully');
    }, onError: (CometChatException e) {
      debugPrint("Updated User exception : ${e.message}");
      showCustomToast(
          msg: 'Something went wrong', background: Colors.redAccent);
    });
    Navigator.pop(context);
  }

  //----updating any users using api key----
  updateUser() async {
    showLoadingIndicatorDialog(context);
    User user = User(
        uid: widget.user.uid,
        name: nameTextController.text,
        avatar: avatarTextController.text,
        link: linkTextController.text,
        role: roleTextController.text,
        statusMessage: statusMessageTextController.text);

    String apiKey = CometChatAuthConstants.apiKey;

    await CometChat.updateUser(user, apiKey, onSuccess: (User updatedUser) {
      debugPrint("Updated User: $updatedUser");
      showCustomToast(msg: 'Updated Successfully');
    }, onError: (CometChatException e) {
      debugPrint("Updated User exception : ${e.message}");
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update User")),
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
                  readOnly: true,
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
                      if (widget.updateLoggedInUser) {
                        updateLoggedInUser();
                      } else {
                        updateUser();
                      }
                    }
                  },
                  child: const Text("Update")),
            ],
          ),
        ),
      ),
    );
  }
}
