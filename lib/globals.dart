import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/C/DB/hive.dart';

enum AppFlavors { V2, DEBUG }

final GlobalKey<ScaffoldMessengerState> snackBarKey = GlobalKey<ScaffoldMessengerState>();
final navigatorKey = GlobalKey<NavigatorState>();
Size screenSize = const Size(0, 0);
var appFlavor = const String.fromEnvironment("flavor");

DatabaseReference get firebaseDatabase => FirebaseDatabase.instance.ref("smartwind/$appFlavor");

Color getPrimaryColor(context) => Theme.of(context).primaryColor;
bool isMaterialManagement = false;

bool? _isTestServer;

bool? _isLocalServer;
bool? _isV2;

Future<bool> get isTestServer async =>
    kIsWeb ? (_isTestServer ?? (_isTestServer = RegExp(r".\.test\.nsslsupportservices\.com").hasMatch(Uri.base.host))) : (await HiveBox.getUserConfig()).isTest;

Future<bool> get isV2 async => kIsWeb ? (_isV2 ?? (_isV2 = RegExp(r".\.v2\.smartwind\.nsslsupportservices\.com").hasMatch(Uri.base.host))) : (await HiveBox.getUserConfig()).isTest;
// kIsWeb ? (_isTestServer ?? (_isTestServer = RegExp(r".\.test\.nsslsupportservices\.com").hasMatch(Uri.base.host))) : (true);
//     true;

bool get isLocalServer => _isLocalServer ?? (_isLocalServer = Uri.base.host == 'localhost');

void printWarning(String text) {
  print('\x1B[33m$text\x1B[0m');
}

void printError(String text) {
  print('\x1B[31m$text\x1B[0m');
}
