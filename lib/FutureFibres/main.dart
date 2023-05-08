import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartwind_future_fibers/C/Server.dart';

import '../C/App.dart';
import '../C/DB/hive.dart';
import '../Mobile/V/MobileApp.dart';
import '../Web/webApp.dart';
import '../firebase_options.dart';
import '../globals.dart';

void runLoggedApp() async {
  runZoned(() async {
    await HiveBox.create();
    runApp((!kIsWeb && await isTestServer)
        ? Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(title: const Text('Test'), backgroundColor: Colors.red, toolbarHeight: 50, centerTitle: true, actions: [
              IconButton(onPressed: () async => {await App.changeToProduction()}, icon: const Icon(Icons.change_circle))
            ]),
            body: const MainApp())
        : const MainApp());
  }, zoneSpecification: ZoneSpecification(print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
    if (kDebugMode) {
      parent.print(zone, "out > $line");
    }
  }));
}

main() async {
  var env = const String.fromEnvironment("flavor");
  print('var env = String.fromEnvironment("flavor") =========== >>>$env');

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    isMaterialManagement = false;
  } else {
    isMaterialManagement = Uri.base.host.contains('mm.');
  }
  runLoggedApp();
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
    // screenSize = MediaQuery.of(context).size;

    return loading
        ? const Center(child: SizedBox(width: 200, height: 200, child: CircularProgressIndicator(color: Colors.red)))
        : FutureBuilder<bool>(
            future: isTestServer,
            builder: (context, AsyncSnapshot<bool> _isTestServer) {
              return _isTestServer.hasData
                  ? Column(children: [
                      if (kIsWeb && (_isTestServer.data ?? false || isLocalServer))
                        Container(
                            height: 20,
                            color: Colors.red,
                            width: double.infinity,
                            child: Center(
                                child: Wrap(
                                    children: [Text((_isTestServer.data ?? false) ? 'Test server' : 'Local Server', style: const TextStyle(color: Colors.white, fontSize: 15))]))),
                      Expanded(
                          child: loading
                              ? const Center(child: SizedBox(width: 200, height: 200, child: CircularProgressIndicator(color: Colors.red)))
                              : (kIsWeb ? const WebApp() : const MobileApp()))
                    ])
                  : Container();
            });
  }
}

Future mainThings({viewIssMaterialManagement = false}) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
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

  DatabaseReference ref = firebaseDatabase.child('devServerIp');

  ref.onValue.listen((event) {
    Server.devServerIp = event.snapshot.value.toString();
    // print('ip == ${Server.devServerIp}');
  });

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

  // runLoggedApp(kIsWeb ? webApp() : const MyApp());
}

late Color primaryColor;
late ThemeData appTheme;
