import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../C/App.dart';
import '../V/Login/Login.dart';
import '../mainFuncs.dart';
import 'home_page.dart';

class webApp extends StatelessWidget {
  webApp({Key? key}) : super(key: key);
  mainFuncs _mainFuncs = new mainFuncs();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Smart Wind',
        theme: ThemeData(
            iconTheme: IconThemeData(size: 16.0),
            primarySwatch: Colors.blue,
            bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.black.withOpacity(0)),
            inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 22, horizontal: 26),
                labelStyle: TextStyle(fontSize: 18, decorationColor: Colors.red),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.lightBlue),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueGrey.shade50, width: 1.0),
                  borderRadius: BorderRadius.circular(4.0),
                ))),
        home: FutureBuilder(
            future: _mainFuncs.initializeFlutterFireFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                print('-----------------------------------------xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
                if (FirebaseAuth.instance.currentUser != null && App.currentUser != null) {
                  print('-----------------------------------------xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx__2222222222222222222222');
                  return WebHomePage();
                }
                return Login();
              } else {
                return Center(
                    child: Container(
                        child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [CircularProgressIndicator(), Padding(padding: const EdgeInsets.all(16.0), child: Text("Loading", textScaleFactor: 1))],
                )));
              }
            }),
        navigatorObservers: []);
  }
}
