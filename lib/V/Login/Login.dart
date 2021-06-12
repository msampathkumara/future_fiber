import 'package:flutter/material.dart';
import 'package:smartwind/C/DB/DB.dart';
import 'package:smartwind/M/User.dart';
import 'package:smartwind/V/Home/Home.dart';

import 'PasswordRecovery.dart';

class Login extends StatefulWidget {
  Login();

  @override
  _LoginState createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black12,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Container(
            child: Wrap(
              direction: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'User Name'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Enter your username'),
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

  User _user = new User();

  _login() {
    // Todo login
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Home()), (Route<dynamic> route) => false);
    DB.updateDatabase();
  }

  _recoverPassword() {
    // Todo recoverPassword

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PasswordRecovery()),
    );
  }
}
