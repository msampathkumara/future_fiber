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
      print('User is currently signed out!__${FirebaseAuth.instance.currentUser}');
      if (user == null) {
        print('User is currently signed out!__${FirebaseAuth.instance.currentUser}');
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
      } else {
        print('User is signed in!');
        // Navigator.pushNamed(context, '/');
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
