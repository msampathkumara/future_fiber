import 'dart:convert';
import 'dart:ui';

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
            List<int> l = NfcA.from(tag)!.identifier;
            nfcCode = HEX.encode(l);
            _login();

            // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            //   content: Text(tag.data.toString()),
            // ));
          },
        );
      }
    });

    // nfcCode = "04f68ad2355e80";
    // _login();
  }

  @override
  void dispose() {
    super.dispose();
    NfcManager.instance.stopSession();
  }

  var _controller = TextEditingController();
  var _passwordFocusNode = FocusNode();
  var _unameFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff01c1fe),
      body: loading
          ? Center(
              child: Container(
                  child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [CircularProgressIndicator(), Padding(padding: const EdgeInsets.all(16.0), child: Text("Loading", textScaleFactor: 1))],
            )))
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment(2.0, 0.0),
                  colors: <Color>[Color(0xff1981d2), Color(0xff40aee5), Color(0xff1981d2)],
                  tileMode: TileMode.clamp,
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Container(
                    child: Wrap(
                      direction: Axis.horizontal,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                            child: CircleAvatar(
                              radius: 100,
                              child: Image.asset("assets/north_sails-logo.png"),
                            ),
                          ),
                        ),
                        Text("User Name", style: TextStyle(color: Colors.white, fontSize: 20)),
                        Material(
                          borderRadius: BorderRadius.circular(5.0),
                          elevation: 10.0,
                          shadowColor: Color(0xff224597),
                          color: Colors.blue,
                          child: TextFormField(
                              autofocus: true,
                              onFieldSubmitted: (d) {
                                _passwordFocusNode.requestFocus();
                              },
                              style: TextStyle(fontSize: 20, color: Colors.white),
                              cursorColor: Colors.white,
                              initialValue: _user.uname,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                    ),
                                  ),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: new Icon(Icons.account_circle_outlined, color: Colors.white),
                                  ),
                                  hintText: 'Enter User Name',
                                  hintStyle: TextStyle(color: Colors.white60),
                                  fillColor: Colors.blue,
                                  filled: true,
                                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white60, width: 2.0), borderRadius: BorderRadius.circular(5.0)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0), borderSide: BorderSide(color: Colors.blue, width: 3.0))),
                              onChanged: (uname) {
                                _user.uname = uname;
                              }),
                        ),
                        SizedBox(
                          height: 62,
                        ),
                        Text("Password", style: TextStyle(color: Colors.white, fontSize: 20)),
                        Material(
                          borderRadius: BorderRadius.circular(5.0),
                          elevation: 10.0,
                          shadowColor: Color(0xff224597),
                          color: Colors.white,
                          child: TextFormField(
                              focusNode: _passwordFocusNode,
                              cursorColor: Colors.white,
                              onFieldSubmitted: (f) {
                                _login();
                              },
                              style: TextStyle(fontSize: 20, color: Colors.white),
                              initialValue: _user.pword,
                              obscureText: hidePassword,
                              autofocus: false,
                              decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        hidePassword = !hidePassword;
                                      });
                                    },
                                    icon: Icon(hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                    ),
                                  ),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: new Icon(Icons.lock_outlined, color: Colors.white),
                                  ),
                                  hintText: 'Enter Password',
                                  hintStyle: TextStyle(color: Colors.white60),
                                  fillColor: Colors.blue,
                                  filled: true,
                                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white60, width: 2.0), borderRadius: BorderRadius.circular(5.0)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0), borderSide: BorderSide(color: Colors.blue, width: 3.0))),
                              onChanged: (pword) {
                                _user.pword = pword;
                              }),
                        ),
                        Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: TextButton(onPressed: _recoverPassword, child: Text("Forgot Password ?", style: TextStyle(color: Colors.white))))),
                        SizedBox(
                          height: 62,
                        ),
                        if (emptyUserDetails) Text("Enter user name and password", style: TextStyle(color: Colors.red)),
                        SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _login,
                              child: Text("Login", style: TextStyle(color: Colors.blue, fontSize: 20)),
                              style: ButtonStyle(
                                  elevation: MaterialStateProperty.all(10),
                                  backgroundColor: MaterialStateProperty.all(Colors.white),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0), side: BorderSide(color: Colors.blue)))),
                            )),
                        if (nfcIsAvailable) SizedBox(height: 84),
                        if (nfcIsAvailable)
                          Center(
                              child: Text(
                            " ~~~~~~~~~~~~~ Or ~~~~~~~~~~~~~~~ ",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          )),
                        if (nfcIsAvailable) SizedBox(height: 32),
                        if (nfcIsAvailable) Center(child: Text("Use NFC card to login ", style: TextStyle(color: Colors.white, fontSize: 25))),
                      ],
                    ),
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
        // if (nsUser.sections.length > 1) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => CheckTabStatus(nsUser)), (Route<dynamic> route) => false);
        // } else {
        //   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Home()), (Route<dynamic> route) => false);
        // }
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
