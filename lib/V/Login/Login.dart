import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartwind/C/Server.dart';
import 'package:smartwind/M/AppUser.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/V/Home/Home.dart';
import 'package:smartwind/V/Login/SectionSelector.dart';
import 'package:smartwind/V/Widgets/ErrorMessageView.dart';

import 'CheckTabStatus.dart';
import 'PasswordRecovery.dart';

class Login extends StatefulWidget {
  static var appUser;

  Login();

  @override
  _LoginState createState() {
    appUser = AppUser();
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  NsUser _user = new NsUser();
  late bool nfcIsAvailable = false;

  bool loading = false;

  var hidePassword = true;

  bool emptyUserDetails = false;
  String nfcCode = "";

  @override
  initState() {
    super.initState();

    NfcManager.instance.isAvailable().then((value) {
      nfcIsAvailable = value;
      if (nfcIsAvailable) {
        NfcManager.instance.startSession(
          onDiscovered: (NfcTag tag) async {
            // print(Ndef.from(tag)!.cachedMessage!.records ?? "");
            // print(new String.fromCharCodes(NfcA.from(tag)!.identifier));
            // List<int> l = tag.data["nfca"]["identifier"];
            List<int> l = NfcA.from(tag)!.identifier;
            // ErrorMessageView(errorMessage: HEX.encode(l)).show(context);

            // new String.fromCharCodes(charCodes)
            // String serial=new String.fromCharCodes( NfcA.from(tag)!.identifier);
            // ErrorMessageView(errorMessage: serial).show(context);
            nfcCode = HEX.encode(l);
            _login();

            // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            //   content: Text(tag.data.toString()),
            // ));
          },
        );
      }
    });

    nfcCode = "04f68ad2355e80";
    _login();
  }

  @override
  void dispose() {
    super.dispose();
    NfcManager.instance.stopSession();
  }

  var _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {

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
                      if (nfcIsAvailable) Text("Use NFC Card To login "),
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
                      if (emptyUserDetails) Text("Enter user name and password", style: TextStyle(color: Colors.red)),
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
    if (nfcCode.isEmpty && (_user.uname.isEmpty || _user.pword.isEmpty)) {
      emptyUserDetails = true;
      return;
    }
    print({"uname": _user.uname, "pword": _user.pword, "nfc": nfcCode});

    setLoading(true);

    Dio dio = new Dio();
    dio.options.headers['content-Type'] = 'application/json';

    dio.post(
      Server.getServerPath("user/login"),
      data: {"uname": _user.uname, "pword": _user.pword, "nfc": nfcCode},
    ).then((response) async {
      print(response.data);
      Map res = response.data;

      if (res["user"] == null) {
        if (nfcCode.isNotEmpty) {
          ErrorMessageView(errorMessage: "Scan Valid ID Card", icon: Icons.badge_outlined).show(context);
          nfcCode = "";
        }
        // emptyUserDetails = true;
        setLoading(false);
        return;
      }

      Map<String, dynamic> payload = Jwt.parseJwt(res["user"]);
      print(payload);

      NsUser nsUser = NsUser.fromJson(payload);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      nsUser.section = nsUser.sections.length > 0 ? nsUser.sections[0] : null;
      await prefs.setString("user", json.encode(nsUser));

      print("saving user to SharedPreferences");
      print(json.encode(nsUser));

      final UserCredential googleUserCredential = await FirebaseAuth.instance.signInWithCustomToken(res["token"]);
      if (googleUserCredential.user != null) {
        if (nsUser.sections.length > 1) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => CheckTabStatus(nsUser)), (Route<dynamic> route) => false);
        } else {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Home()), (Route<dynamic> route) => false);
        }
        NfcManager.instance.stopSession();
      }
      setLoading(false);
    }).onError((error, stackTrace) {
      nfcCode = "";
      print(stackTrace.toString());
      ErrorMessageView(errorMessage: error.toString()).show(context);
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
