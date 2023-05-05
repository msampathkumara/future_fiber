import 'package:device_info/device_info.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartwind_future_fibers/C/App.dart';

class MainFunctions {
  final _kShouldTestAsyncErrorOnInit = false;
  final _kTestingCrashlytics = true;

  late Future initializeFlutterFireFuture = initializeFlutterFire();

  MainFunctions();

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool tabChecked = prefs.getBool("tabCheck") ?? false;

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    PermissionStatus ps = await Permission.phone.request();
    PermissionStatus storage = androidInfo.version.sdkInt >= 33 ? await Permission.photos.request() : await Permission.storage.request();
    PermissionStatus camera = await Permission.camera.request();

    bool storageIsPermanentlyDenied = false;
    if (androidInfo.version.sdkInt >= 33) {
      storageIsPermanentlyDenied = false;
    } else {
      storageIsPermanentlyDenied = storage.isPermanentlyDenied;
    }

    return {
      'permission': ps.isGranted && storage.isGranted && camera.isGranted,
      'isPermanentlyDenied': ps.isPermanentlyDenied || storageIsPermanentlyDenied || camera.isPermanentlyDenied,
      'permissions': {'phone': ps, 'camera': camera, 'storage': storage},
      'tabChecked': tabChecked
    };
  }
}
