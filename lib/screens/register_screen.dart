import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RegisterScreenState();
  }
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isValidUsername(String? username) {
    RegExp validCharacters = RegExp(r'^[a-zA-Z0-9_]+$');
    if (username == null) {
      return false;
    }
    return username.length >= 4 &&
        username.length <= 20 &&
        validCharacters.hasMatch(username);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
