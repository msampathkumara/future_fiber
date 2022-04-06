import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:smartwind/C/Server.dart';
import 'package:smartwind/C/form_input_decoration.dart';
import 'package:smartwind/M/AppUser.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/M/hive.dart';
import 'package:smartwind/V/Widgets/ErrorMessageView.dart';
import 'package:smartwind/Web/home_page.dart';
import 'package:video_player/video_player.dart';

import '../../C/FCM.dart';
import '../../M/Section.dart';
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

  String errorMessage = "";

  @override
  initState() {
    super.initState();
    print('-----------------------------------------xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx__login');

    // if (kDebugMode) {
    //   nfcCode = "04f68ad2355e80";
    //   _login();
    // }
    if (!kIsWeb) {
      NfcManager.instance.isAvailable().then((value) {
        nfcIsAvailable = value;
        if (nfcIsAvailable) {
          NfcManager.instance.startSession(
            onDiscovered: (NfcTag tag) async {
              List<int> l = NfcA.from(tag)!.identifier;
              nfcCode = HEX.encode(l);
              _login();
            },
          );
        }
        setState(() {});
      });
      _videoPlayerController = VideoPlayerController.asset("assets/loginVideo.mp4")
        ..initialize().then((_) {
          _videoPlayerController.play();
          _videoPlayerController.setLooping(true);
          setState(() {});
        });
    }

  }

  @override
  void dispose() {
    if (!kIsWeb) {
      _videoPlayerController.dispose();
      NfcManager.instance.stopSession();
    }
    super.dispose();
  }

  var _passwordFocusNode = FocusNode();
  late VideoPlayerController _videoPlayerController;

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
            : Stack(
                children: [
                  if (!kIsWeb)
                    SizedBox.expand(
                        child: FittedBox(
                      clipBehavior: Clip.antiAlias,
                      fit: BoxFit.fill,
                      child: SizedBox(width: _videoPlayerController.value.size.width, height: _videoPlayerController.value.size.height, child: VideoPlayer(_videoPlayerController)),
                    )),
                  Center(
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            color: Colors.white70,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: SizedBox(
                                width: 300,
                                child: Wrap(direction: Axis.horizontal, children: [
                                  Container(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Center(
                                        child: CircleAvatar(
                                          radius: 100,
                                          child: Image.asset("assets/north_sails-logo.png"),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 62,
                                  ),
                                  TextFormField(
                                      autofocus: false,
                                      onFieldSubmitted: (d) {
                                        _passwordFocusNode.requestFocus();
                                      },
                                      style: TextStyle(fontSize: 20, color: Colors.blue),
                                      cursorColor: Colors.blue,
                                      initialValue: _user.uname,
                                      // decoration: FormInputDecoration.getDeco(hintText: 'Enter User Name', prefixIcon: Icon(Icons.account_circle_outlined, color: Colors.lightBlue)),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5.0),
                                          borderSide: BorderSide(
                                            color: Colors.black,
                                          ),
                                        ),
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.only(left: 8.0),
                                          child: new Icon(Icons.account_circle_outlined, color: Colors.blue),
                                        ),
                                        hintText: 'Enter User Name',
                                        hintStyle: TextStyle(color: Colors.blue.shade200),
                                        fillColor: Colors.white,
                                        filled: true,
                                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                      ),
                                      onChanged: (uname) {
                                        _user.uname = uname;
                                      }),
                                  SizedBox(
                                    height: 84,
                                  ),
                                  // Text("Password",
                                  //     style:
                                  //         TextStyle(color: Colors.black, fontSize: 20)),
                                  TextFormField(
                                      focusNode: _passwordFocusNode,
                                      cursorColor: Colors.blue,
                                      onFieldSubmitted: (f) {
                                        _login();
                                      },
                                      style: TextStyle(fontSize: 20, color: Colors.blue),
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
                                            icon: Icon(hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.blue),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                            borderSide: BorderSide(
                                              color: Colors.black,
                                            ),
                                          ),
                                          prefixIcon: Padding(
                                            padding: const EdgeInsets.only(left: 8.0),
                                            child: new Icon(Icons.lock_outlined, color: Colors.blue),
                                          ),
                                          hintText: 'Enter Password',
                                          hintStyle: TextStyle(color: Colors.blue.shade200),
                                          fillColor: Colors.white,
                                          filled: true,
                                          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                          focusedBorder:
                                              OutlineInputBorder(borderSide: const BorderSide(color: Colors.blueAccent, width: 1.0), borderRadius: BorderRadius.circular(5.0)),
                                          enabledBorder:
                                              OutlineInputBorder(borderRadius: BorderRadius.circular(5.0), borderSide: BorderSide(color: Colors.blueGrey.shade50, width: 1.0))),
                                      onChanged: (pword) {
                                        _user.pword = pword;
                                      }),
                                  SizedBox(height: 64),

                                  Text(errorMessage, style: TextStyle(color: Colors.red, fontSize: 20)),
                                  Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: TextButton(onPressed: _recoverPassword, child: Text("Forgot Password ?", style: TextStyle(color: Colors.white))))),

                                  SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                          onPressed: _login, child: Text("Login", style: TextStyle(color: Colors.white, fontSize: 20)), style: FormInputDecoration.buttonStyle())),
                                  SizedBox(
                                      width: double.infinity,
                                      child: TextButton(
                                        onPressed: () async {
                                          await Navigator.push(context, MaterialPageRoute(builder: (context) => const PasswordRecovery()));
                                        },
                                        child: const Text('forgot my password'),
                                        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0), side: const BorderSide(color: Colors.orange)),
                                      )),
                                  if (nfcIsAvailable) SizedBox(height: 84),
                                  if (nfcIsAvailable)
                                    Center(
                                        child: Text(
                                      "  Or ",
                                      style: TextStyle(color: Colors.grey, fontSize: 20),
                                      textAlign: TextAlign.center,
                                    )),
                                  if (nfcIsAvailable) SizedBox(height: 32),
                                  if (nfcIsAvailable) Center(child: Text("Use NFC card to login ", style: TextStyle(color: Colors.black, fontSize: 25)))
                                ])),
                          ))),
                ],
              ));
  }

  _login() {
    print('-----------------------------------------xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx__login__');
    errorMessage = "";
    if (nfcCode.isEmpty && (_user.uname.isEmpty || _user.pword.isEmpty)) {
      errorMessage = "Enter username and password";
      setState(() {});
      return;
    }
    print({"uname": _user.uname, "pword": _user.pword, "nfc": nfcCode});

    setLoading(true);

    Dio dio = new Dio();
    dio.options.headers['content-Type'] = 'application/json';
    print('-----------------------------------------xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx__login__1');
    dio.post(
      Server.getServerPath("user/login"),
      data: {"uname": _user.uname, "pword": _user.pword, "nfc": nfcCode},
    ).then((response) async {
      print('-----------------------------------------xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx__login__2');
      print(response.data);

      Map res = response.data;

      if (res["user"] == null) {
        if (nfcCode.isNotEmpty) {
          ErrorMessageView(errorMessage: "Scan Valid ID Card", icon: Icons.badge_outlined).show(context);
          nfcCode = "";
        }
        errorMessage = "Enter valid username and password";
        setLoading(false);
        return;
      }

      final UserCredential googleUserCredential = await FirebaseAuth.instance.signInWithCustomToken(res["token"]);
      if (googleUserCredential.user != null) {
        if (!kIsWeb) {
          NfcManager.instance.stopSession();
        }
        AppUser.refreshUserData().then((nsUser) async {
          Section section = nsUser.sections.length > 0 ? nsUser.sections[0] : null;
          AppUser.setSelectedSection(section);
          AppUser.setUser(nsUser);
          HiveBox.getDataFromServer();

          if (kIsWeb) {
            await Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => WebHomePage()), (Route<dynamic> route) => false);
          } else {
            FCM.subscribe();
            await Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => CheckTabStatus(nsUser)), (Route<dynamic> route) => false);
          }
          setLoading(false);
        });
      }
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
