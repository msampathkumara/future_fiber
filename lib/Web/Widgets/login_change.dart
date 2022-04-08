import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../C/App.dart';

class LoginChangeWidget extends StatefulWidget {
  final Widget child;

  final Widget loginChild;

  const LoginChangeWidget({required this.child, required this.loginChild, Key? key}) : super(key: key);

  @override
  State<LoginChangeWidget> createState() => _LoginChangeWidgetState();
}

class _LoginChangeWidgetState extends State<LoginChangeWidget> {
  bool loading = true;

  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      loading = false;
      if (user == null) {
        print('User is currently signed out!__');
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
      } else {
        print('User is signed in!');
        // Navigator.pushNamed(context, '/');
      }
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Center(child: CircularProgressIndicator(color: Colors.redAccent))
        : ((FirebaseAuth.instance.currentUser != null && App.currentUser != null))
            ? widget.child
            : widget.loginChild;
  }
}
