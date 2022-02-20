import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:smartwind/C/App.dart';
import 'package:smartwind/C/DB/DB.dart';

class mainFuncs {
  final _kShouldTestAsyncErrorOnInit = false;
  final _kTestingCrashlytics = true;

  late Future initializeFlutterFireFuture = initializeFlutterFire();

  mainFuncs();

  Future<bool> initializeFlutterFire() async {
    // await DB.getDB();
    // Wait for Firebase to initialize
    await Firebase.initializeApp();
    // FirebaseCrashlytics.instance.crash();
    if (_kTestingCrashlytics) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    } else {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
    }


    Function originalOnError = FlutterError.onError as Function;
    FlutterError.onError = (FlutterErrorDetails errorDetails) async {
      await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      originalOnError(errorDetails);
    };
    if (_kShouldTestAsyncErrorOnInit) {
      await _testAsyncErrorOnInit();
    }
      App.getCurrentUser();
    print('ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc');
    return true;
  }

  Future<void> _testAsyncErrorOnInit() async {
    Future<void>.delayed(const Duration(seconds: 2), () {
      final List<int> list = <int>[];
      print(list[100]);
    });
  }
}
