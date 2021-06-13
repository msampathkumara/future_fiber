import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/V/Widgets/Loading.dart';

// import 'package:firebase_auth/firebase_auth.dart';
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
  FirebaseAnalytics analytics = FirebaseAnalytics();

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
            print("ssssssssssssssssssssssssssss " + snapshot.toString());
            if (snapshot.hasData) {
              return Login();
            } else {
              return Loading();
            }
          }),
    );
  }
}
