import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/C/DB/hive.dart';
import 'package:smartwind/M/AppUser.dart';

import '../../C/App.dart';
import '../../C/DB/user_config.dart';

class LoginChangeWidget extends StatefulWidget {
  final Widget child;

  final Widget loginChild;

  const LoginChangeWidget({required this.child, required this.loginChild, Key? key}) : super(key: key);

  @override
  State<LoginChangeWidget> createState() => _LoginChangeWidgetState();
}

class _LoginChangeWidgetState extends State<LoginChangeWidget> {
  bool loading = true;

  StreamSubscription<User?>? authStateChangesListener;

  @override
  void initState() {
    if (authStateChangesListener != null) {
      authStateChangesListener?.cancel();
    }

    authStateChangesListener = FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      loading = false;
      print('User   changed!__${FirebaseAuth.instance.currentUser}');
      if (user == null) {
        print('User is currently signed out!__${FirebaseAuth.instance.currentUser}');
        if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
      } else {
        print('User is signed in!');
        print('FirebaseAuth.instance.currentUser == ${FirebaseAuth.instance.currentUser}');
        print('FirebaseAuth.instance.currentUser == ${App.currentUser}');
        UserConfig userConfig = await HiveBox.getUserConfig();
        print('FirebaseAuth.instance.currentUser == ${userConfig.user?.toJson()}');
        // Navigator.pushNamed(context, '/');
        if ((App.currentUser == null)) {
          await AppUser.logout(context);
        }
      }
      if (mounted) {
        setState(() {});
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
        : ((FirebaseAuth.instance.currentUser != null && App.currentUser != null))
            ? widget.child
            : widget.loginChild;
  }
}
