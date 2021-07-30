import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:smartwind/C/App.dart';
import 'package:smartwind/C/DB/DB.dart';

class mainFuncs {
  final _kShouldTestAsyncErrorOnInit = false;
  final _kTestingCrashlytics = true;

  late Future initializeFlutterFireFuture = initializeFlutterFire();

  mainFuncs() ;

  Future<bool> initializeFlutterFire() async {

    await DB.getDB();

    // Wait for Firebase to initialize
    await Firebase.initializeApp();
    // FirebaseCrashlytics.instance.crash();

    if (_kTestingCrashlytics) {
      // Force enable crashlytics collection enabled if we're testing it.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    } else {
      // Else only enable it in non-debug builds.
      // You could additionally extend this to allow users to opt-in.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
    }

    // Pass all uncaught errors to Crashlytics.
    Function originalOnError = FlutterError.onError as Function;
    FlutterError.onError = (FlutterErrorDetails errorDetails) async {
      await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      // Forward to original handler.
      originalOnError(errorDetails);
    };

    if (_kShouldTestAsyncErrorOnInit) {
      await _testAsyncErrorOnInit();
    }

   await App.getCurrentUser();

    return true;
  }

  Future<void> _testAsyncErrorOnInit() async {
    Future<void>.delayed(const Duration(seconds: 2), () {
      final List<int> list = <int>[];
      print(list[100]);
    });
  }
}
