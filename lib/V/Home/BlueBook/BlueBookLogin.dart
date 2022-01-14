import 'dart:convert';

import 'package:flutter/cupertino.dart';
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
  BlueBookCredentials blueBookCredentials = new BlueBookCredentials();

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
  var _passwordFocusNode = FocusNode();
  var _unameFocusNode = FocusNode();

  String errorMsg = "";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
          child: Wrap(children: [
        Center(
            child: Text(
          "User Login",
          textScaleFactor: 1.2,
        )),
        SizedBox(height: 60),
        TextFormField(
            controller: unameController,
            autofocus: true,
            onFieldSubmitted: (d) {
              _passwordFocusNode.requestFocus();
            },
            style: TextStyle(fontSize: 20, color: Colors.blue),
            cursorColor: Colors.blue,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: new Icon(Icons.account_circle_outlined),
                ),
                hintText: 'Enter User Name',
                hintStyle: TextStyle(color: Colors.grey),
                fillColor: Colors.white,
                filled: true,
                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.blueAccent, width: 1.0), borderRadius: BorderRadius.circular(5.0)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0), borderSide: BorderSide(color: Colors.blueGrey.shade50, width: 1.0))),
            onChanged: (uname) {
              blueBookCredentials.userName = uname;
            }),
        SizedBox(height: 60),
        TextFormField(
            controller: pwordController,
            focusNode: _passwordFocusNode,
            cursorColor: Colors.blue,
            onFieldSubmitted: (f) {
              _login();
            },
            style: TextStyle(fontSize: 20, color: Colors.blue),
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
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: new Icon(Icons.lock_outlined),
                ),
                hintText: 'Enter Password',
                hintStyle: TextStyle(color: Colors.grey),
                fillColor: Colors.white,
                filled: true,
                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.blueAccent, width: 1.0), borderRadius: BorderRadius.circular(5.0)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0), borderSide: BorderSide(color: Colors.blueGrey.shade50, width: 1.0)))),
        SizedBox(height: 64),
        Text(errorMsg, style: TextStyle(color: Colors.red)),
        SizedBox(height: 32),
        Align(
          alignment: Alignment.bottomRight,
          child: Wrap(
            children: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel")),
              SizedBox(width: 8),
              ElevatedButton(
                  onPressed: () {
                    _login();
                  },
                  child: Text("Login"))
            ],
          ),
        )
      ])),
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
