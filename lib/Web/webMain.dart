import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/Web/V/MaterialManagement/materialManagementHomePage.dart';
import 'package:smartwind/main.dart';

import '../C/App.dart';
import '../M/AppUser.dart';
import '../V/Login/Login.dart';
import '../globals.dart';
import 'home_page.dart';

class webApp extends StatelessWidget {
  webApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // connectSocket();
    AppUser(context);

    return MaterialApp(
      title: 'Smart Wind',
      scaffoldMessengerKey: snackBarKey,
      theme: ThemeData(
        iconTheme: const IconThemeData(size: 16.0),
        primarySwatch: Colors.green,
        // primaryColor: Colors.lightGreen,
        primaryColorDark: Colors.green,
        bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.black.withOpacity(0)),
        inputDecorationTheme: InputDecorationTheme(
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(vertical: 22, horizontal: 26),
            labelStyle: const TextStyle(fontSize: 18, decorationColor: Colors.red),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.orange),
              borderRadius: BorderRadius.circular(4.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blueGrey.shade50, width: 1.0),
              borderRadius: BorderRadius.circular(4.0),
            )),
        scrollbarTheme: const ScrollbarThemeData().copyWith(
            thumbColor: MaterialStateProperty.all(Colors.lightGreen),
            thumbVisibility: MaterialStateProperty.all(true),
            trackBorderColor: MaterialStateProperty.all(Colors.lightGreen),
            trackColor: MaterialStateProperty.all(Colors.lightGreen)),
      ),
      // home: MainPage(),
      navigatorObservers: const [],
      initialRoute: "/",
      onUnknownRoute: (RouteSettings settings) {
        return MaterialPageRoute<void>(settings: settings, builder: (BuildContext context) => const Scaffold(body: Center(child: Text('Not Found'))));
      },
      routes: <String, WidgetBuilder>{
        '/login': (BuildContext context) => const Login(),
        '/': (BuildContext context) => (isMaterialManagement ? const MaterialManagementHomePage() : const WebHomePage())
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool loading = true;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      loading = false;
      if (user == null) {
        print('User is currently signed out!__${FirebaseAuth.instance.currentUser}');
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
      } else {
        print('User is signed in!');
        Navigator.pushNamed(context, '/');
      }
    });
    primaryColor = Theme.of(context).primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    return ((FirebaseAuth.instance.currentUser != null && App.currentUser != null))
        ? const Center(child: CircularProgressIndicator())
        : (isMaterialManagement ? const MaterialManagementHomePage() : const WebHomePage());
  }
}
