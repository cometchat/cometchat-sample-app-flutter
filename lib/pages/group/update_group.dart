import 'package:cometchat/cometchat_sdk.dart';
import 'package:flutter/material.dart';

class UpdateGroup extends StatefulWidget {
  const UpdateGroup({Key? key, required this.group}) : super(key: key);
  final Group group;

  @override
  _UpdateGroupState createState() => _UpdateGroupState();
}

class _UpdateGroupState extends State<UpdateGroup> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController guidTextController = TextEditingController();
  TextEditingController nameTextController = TextEditingController();
  TextEditingController iconTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();
  String? groupType = "public";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    guidTextController.text = widget.group.guid;
    nameTextController.text = widget.group.name;
    iconTextController.text = widget.group.icon;
    groupType = widget.group.type;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Group"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  controller: guidTextController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'GUID',
                    hintText: 'GUID: A unique identifier for a group',
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
                    hintText: 'Name: Name of the group',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  controller: iconTextController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Icon',
                    hintText: 'Icon: An URL to group icon',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Group Type',
                    hintText: 'Group Type',
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: groupType,
                      items:
                          ["public", "private", "password"].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? val) {
                        groupType = val;
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ),
              if (groupType == CometChatGroupType.password)
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: TextFormField(
                    controller: passwordTextController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      hintText: 'Group Password',
                    ),
                  ),
                ),
              MaterialButton(
                  color: Colors.blue,
                  minWidth: 200,
                  height: 40,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      String _GUID = guidTextController.text;
                      String _groupName = nameTextController.text;
                      String _groupType =
                          groupType ?? CometChatGroupType.public;
                      String _password = passwordTextController.text;

                      setState(() {
                        isLoading = true;
                      });
                      Group? group = await CometChat.updateGroup(
                          guid: _GUID,
                          groupName: _groupName,
                          groupType: _groupType,
                          password: _password,
                          onSuccess: (Group group) {},
                          onError: (CometChatException excep) {});
                      setState(() {
                        isLoading = false;
                      });

                      if (group == null) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Something Went Wrong"),
                        ));
                      }
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Group Updated"),
                      ));
                    }
                  },
                  child: const Text("Update")),
              const SizedBox(
                height: 10,
              ),
              if (isLoading) const CircularProgressIndicator()
            ],
          ),
        ),
      ),
    );
  }
}
