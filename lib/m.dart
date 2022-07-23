import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainApp1 extends StatefulWidget {
  const MainApp1({Key? key}) : super(key: key);

  @override
  State<MainApp1> createState() => _MainApp1State();
}

class _MainApp1State extends State<MainApp1> {
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    // TODO: implement initState
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      print('User----------------------------------------------------------');
      if (user == null) {
        print('User is currently signed out!***');
      } else {
        print('User is signed in!');
        setState(() {});
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FirebaseAuth.instance.currentUser == null
            ? ElevatedButton(
                onPressed: () async {
                  final UserCredential googleUserCredential = await FirebaseAuth.instance.signInWithCustomToken(
                      "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJodHRwczovL2lkZW50aXR5dG9vbGtpdC5nb29nbGVhcGlzLmNvbS9nb29nbGUuaWRlbnRpdHkuaWRlbnRpdHl0b29sa2l0LnYxLklkZW50aXR5VG9vbGtpdCIsImlhdCI6MTY1Nzg2ODk0NywiZXhwIjoxNjU3ODcyNTQ3LCJpc3MiOiJmaXJlYmFzZS1hZG1pbnNkay05NXpiZEBzbWFydC13aW5kLmlhbS5nc2VydmljZWFjY291bnQuY29tIiwic3ViIjoiZmlyZWJhc2UtYWRtaW5zZGstOTV6YmRAc21hcnQtd2luZC5pYW0uZ3NlcnZpY2VhY2NvdW50LmNvbSIsInVpZCI6IjU1YTU0MDA4YWQxYmE1ODlhYTIxMGQyNjI5YzFkZjQxIiwiY2xhaW1zIjp7InVzZXIiOnsiaWQiOjEsImNsYWltVmVyc2lvbiI6MH19fQ.MhCY2gGwCzCi9pMahVDlASluiI3eACIlZIMyuSZWF2pidILUtfo74hN237jDB7bd939gauAyfOrwwRd-BViWNT4eZXEfRvIW1KFLrO29xpmUJoeupbOLIh4H2p7xiZ3cCYTS15WvUOxXMqbobTp_GpzfEqJz45w48GQq-uHeMoXYtT8HEbmLhr6DzQx6WoeCcyjF9hf-edRuSc2kekh4c0gVnkaO0uqbYosiDCw30jwNhXYCN-9zG7HcCEXlegKdsBMmoa10qLXzawBmVNQDEsw9Aus9DMEuy4bJs9jJNtLB9XipqJJKQz3O6iNIZPOAf2hjVXHZFOqCHo2E0zLRtg");
                },
                child: Text("ssss"),
              )
            : const Text("ddddddddddd"),
      ),
    );
  }
}
