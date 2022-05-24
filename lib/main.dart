import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartwind/C/Server.dart';
import 'package:smartwind/M/hive.dart';
import 'package:smartwind/Web/webMain.dart';

import 'C/App.dart';
import 'V/Home/Home.dart';
import 'V/Login/Login.dart';
import 'mainFuncs.dart';

main() async {
  bool x = Uri.base.host.contains('mm.');
  if (kDebugMode) {
    x = false;
  }
  await mainThings(viewIssMaterialManagement: x);
}

bool isMaterialManagement = false;

Future<void> mainThings({viewIssMaterialManagement = false}) async {
  isMaterialManagement = viewIssMaterialManagement;
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();

  DatabaseReference ref = FirebaseDatabase.instance.ref('devServerIp');

  ref.onValue.listen((event) {
    Server.devServerIp = event.snapshot.value.toString();
    print('ip == ' + Server.devServerIp);
  });
  await HiveBox.create();

  if (Firebase.apps.isEmpty) {
    if (kIsWeb) {
      await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: "AIzaSyCgW6bXgp0PmoKNcAUsAzTqOS8YYFPd0dM",
              authDomain: "smart-wind.firebaseapp.com",
              databaseURL: "https://smart-wind-default-rtdb.firebaseio.com",
              projectId: "smart-wind",
              storageBucket: "smart-wind.appspot.com",
              messagingSenderId: "27155477934",
              appId: "1:27155477934:web:1ff8578ac037a6e330043f",
              measurementId: "G-SEBNEV8XVM"));
    } else {
      await Firebase.initializeApp();
    }
  } else {
    Firebase.app();
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // transparent status bar
  ));

  runApp(kIsWeb ? webApp() : const MyApp());
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Smart Wind',
        theme: ThemeData(
            primarySwatch: Colors.blue,
            bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.black.withOpacity(0)),
            inputDecorationTheme: InputDecorationTheme(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(vertical: 22, horizontal: 26),
                labelStyle: const TextStyle(fontSize: 18, decorationColor: Colors.red),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.lightBlue),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueGrey.shade50, width: 1.0),
                  borderRadius: BorderRadius.circular(4.0),
                ))),
        home: const MyHomePage(),
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: analytics),
        ]);
  }
}

late Color primaryColor;
late ThemeData AppTheme;

class MyHomePage extends StatefulWidget {
  const MyHomePage();

  final String title = "NS Smart Wind";

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final mainFuncs _mainFuncs = mainFuncs();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      primaryColor = Theme.of(context).primaryColor;
      AppTheme = Theme.of(context);
    });

    if (kDebugMode) {
      SharedPreferences.setMockInitialValues(Map());
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
            return _getUi(snapshot.hasData);
          }),
    );
  }

  Widget _getUi(hasData) {
    if (hasData) {
      if (FirebaseAuth.instance.currentUser != null && App.currentUser != null) {
        return const Home();
      }
      return Login();
    } else {
      return Center(
          child: Column(
              mainAxisSize: MainAxisSize.min, children: const [CircularProgressIndicator(), Padding(padding: EdgeInsets.all(16.0), child: Text("Loading", textScaleFactor: 1))]));
    }
  }
}
