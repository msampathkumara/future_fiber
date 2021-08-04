import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/V/Home/UserManager/UserManagerUserList.dart';

class UserManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new FutureBuilder<String>(
        future: load(), // a Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.hasError)
              return new Text('Error: ${snapshot.error}');
            else
              return UserManagerUserList(idToken);
          }
        });
  }

  var idToken;

  Future<String> load() async {
    final user = FirebaseAuth.instance.currentUser;
    idToken = await user!.getIdToken();
    print('id token === $idToken');
    return (idToken);
  }
}
