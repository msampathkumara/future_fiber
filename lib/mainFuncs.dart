import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smartwind/C/App.dart';

class mainFuncs {
  final _kShouldTestAsyncErrorOnInit = false;
  final _kTestingCrashlytics = true;

  late Future initializeFlutterFireFuture = initializeFlutterFire();

  mainFuncs();

  Future<bool> initializeFlutterFire() async {
    // await DB.getDB();
    // Wait for Firebase to initialize
    if (!kIsWeb) {
      await Firebase.initializeApp();
      print('dddddddddddddd');
      // FirebaseCrashlytics.instance.crash();
      if (_kTestingCrashlytics) {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      } else {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
      }
      print('dddddddddddddd');

      Function originalOnError = FlutterError.onError as Function;
      FlutterError.onError = (FlutterErrorDetails errorDetails) async {
        await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
        originalOnError(errorDetails);
      };
      print('dddddddddddddd');
      if (_kShouldTestAsyncErrorOnInit) {
        await _testAsyncErrorOnInit();
      }
    }

    App.getCurrentUser();
    print('ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc');
    return Future.value(true);
  }

  Future<void> _testAsyncErrorOnInit() async {
    Future<void>.delayed(const Duration(seconds: 2), () {
      final List<int> list = <int>[];
      print(list[100]);
    });
  }

  init() async {
    await initializeFlutterFireFuture;

    PermissionStatus ps = await Permission.phone.request();
    PermissionStatus storage = await Permission.storage.request();
    PermissionStatus camera = await Permission.camera.request();
    return {
      'permission': ps.isGranted && storage.isGranted && camera.isGranted,
      'isPermanentlyDenied': ps.isPermanentlyDenied || storage.isPermanentlyDenied || camera.isPermanentlyDenied,
      'permissions': {'phone': ps, 'camera': camera, 'storage': storage}
    };
  }
}
