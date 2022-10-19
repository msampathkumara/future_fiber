import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'BlueBookCredentials.dart';

class BlurBookLogin extends StatefulWidget {
  const BlurBookLogin({Key? key}) : super(key: key);

  @override
  _BlurBookLoginState createState() => _BlurBookLoginState();

  static Future<BlueBookCredentials?> getBlueBookCredentials() async {
    var prefs = await SharedPreferences.getInstance();
    String? u = prefs.getString("BlueBookCredentials");
    if (u != null) {
      return BlueBookCredentials.fromJson(jsonDecode(u));
    }
    return null;
  }
}

class _BlurBookLoginState extends State<BlurBookLogin> {
  BlueBookCredentials blueBookCredentials = BlueBookCredentials();

  TextEditingController unameController = TextEditingController();
  TextEditingController pwordController = TextEditingController();

  @override
  initState() {
    super.initState();
    BlurBookLogin.getBlueBookCredentials().then((value) {
      if (value != null) {
        print('xxxxxxxxxxxx ${value.userName}');
        setState(() {
          blueBookCredentials = value;
          unameController.text = blueBookCredentials.userName;
          pwordController.text = blueBookCredentials.userName;
        });
      }
    });
    unameController.text = blueBookCredentials.userName;
    pwordController.text = blueBookCredentials.userName;
  }

  bool hidePassword = true;
  final _passwordFocusNode = FocusNode();

  String errorMsg = "";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Wrap(children: [
        const Center(
            child: Text(
          "User Login",
          textScaleFactor: 1.2,
        )),
        const SizedBox(height: 60),
        TextFormField(
            controller: unameController,
            autofocus: true,
            onFieldSubmitted: (d) {
              _passwordFocusNode.requestFocus();
            },
            style: const TextStyle(fontSize: 20, color: Colors.blue),
            cursorColor: Colors.blue,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: const BorderSide(
                    color: Colors.black,
                  ),
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.account_circle_outlined),
                ),
                hintText: 'Enter User Name',
                hintStyle: const TextStyle(color: Colors.grey),
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.blueAccent, width: 1.0), borderRadius: BorderRadius.circular(5.0)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0), borderSide: BorderSide(color: Colors.blueGrey.shade50, width: 1.0))),
            onChanged: (uname) {
              blueBookCredentials.userName = uname;
            }),
        const SizedBox(height: 60),
        TextFormField(
            controller: pwordController,
            focusNode: _passwordFocusNode,
            cursorColor: Colors.blue,
            onFieldSubmitted: (f) {
              _login();
            },
            style: const TextStyle(fontSize: 20, color: Colors.blue),
            obscureText: hidePassword,
            onChanged: (t) {
              blueBookCredentials.password = t;
            },
            decoration: InputDecoration(
                suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },
                    icon: Icon(hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey)),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.lock_outlined),
                ),
                hintText: 'Enter Password',
                hintStyle: const TextStyle(color: Colors.grey),
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.blueAccent, width: 1.0), borderRadius: BorderRadius.circular(5.0)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0), borderSide: BorderSide(color: Colors.blueGrey.shade50, width: 1.0)))),
        const SizedBox(height: 64),
        Text(errorMsg, style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 32),
        Align(
          alignment: Alignment.bottomRight,
          child: Wrap(
            children: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel")),
              const SizedBox(width: 8),
              ElevatedButton(
                  onPressed: () {
                    _login();
                  },
                  child: const Text("Login"))
            ],
          ),
        )
      ]),
    );
  }

  void _login() {
    errorMsg = "";

    if ((blueBookCredentials.userName).trim().isEmpty) {
      errorMsg = "Enter UserName";
      setState(() {});
      return;
    } else if ((blueBookCredentials.password).trim().isEmpty) {
      errorMsg = "Enter Password";
      setState(() {});
      return;
    }
    print('ddddddddddd');
    setBlueBookCredentials(blueBookCredentials);
    Navigator.pop(context, blueBookCredentials);
  }

  static Future setBlueBookCredentials(blueBookCredentials) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString("BlueBookCredentials", jsonEncode(blueBookCredentials));
  }
}
