import 'package:app_settings/app_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../C/App.dart';
import '../../M/AppUser.dart';
import '../../globals.dart';
import '../../main.dart';
import 'mainFuncs.dart';
import 'Home/MobileHome.dart';
import 'Home/Tickets/ProductionPool/ProductionPool.dart';
import 'Login/CheckTabStatus.dart';
import 'Login/Login.dart';

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
