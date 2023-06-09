import 'package:flutter/material.dart';
import 'package:smartwind_future_fibers/Web/V/MaterialManagement/materialManagementHomePage.dart';

import '../M/AppUser.dart';
import '../Mobile/V/Login/Login.dart';
import '../globals.dart';
import 'WebHomePage.dart';

class WebApp extends StatelessWidget {
  const WebApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // connectSocket();
    AppUser(context);

    return MaterialApp(
      title: 'Smart Wind',
      scaffoldMessengerKey: snackBarKey,
      navigatorKey: navigatorKey,

      theme: ThemeData(
        iconTheme: const IconThemeData(size: 16.0),
        primarySwatch: Colors.green,
        primaryColorDark: Colors.green,
        primaryIconTheme: IconThemeData(color: Colors.yellow[700], size: 24),
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
            thumbColor: MaterialStateProperty.all(Colors.grey),
            thumbVisibility: MaterialStateProperty.all(true),
            trackBorderColor: MaterialStateProperty.all(Colors.grey),
            trackColor: MaterialStateProperty.all(Colors.grey)),
      ),
      // home: MainPage(),
      navigatorObservers: const [],
      // initialRoute: "/",
      onUnknownRoute: (RouteSettings settings) {
        return MaterialPageRoute<void>(settings: settings, builder: (BuildContext context) => const Scaffold(body: Center(child: Text('Not Found'))));
      },
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => (isMaterialManagement ? const MaterialManagementHomePage() : const WebHomePage()),
        '/login': (BuildContext context) => const Login(),
        // '/materialManagement': (BuildContext context) => const MaterialManagementHomePage(),
        '/materialManagement': (BuildContext context) => const WebHomePage(isMaterialManagement: true),
      },
    );
  }
}
