import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:firebase_auth/firebase_auth.dart';
import 'C/App.dart';
import 'V/Home/Home.dart';
import 'V/Login/Login.dart';
import 'mainFuncs.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  // Firebase.initializeApp().then((value) => print(value)).catchError((onError) => print(onError));
  // FirebaseApp defaultApp = Firebase.app();

  // FirebaseAuth auth = FirebaseAuth.instance;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Smart Wind',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.black.withOpacity(0)),
        ),
        home: MyHomePage(),
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: analytics),
        ]);
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage();

  final String title = "NS Smart Wind";

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  mainFuncs _mainFuncs = new mainFuncs();

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      SharedPreferences.setMockInitialValues(new Map());
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: _mainFuncs.initializeFlutterFireFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (FirebaseAuth.instance.currentUser != null &&  App.currentUser!=null) {
                return Home();
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
    );
  }
}
