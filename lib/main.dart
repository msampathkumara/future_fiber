import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smartwind/C/Server.dart';
import 'package:smartwind/Mobile/V/Home/Tickets/ProductionPool/ProductionPool.dart';
import 'C/App.dart';
import 'C/DB/hive.dart';
import 'M/AppUser.dart';
import 'Mobile/V/Home/MobileHome.dart';
import 'Mobile/V/Login/CheckTabStatus.dart';
import 'Mobile/V/Login/Login.dart';
import 'Web/webMain.dart';
import 'firebase_options.dart';
import 'globals.dart';
import 'mainFuncs.dart';

void runLoggedApp() async {
  runZoned(() async {
    await HiveBox.create();
    runApp(MaterialApp(
        home: (!kIsWeb && await isTestServer)
            ? Scaffold(
                appBar: AppBar(title: const Text('Test'), backgroundColor: Colors.red, toolbarHeight: 50, centerTitle: true, actions: [
                  IconButton(onPressed: () async => {await App.changeToProduction()}, icon: const Icon(Icons.change_circle))
                ]),
                body: const MainApp())
            : const MainApp()));
  }, zoneSpecification: ZoneSpecification(print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
    if (kDebugMode) {
      parent.print(zone, "out > $line");
    }
  }));
}

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  bool x = Uri.base.host.contains('mm.');
  if (kDebugMode) {
    x = false;
  }

  isMaterialManagement = x;

  runLoggedApp();
}

Future mainThings({viewIssMaterialManagement = false}) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }
  if (kIsWeb) {
    await FirebaseAuth.instance.authStateChanges().first;
  }

  FirebaseAuth.instance.userChanges().listen((User? user) {
    if (user == null) {
      // print('User is currently signed out!***');
    } else {
      // print('User is signed in!');
    }
  });

  FirebaseAuth.instance.authStateChanges().listen((event) {
    // print(FirebaseAuth.instance.currentUser);
  });

  DatabaseReference ref = FirebaseDatabase.instance.ref('devServerIp');

  ref.onValue.listen((event) {
    Server.devServerIp = event.snapshot.value.toString();
    // print('ip == ${Server.devServerIp}');
  });

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

  // runLoggedApp(kIsWeb ? webApp() : const MyApp());
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool loading = true;

  @override
  void initState() {
    mainThings().then((value) => {
          setState(() {
            loading = false;
          })
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    return loading
        ? const Center(child: SizedBox(width: 200, height: 200, child: CircularProgressIndicator(color: Colors.red)))
        : MaterialApp(
            home: FutureBuilder<bool>(
                future: isTestServer,
                builder: (context, AsyncSnapshot<bool> _isTestServer) {
                  return _isTestServer.hasData
                      ? Column(
                          children: [
                            if (kIsWeb && (_isTestServer.data ?? false || isLocalServer))
                              Container(
                                  height: 20,
                                  color: Colors.red,
                                  width: double.infinity,
                                  child: Center(
                                      child: Wrap(
                                    children: [
                                      Text((_isTestServer.data ?? false) ? 'Test server' : 'Local Server', style: const TextStyle(color: Colors.white, fontSize: 15)),
                                    ],
                                  ))),
                            Expanded(
                                child: loading
                                    ? const Center(child: SizedBox(width: 200, height: 200, child: CircularProgressIndicator(color: Colors.red)))
                                    : (kIsWeb ? const WebApp() : const MobileApp())),
                          ],
                        )
                      : Container();
                }),
          );
  }
}

class MobileApp extends StatelessWidget {
  const MobileApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Wind',
      scaffoldMessengerKey: snackBarKey,
      navigatorKey: navigatorKey,
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
      // home: const CsTest(),
      navigatorObservers: const [
        // FirebaseAnalyticsObserver(analytics: analytics),
      ],
      routes: <String, WidgetBuilder>{'/login': (BuildContext context) => const Login(), '/pp': (BuildContext context) => const ProductionPool()},
    );
  }
}

late Color primaryColor;
late ThemeData appTheme;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  final String title = "NS SmartWind";

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final MainFunctions _mainFuncs = MainFunctions();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      primaryColor = Theme.of(context).primaryColor;
      appTheme = Theme.of(context);
    });
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
                      await Permission.phone.request();
                      await Permission.storage.request();
                      await Permission.camera.request();
                      if (!mounted) return;
                      await AppUser.logout(context);
                    },
                    child: const Text("Request permissions"))
            ],
          ),
        ));
      }

      if (FirebaseAuth.instance.currentUser != null && App.currentUser != null) {
        if (snapshot.data['tabChecked'] == false) {
          return CheckTabStatus(App.currentUser!);
        }
        return const MobileHome();
      }

      return const Login();
    } else {
      return Center(
          child: Column(
              mainAxisSize: MainAxisSize.min, children: const [CircularProgressIndicator(), Padding(padding: EdgeInsets.all(16.0), child: Text("Loading", textScaleFactor: 1))]));
    }
  }
}
