import 'package:app_settings/app_settings.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartwind/C/Server.dart';
import 'package:smartwind/M/hive.dart';

import 'C/App.dart';
import 'M/AppUser.dart';
import 'V/Home/Home.dart';
import 'V/Login/Login.dart';
import 'Web/webMain.dart';
import 'firebase_options.dart';
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

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform).catchError((e) {
    print(" Error : ${e.toString()}");
  });

  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }
  if (kIsWeb) {
    var xx = await FirebaseAuth.instance.authStateChanges().first;
    print(xx);
    print('User----------------------------------------------------------s');
  }

  FirebaseAuth.instance.userChanges().listen((User? user) {
    print('User----------------------------------------------------------');
    if (user == null) {
      print('User is currently signed out!***');
    } else {
      print('User is signed in!');
    }
  });

  FirebaseAuth.instance.authStateChanges().listen((event) {
    print('----------------------------------------------------------');

    print(FirebaseAuth.instance.currentUser);
    print(event);
    print('----------------------------------------------------------');
  });

  try {
    print("***xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx${Firebase.apps.length}___${FirebaseAuth.instance.currentUser}");
  } catch (e) {
    // if (Firebase.apps.isEmpty) {
    // } else {
    //   Firebase.app();
    // }

    //   if (kIsWeb) {
    //     await Firebase.initializeApp(
    //         options: const FirebaseOptions(
    //             apiKey: "AIzaSyCgW6bXgp0PmoKNcAUsAzTqOS8YYFPd0dM",
    //             authDomain: "smart-wind.firebaseapp.com",
    //             databaseURL: "https://smart-wind-default-rtdb.firebaseio.com",
    //             projectId: "smart-wind",
    //             storageBucket: "smart-wind.appspot.com",
    //             messagingSenderId: "27155477934",
    //             appId: "1:27155477934:web:1ff8578ac037a6e330043f",
    //             measurementId: "G-SEBNEV8XVM"));
    //   } else {
    //     await Firebase.initializeApp();
    //   }
  }

  DatabaseReference ref = FirebaseDatabase.instance.ref('devServerIp');

  ref.onValue.listen((event) {
    Server.devServerIp = event.snapshot.value.toString();
    print('ip == ${Server.devServerIp}');
  });
  await HiveBox.create();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

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
            primarySwatch: Colors.green,
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
                ))),
        home: const MyHomePage(),
        // home: const MainApp1(),
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
      SharedPreferences.setMockInitialValues({});
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
          future: _mainFuncs.init(),
          builder: (context, snapshot) {
            return _getUi(snapshot);
          }),
    );
  }

  Widget _getUi(AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      if (snapshot.data['permission'] == false) {
        return Scaffold(
            body: Center(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            direction: Axis.vertical,
            children: [
              const Text("Enable Permissions", textScaleFactor: 1.5),
              const SizedBox(height: 16),
              if (snapshot.data['isPermanentlyDenied'] == true)
                ElevatedButton(
                    onPressed: () async {
                      await AppSettings.openAppSettings();
                      if (!mounted) return;
                      await AppUser.logout(context);
                    },
                    child: const Text("Open Settings")),
              if (snapshot.data['isPermanentlyDenied'] == false)
                ElevatedButton(
                    onPressed: () async {
                      PermissionStatus p = await Permission.phone.request();
                      await Permission.storage.request();
                      await Permission.camera.request();
                      print("******************************************************************************");
                      print(p);
                      if (!mounted) return;
                      await AppUser.logout(context);
                    },
                    child: const Text("Request permissions"))
            ],
          ),
        ));
      }

      if (FirebaseAuth.instance.currentUser != null && App.currentUser != null) {
        return const Home();
      }
      return const Login();
    } else {
      return Center(
          child: Column(
              mainAxisSize: MainAxisSize.min, children: const [CircularProgressIndicator(), Padding(padding: EdgeInsets.all(16.0), child: Text("Loading", textScaleFactor: 1))]));
    }
  }
}
