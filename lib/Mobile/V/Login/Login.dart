import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smartwind_future_fibers/C/Server.dart';
import 'package:smartwind_future_fibers/C/form_input_decoration.dart';
import 'package:smartwind_future_fibers/M/AppUser.dart';
import 'package:smartwind_future_fibers/M/EndPoints.dart';
import 'package:smartwind_future_fibers/M/NsUser.dart';
import 'package:smartwind_future_fibers/Mobile/V/Widgets/ErrorMessageView.dart';
import 'package:smartwind_future_fibers/res.dart';
import 'package:video_player/video_player.dart';

import '../../../C/DB/hive.dart';
import '../../../C/FCM.dart';
import '../../../M/Section.dart';
import 'CheckTabStatus.dart';
import 'PasswordRecovery.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  final NsUser _user = NsUser();
  late bool nfcIsAvailable = false;

  bool loading = false;

  var hidePassword = true;

  bool emptyUserDetails = false;
  String nfcCode = "";

  String errorMessage = "";

  String appVersion = "";

  bool visiblePassword = false;

  StreamSubscription<DatabaseEvent>? userPermissionsUponListener;
  var appFlavor = const String.fromEnvironment("flavor");

  @override
  initState() {
    super.initState();

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
      _videoPlayerController = VideoPlayerController.asset(Res.loginVideo)
        ..initialize().then((_) {
          _videoPlayerController.play();
          _videoPlayerController.setLooping(true);
          setState(() {});
        });
    } else {
      // Future(() {
      if (AppUser.isLogged) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
      }
      // });
    }
    print('-----------------------------------------xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx__login');
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      String version = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;
      setState(() {
        appVersion = "$version.$buildNumber";
      });
    });
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      _videoPlayerController.dispose();
      NfcManager.instance.stopSession();
    }
    super.dispose();
  }

  final _passwordFocusNode = FocusNode();
  late VideoPlayerController _videoPlayerController;

  @override
  Widget build(BuildContext context) {
    // return Text("${Firebase.apps.length}555555555555555555555555555555555${FirebaseAuth.instance.currentUser}");

    return Scaffold(
        backgroundColor: Colors.white,
        body: loading
            ? Center(
                child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [CircularProgressIndicator(), Padding(padding: EdgeInsets.all(16.0), child: Text("Loading", textScaleFactor: 1))],
              ))
            : kIsWeb
                ? getWebUi()
                : getMobileUi());
  }

  Future<void> _login() async {
    errorMessage = "";
    if (nfcCode.isEmpty && (_user.uname.isEmpty || _user.pword.isEmpty)) {
      errorMessage = "Enter username and password";
      setState(() {});
      return;
    }

    setLoading(true);

    Dio dio = Dio();
    dio.options.headers['content-Type'] = 'application/json';
    dio.post(await Server.getServerPath(EndPoints.user_login), data: {"uname": _user.uname, "pword": _user.pword, "nfc": nfcCode}).then((response) async {
      Map res = response.data;

      if (res["locked"] == true) {
        showAccountLockedAlertDialog(context);
        setLoading(false);
      }
      if (res["login"] == false) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login failed, Check user name and password"), backgroundColor: Colors.red));
        setLoading(false);
        return;
      } else if (res["deactivate"] != null) {
        setLoading(false);
        return showAccountDeactivatedAlertDialog(context);
      } else if (res["token"] == null) {
        if (nfcCode.isNotEmpty) {
          const ErrorMessageView(errorMessage: "Scan Valid ID Card", icon: Icons.badge_outlined).show(context);
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
        } else {
          if (userPermissionsUponListener != null) {
            userPermissionsUponListener?.cancel();
          }
        }

        AppUser.refreshUserData().then((nsUser) async {
          Section? section = nsUser.sections.length > 0 ? nsUser.sections[0] : null;
          if (section != null) {
            AppUser.setSelectedSection(section);
          }
          await HiveBox.getUserConfig();
          print('login__________________________________________________________________________________________getDataFromServer before');
          // AppUser.setUser(nsUser);
          // await HiveBox.getDataFromServer();
          print('login__________________________________________________________________________________________getDataFromServer');
          await HiveBox.getUserConfig();
          print('login__________________________________________________________________________________________');

          if (kIsWeb) {
            // await Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => WebHomePage()), (Route<dynamic> route) => false);
            if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
          } else {
            FCM.subscribe();
            if (mounted) await Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => CheckTabStatus(nsUser)), (Route<dynamic> route) => false);
          }
          setLoading(false);
        });
      }
    }).onError((error, stackTrace) {
      nfcCode = "";
      var e = error as DioError;
      var errmsg = '';
      if (e.type == DioErrorType.receiveTimeout) {
        print('catched');
      } else if (e.type == DioErrorType.connectionTimeout) {
        print('check your connection');
        errmsg = 'check your connection';
      } else if (e.type == DioErrorType.receiveTimeout) {
        print('unable to connect to the server');
        errmsg = 'unable to connect to the server';
      } else {
        print('Something went wrong');
        errmsg = 'Something went wrong';
      }
      print(e);

      // print(stackTrace.toString());
      ErrorMessageView(errorMessage: errmsg, errorDescription: e.message.toString()).show(context);
      setLoading(false);
    });
  }

  void setLoading(bool show) {
    setState(() {
      loading = show;
    });
  }

  Stack getWebUi() {
    return Stack(children: [
      if (kIsWeb) SizedBox.expand(child: FittedBox(fit: BoxFit.cover, child: Image.asset(Res.background))),
      if (!loading) Center(child: _body()),
      if (loading) ConstrainedBox(constraints: const BoxConstraints.expand(), child: Container(color: Colors.black54, child: const Center(child: CircularProgressIndicator()))),
      Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Chip(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  padding: const EdgeInsets.all(8.0),
                  label: Text("SmartWind for Future Fibers $appVersion v",
                      style: const TextStyle(color: Colors.white, shadows: <Shadow>[Shadow(offset: Offset(0.0, 0.0), blurRadius: 10.0, color: Colors.black)])))))
    ]);
  }

  final _formKey = GlobalKey<FormState>();

  Column _body() {
    // Build a Form widget using the _formKey created above.
    return Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 64.0),
            child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white.withAlpha(230)),
                child: Padding(
                  padding: const EdgeInsets.only(top: 76, bottom: 16.0, left: 16, right: 16),
                  child: SizedBox(
                    width: 300,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: TextFormField(
                                initialValue: _user.uname,
                                onChanged: (text) {
                                  _user.uname = text;
                                },
                                autofocus: false,
                                style: const TextStyle(fontSize: 15.0, color: Colors.black),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Username',
                                  filled: true,
                                  fillColor: Colors.grey.shade300,
                                  contentPadding: const EdgeInsets.only(left: 14.0, bottom: 6.0, top: 8.0),
                                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(10.0)),
                                  enabledBorder: UnderlineInputBorder(borderSide: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(10.0)),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter user name';
                                  }
                                  return null;
                                }),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Stack(
                              alignment: const Alignment(0, 0),
                              children: <Widget>[
                                TextFormField(
                                    initialValue: _user.password,
                                    onChanged: (text) {
                                      _user.pword = text;
                                    },
                                    onFieldSubmitted: (text) {
                                      _user.pword = text;
                                      if (_formKey.currentState!.validate()) {
                                        _login();
                                      }
                                    },
                                    obscureText: !visiblePassword,
                                    autofocus: false,
                                    style: const TextStyle(fontSize: 15.0, color: Colors.black),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'password',
                                      filled: true,
                                      fillColor: Colors.grey.shade300,
                                      contentPadding: const EdgeInsets.only(left: 14.0, bottom: 6.0, top: 8.0),
                                      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(10.0)),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter password';
                                      }
                                      return null;
                                    }),
                                Positioned(
                                    right: 15,
                                    child: SizedBox(
                                        child: IconButton(
                                            onPressed: () {
                                              visiblePassword = !visiblePassword;
                                              setState(() {});
                                            },
                                            icon: Icon(visiblePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded))))
                              ],
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.all(10),
                              child: SizedBox(
                                  height: 50,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: FormInputDecoration.buttonStyle(),

                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        _login();
                                      }
                                    },
                                    child: const Text(
                                      'Login',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0), side: const BorderSide(color: Colors.orange)),
                                  ))),
                          SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                onPressed: () async {
                                  print('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
                                  // await Navigator.push(context, MaterialPageRoute(builder: (context) => const PasswordRecovery()));
                                  await const PasswordRecovery().show(context);
                                },
                                child: const Text('forgot my password'),
                                // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0), side: const BorderSide(color: Colors.orange)),
                              ))
                        ],
                      ),
                    ),
                  ),
                )),
          ),
          Positioned(
              top: 0,
              child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black, spreadRadius: 1)],
                  ),
                  width: 128,
                  height: 128,
                  child: CircleAvatar(radius: 360, child: ClipRRect(borderRadius: const BorderRadius.all(Radius.circular(360)), child: Image.asset(Res.smartwindlogo150)))))
        ],
      )
    ]);
  }

  Stack getMobileUi() {
    return Stack(
      children: [
        if (kIsWeb)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage(Res.background), fit: BoxFit.cover),
            ),
            child: null /* add child content here */,
          ),
        if (!kIsWeb)
          SizedBox.expand(
              child: FittedBox(
                  clipBehavior: Clip.antiAlias,
                  fit: BoxFit.fill,
                  child: SizedBox(width: _videoPlayerController.value.size.width, height: _videoPlayerController.value.size.height, child: VideoPlayer(_videoPlayerController)))),
        Center(
            child: SizedBox(
          height: 600,
          width: 400,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 150,
                child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      color: Colors.white70,
                    ),
                    child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 64.0),
                          child: SizedBox(
                              width: 300,
                              child: Wrap(direction: Axis.horizontal, children: [
                                const SizedBox(height: 62),
                                TextFormField(
                                    autofocus: false,
                                    onFieldSubmitted: (d) {
                                      _passwordFocusNode.requestFocus();
                                    },
                                    style: const TextStyle(fontSize: 20, color: Colors.blue),
                                    cursorColor: Colors.blue,
                                    initialValue: _user.uname,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0), borderSide: const BorderSide(color: Colors.black)),
                                        prefixIcon: const Padding(padding: EdgeInsets.only(left: 8.0), child: Icon(Icons.account_circle_outlined, color: Colors.blue)),
                                        hintText: 'User Name',
                                        hintStyle: TextStyle(color: Colors.blue.shade200),
                                        fillColor: Colors.white,
                                        filled: true,
                                        contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0)),
                                    onChanged: (uname) {
                                      _user.uname = uname;
                                    }),
                                const SizedBox(height: 84),
                                TextFormField(
                                    focusNode: _passwordFocusNode,
                                    cursorColor: Colors.blue,
                                    onFieldSubmitted: (f) {
                                      _login();
                                    },
                                    style: const TextStyle(fontSize: 20, color: Colors.blue),
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
                                            icon: Icon((!hidePassword) ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.blue)),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0), borderSide: const BorderSide(color: Colors.black)),
                                        prefixIcon: const Padding(padding: EdgeInsets.only(left: 8.0), child: Icon(Icons.lock_outlined, color: Colors.blue)),
                                        hintText: 'Password',
                                        hintStyle: TextStyle(color: Colors.blue.shade200),
                                        fillColor: Colors.white,
                                        filled: true,
                                        contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                        focusedBorder:
                                            OutlineInputBorder(borderSide: const BorderSide(color: Colors.blueAccent, width: 1.0), borderRadius: BorderRadius.circular(5.0)),
                                        enabledBorder:
                                            OutlineInputBorder(borderRadius: BorderRadius.circular(5.0), borderSide: BorderSide(color: Colors.blueGrey.shade50, width: 1.0))),
                                    onChanged: (pword) {
                                      _user.pword = pword;
                                    }),
                                const SizedBox(height: 64),
                                Text(errorMessage, style: const TextStyle(color: Colors.red, fontSize: 20)),
                                SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                        onPressed: _login,
                                        style: FormInputDecoration.buttonStyle(),
                                        child: const Text("Login", style: TextStyle(color: Colors.white, fontSize: 20)))),
                                SizedBox(
                                    width: double.infinity,
                                    child: TextButton(
                                        onPressed: () async {
                                          await const PasswordRecovery().show(context);
                                        },
                                        child: const Text('forgot my password'))),
                                if (nfcIsAvailable) const SizedBox(height: 84),
                                if (nfcIsAvailable) const Center(child: Text("  Or ", style: TextStyle(color: Colors.grey, fontSize: 20), textAlign: TextAlign.center)),
                                if (nfcIsAvailable) const SizedBox(height: 32),
                                if (nfcIsAvailable) const Center(child: Text("Use NFC card to login ", style: TextStyle(color: Colors.black, fontSize: 25)))
                              ])),
                        ))),
              ),
              Positioned(
                top: -50,
                child: SizedBox(
                  height: 300,
                  width: 300,
                  child: Padding(
                      padding: const EdgeInsets.all(24.0), child: Center(child: ClipRRect(borderRadius: BorderRadius.circular(360), child: Image.asset(Res.smartwindlogo)))),
                ),
              ),
              Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Align(
                      alignment: FractionalOffset.bottomCenter,
                      child: Chip(
                          avatar: CircleAvatar(
                              radius: 360,
                              backgroundColor: Colors.grey.shade800,
                              child: ClipRRect(clipBehavior: Clip.antiAlias, borderRadius: BorderRadius.circular(360), child: Image.asset(Res.smartwindlogo, width: 50))),
                          label: Text('SmartWind for Future Fibers $appVersion | $appFlavor'))))
            ],
          ),
        ))
      ],
    );
  }
}

showAccountDeactivatedAlertDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context1) {
      return AlertDialog(
        title: const Text("Deactivated User"),
        content: const Text("Your Account has been deactivated .. please contact admin to activate your account"),
        actions: [
          TextButton(
              child: const Text("Ok"),
              onPressed: () {
                Navigator.of(context1).pop();
              })
        ],
      );
    },
  );
}

showAccountLockedAlertDialog(BuildContext context1) {
  showDialog(
      context: context1,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            height: 400,
            child: Column(
              children: [
                SizedBox(width: 400, child: Image.asset(Res.accountBlocked)),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Locked", textScaleFactor: 1.2, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                ),
                const Text("Your account has been locked please contact Admin", textScaleFactor: 1, style: TextStyle(color: Colors.grey)),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("OK")),
                )
              ],
            ),
          ),
          actions: const [],
        );
      });
}
