import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/C/Api.dart';
import 'package:smartwind/M/EndPoints.dart';
import 'package:smartwind/M/Enums.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/M/PermissionsEnum.dart';
import 'package:smartwind/M/user_config.dart';

import '../C/DB/DB.dart';
import 'Section.dart';
import 'hive.dart';

class AppUser extends NsUser {

  AppUser(context) {
    print('AppUser');
    FirebaseAuth.instance.idTokenChanges().listen((firebaseUser) {
      if (firebaseUser != null) {
        print('appUser firebase authStateChanges');
      } else {
      }
    });
  }

  static bool get isLogged => (FirebaseAuth.instance.currentUser != null);

  static bool get isNotLogged => !isLogged;

  static getIdToken([reFreshToken = false]) async {
    final user = FirebaseAuth.instance.currentUser;

    final _idToken = user?.getIdToken(reFreshToken);
    return _idToken;
  }

  static var configKey = "currentUser";

  static NsUser? getUser() {
    return (HiveBox.userConfigBox.get(configKey, defaultValue: UserConfig()) ?? UserConfig()).user;
  }

  static Section? getSelectedSection() {
    return getUserConfig().selectedSection;
  }

  static Future setSelectedSection(Section section) {
    return Api.post(EndPoints.user_setUserSection, {'sectionId': section.id}).then((value) {
      UserConfig userConfig = getUserConfig();
      userConfig.selectedSection = section;
      userConfig.save();
    });
  }

  static Future refreshUserData() {
    _userIsAdmin = null;
    return Api.get(EndPoints.user_getUserData, {}).then((value) {
      Map res = value.data;
      // print(res);
      NsUser nsUser = NsUser.fromJson(res["user"]);
      AppUser.setUser(nsUser);
      DB.callChangesCallBack(DataTables.appUser);
      updateUserChangers();
      return nsUser;
    });
  }

  static bool? _userIsAdmin;

  static get userIsAdmin {
    return _userIsAdmin ?? AppUser.getUser()?.utype == 'admin';
  }

  static void setUser(NsUser nsUser) {
    UserConfig userConfig = getUserConfig();
    userConfig.user = nsUser;
    HiveBox.userConfigBox.put(configKey, userConfig);
    // print(nsUser.toJson());
    updateUserChangers();
  }

  static UserConfig getUserConfig() {
    return HiveBox.userConfigBox.get(configKey, defaultValue: UserConfig()) ?? UserConfig();
  }

  static final List<Function> listeners = [];

  static onUpdate(Function function) {
    listeners.add(function);
  }

  static void removeOnUpdate(onUpdate) {
    listeners.remove(onUpdate);
  }

  static void updateUserChangers() {
    for (var element in listeners) {
      try {
        element();
      } catch (e) {
        print('EEEEEEEEEEEEEE');
      }
    }
  }

  static havePermissionFor(NsPermissions permission) {
    return (getUser()?.permissions.indexOf(permission.getValue()) ?? -1) > -1;
  }

  static logout(context) async {
    _userIsAdmin = null;
    await FirebaseAuth.instance.signOut();
    HiveBox.userConfigBox.clear();

    if (kIsWeb) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }
}
