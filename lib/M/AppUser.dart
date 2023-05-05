import 'package:firebase_auth/firebase_auth.dart';
import 'package:restart_app/restart_app.dart';
import 'package:smartwind_future_fibers/C/Api.dart';
import 'package:smartwind_future_fibers/C/App.dart';
import 'package:smartwind_future_fibers/M/EndPoints.dart';
import 'package:smartwind_future_fibers/M/Enums.dart';
import 'package:smartwind_future_fibers/M/NsUser.dart';
import 'package:smartwind_future_fibers/M/PermissionsEnum.dart';
import 'package:smartwind_future_fibers/C/DB/user_config.dart';

import '../C/DB/DB.dart';
import 'Section.dart';
import '../C/DB/hive.dart';

class AppUser extends NsUser {
  static get isDeveloper => getUser()?.id == 1;

  AppUser(context) {
    print('AppUser');
    FirebaseAuth.instance.idTokenChanges().listen((firebaseUser) {
      if (firebaseUser != null) {
        print('appUser firebase authStateChanges');
      } else {}
    });
  }

  static bool get isLogged => (FirebaseAuth.instance.currentUser != null);

  static bool get isNotLogged => !isLogged;

  static getIdToken([reFreshToken = false]) async {
    final user = FirebaseAuth.instance.currentUser;

    final _idToken = user?.getIdToken(reFreshToken);
    return _idToken;
  }

  static var configKey = 0;

  static NsUser? getUser() {
    // return (await HiveBox. getUserConfig()).user;
    return ((HiveBox.userConfigBox.get(configKey, defaultValue: UserConfig())))?.user;
  }

  static Section? getSelectedSection() {
    return ((HiveBox.userConfigBox.get(configKey, defaultValue: UserConfig())))?.selectedSection;
  }

  static Future setSelectedSection(Section section) {
    return Api.post(EndPoints.user_setUserSection, {'sectionId': section.id}).then((value) async {
      UserConfig userConfig = await HiveBox.getUserConfig();
      userConfig.selectedSection = section;
      userConfig.save();
    });
  }

  static Future refreshUserData() {
    _userIsAdmin = null;
    return Api.get(EndPoints.user_getUserData, {}).then((value) async {
      Map res = value.data;
      print("user data response");
      // print(res);
      NsUser nsUser = NsUser.fromJson(res["user"]);
      // print(nsUser.toJson());
      await AppUser.setUser(nsUser);
      print(App.currentUser?.toJson());

      DB.callChangesCallBack(DataTables.appUser);
      return nsUser;
    });
  }

  static bool? _userIsAdmin;

  static get userIsAdmin {
    return _userIsAdmin ?? AppUser.getUser()?.utype == 'admin';
  }

  static Future<void> setUser(NsUser nsUser) async {
    UserConfig userConfig = await HiveBox.getUserConfig();
    // UserConfig userConfig = HiveBox.userConfigBox.get(configKey, defaultValue: UserConfig()) ?? UserConfig();
    userConfig.user = nsUser;
    await userConfig.save();
    // await HiveBox.userConfigBox.put(configKey, userConfig);
    // print(nsUser.toJson());
    updateUserChangers();
  }

  // static UserConfig getUserConfig() {
  //   return HiveBox.userConfigBox.get(configKey, defaultValue: UserConfig()) ?? UserConfig();
  // }

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
    await HiveBox.userConfigBox.clear();
    Restart.restartApp(webOrigin: '/');

    // if (kIsWeb) {
    //   Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    // } else {
    //   Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    // }
  }
}
