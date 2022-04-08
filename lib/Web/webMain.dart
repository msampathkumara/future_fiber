import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

import '../C/App.dart';
import '../C/Server.dart';
import '../M/AppUser.dart';
import '../M/hive.dart';
import '../V/Login/Login.dart';
import 'home_page.dart';

class webApp extends StatelessWidget {
  webApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {



    // connectSocket();
    AppUser(context);

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
      // home: MainPage(),
      navigatorObservers: [],
      initialRoute: "/",
      onUnknownRoute: (RouteSettings settings) {
        return MaterialPageRoute<void>(settings: settings, builder: (BuildContext context) => Scaffold(body: Center(child: Text('Not Found'))));
      },
      routes: <String, WidgetBuilder>{'/login': (BuildContext context) => Login(), '/': (BuildContext context) => WebHomePage()},
    );
  }

  static late IO.Socket socket;

  static void connectSocket() {
    socket = IO.io(
        Server.getServerAddress(),
        OptionBuilder()
            .setExtraHeaders({'foo': 'bar'})
            .enableAutoConnect() // optional
            .build());

    socket.onConnect((data) {
      print('connect');
      var userid = socket.id!;
      print("id: " + userid);

      if (FirebaseAuth.instance.currentUser != null) {
        HiveBox.getDataFromServer();
      }
    });

    socket.onDisconnect((data) {
      print('disconnect');
    });

    socket.on('connect_error', (data) {
      print("connect_error " + data.toString());
    });

    socket.connect();

    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        print('User is currently signed out!');
        socket.off("db_update");
      } else {
        print('User is signed in!');

        socket.off("db_update");
        socket.off("db_clean_update");
        socket.off("userUpdates");
        socket.off("db_clean_update");

        socket.on('db_update', (data) {
          print("db_update:message: " + data.toString());
          HiveBox.getDataFromServer();
        });
        socket.on('file_update', (data) {
          print("message: " + data.toString());
          HiveBox.getDataFromServer();
        });
        socket.on('userUpdates', (data) {
          print("socket : userUpdates: " + data.toString());
          HiveBox.getDataFromServer();
        });
        socket.on('db_clean_update', (data) {
          print("message: " + data.toString());
          HiveBox.getDataFromServer(clean: true);
        });
      }
    });
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
    // FirebaseAuth.instance.authStateChanges().listen((User? user) {
    //   loading = false;
    //   if (user == null) {
    //     print('User is currently signed out!__');
    //     Navigator.pushNamed(context, '/login');
    //   } else {
    //     print('User is signed in!');
    //     // Navigator.pushNamed(context, '/');
    //   }
    //   setState(() {});
    // });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ((FirebaseAuth.instance.currentUser != null && App.currentUser != null)) ? Center(child: CircularProgressIndicator()) : WebHomePage();

    // return loading
    //     ? Center(child: CircularProgressIndicator())
    //     : (FirebaseAuth.instance.currentUser != null && App.currentUser != null)
    //         ? WebHomePage()
    //         : Login();
  }
}