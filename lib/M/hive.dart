import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smartwind/M/user_config.dart';

import '../C/Server.dart';
import '../V/Home/UserManager/UserPermissions.dart';
import 'AppUser.dart';
import 'NsUser.dart';
import 'enums.dart';

class HiveBox {
  static late final Box<NsUser> usersBox;
  static late final Box<NsUser> topReadersBox;

  static late final Box userConfigBox;

  static late final Box<UserPermissions> userPermissions;

  /// Create an instance of HiveBox to use throughout the app.
  static Future create() async {
    if (kIsWeb) {
      Hive.init('booksDb2');
    } else {
      var directory = await getApplicationDocumentsDirectory();
      print("dddddddddddddddddddddddd = ${directory.path}");
      Hive.init(directory.path + '/booksDb2');
    }

    Hive.registerAdapter(NsUserAdapter());
    Hive.registerAdapter(UserConfigAdapter());

    usersBox = await Hive.openBox<NsUser>('userBox');
    topReadersBox = await Hive.openBox<NsUser>('topReadersBox');
    userConfigBox = await Hive.openBox('userConfigBox');
    userPermissions = await Hive.openBox<UserPermissions>('userPermissionsBox');
  }

  static Future getDataFromServer({clean = false}) {
    Box<NsUser> usersBox = HiveBox.usersBox;
    Box<NsUser> topReadersBox = HiveBox.topReadersBox;
    Box<UserPermissions> userPermissionsBox = HiveBox.userPermissions;

    final usersBoxUpon = usersBox.values.isEmpty ? 0 : usersBox.values.map<int>((e) => e.upon).reduce(max);
    final topReadersBoxUpon = topReadersBox.values.isEmpty ? 0 : topReadersBox.values.map<int>((e) => e.upon).reduce(max);

    return Server.apiGet(("data/getData"), {"users": clean ? 0 : usersBoxUpon, "topReaders": clean ? 0 : topReadersBoxUpon}).then((Response response) async {
      if (clean) {
        await usersBox.clear();
        await topReadersBox.clear();
        await userPermissionsBox.clear();
      }

      print('5');
      Map res = response.data;

      List<NsUser> usersList = NsUser.fromJsonArray(res["users"] ?? []);
      List<NsUser> topReadersList = NsUser.fromJsonArray(res["topReaders"] ?? []);

      usersBox.putMany(usersList);
      topReadersBox.putMany(topReadersList);

      if (usersList.where((element) => element.id == AppUser.getUser()?.id).isNotEmpty) {
        AppUser.refreshUserData();
      }

      callOnUpdates();
      print("data loaded from server ");
    }).onError((error, stackTrace) {
      print('__________________________________________________________________________________________________________');
      print(error.toString());
      print(stackTrace.toString());
      // ErrorMessageView(errorMessage: error.toString()).show(context);
    });
  }

  static final List<Function> listeners = [];

  static onUpdate(Function function) {
    listeners.add(function);
  }

  static void removeOnUpdate(onupdate) {
    listeners.remove(onupdate);
  }

  static void loadUserBooksList() {}

  static void callOnUpdates() {
    listeners.forEach((element) {
      try {
        element();
      } catch (e) {}
    });
  }
}
