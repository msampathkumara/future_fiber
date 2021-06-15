import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nfc_manager/nfc_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartwind/C/DB/DB.dart';
import 'package:smartwind/C/Server.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/V/Home/Home.dart';

import 'PasswordRecovery.dart';

class Login extends StatefulWidget {
  Login() {}

  @override
  _LoginState createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  NsUser _user = new NsUser();
  late bool NfcIsAvailable = false;

  @override
  initState() {
    super.initState();

    NfcManager.instance.isAvailable().then((value) {
      NfcIsAvailable = value;
      if (NfcIsAvailable) {
        NfcManager.instance.startSession(
          onDiscovered: (NfcTag tag) async {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(tag.data.toString()),
            ));
          },
        );
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    NfcManager.instance.stopSession();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Container(
            child: Wrap(
              direction: Axis.horizontal,
              children: [
                if (NfcIsAvailable) Text("Use NFC Card To login "),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'User Name'),
                    onChanged: (uname) {
                      _user.uname = uname;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Enter your username'),
                    onChanged: (pword) {
                      _user.pword = pword;
                    },
                  ),
                ),
                Center(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(onPressed: _login, child: Text("Login")),
                )),
                Center(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(onPressed: _recoverPassword, child: Text("Forgot Password")),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _login() {
    // Todo login
    print('ddddddddddddddddddddddddddddd');
    http
        .post(
      Uri.parse(Server.getServerPath("users/login")),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({"uname": _user.uname, "pword": _user.pword}),
    )
        .then((response) async {
      print(response.body);
      Map res = (json.decode(response.body) as Map);

      NsUser nsUser = NsUser.fromJson(res["user"]);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("user", json.encode(nsUser));
      print("saving user to SharedPreferences");
      print(json.encode(nsUser));

      final UserCredential googleUserCredential = await FirebaseAuth.instance.signInWithCustomToken(res["token"]);
      if (googleUserCredential.user != null) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Home()), (Route<dynamic> route) => false);
        DB.updateDatabase();
      }
    }).onError((error, stackTrace) {
      print(error);
    });

    // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Home()), (Route<dynamic> route) => false);
    // DB.updateDatabase();
  }

  _recoverPassword() {
    // Todo recoverPassword

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PasswordRecovery()),
    );
  }
}
