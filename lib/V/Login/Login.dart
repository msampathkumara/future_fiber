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
import 'package:smartwind/V/Login/SectionSelector.dart';

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

  bool loading = false;

  var hidePassword = true;

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

  var _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: loading
          ? Center(
              child: Container(
                  child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [CircularProgressIndicator(), Padding(padding: const EdgeInsets.all(16.0), child: Text("Loading", textScaleFactor: 1))],
            )))
          : Center(
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
                              initialValue: _user.uname,
                              decoration: InputDecoration(labelText: 'User Name'),
                              onChanged: (uname) {
                                _user.uname = uname;
                              })),
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                              decoration: InputDecoration(
                                  labelText: 'Enter Password',
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        hidePassword = !hidePassword;
                                      });
                                    },
                                    icon: Icon(hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                  )),
                              obscureText: hidePassword,
                              enableSuggestions: false,
                              autocorrect: false,
                              controller: _controller,
                              onChanged: (pword) {
                                _user.pword = pword;
                              })),
                      Center(child: Padding(padding: const EdgeInsets.all(8.0), child: ElevatedButton(onPressed: _login, child: Text("Login")))),
                      Center(child: Padding(padding: const EdgeInsets.all(8.0), child: TextButton(onPressed: _recoverPassword, child: Text("Forgot Password")))),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  _login() {
    // Todo login

    setLoading(true);
    http
        .post(
      Uri.parse(Server.getServerPath("user/login")),
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
      nsUser.section = nsUser.sections.length > 0 ? nsUser.sections[0] : null;
      await prefs.setString("user", json.encode(nsUser));

      print("saving user to SharedPreferences");
      print(json.encode(nsUser));

      final UserCredential googleUserCredential = await FirebaseAuth.instance.signInWithCustomToken(res["token"]);
      if (googleUserCredential.user != null) {
        if (nsUser.sections.length > 1) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SectionSelector(nsUser)), (Route<dynamic> route) => false);
        } else {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Home()), (Route<dynamic> route) => false);
        }
        DB.updateDatabase();
      }
      setLoading(false);
    }).onError((error, stackTrace) {
      print(error);
      setLoading(false);
    });
  }

  _recoverPassword() {
    // Todo recoverPassword

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PasswordRecovery()),
    );
  }

  void setLoading(bool show) {
    setState(() {
      loading = show;
    });
  }
}
