import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartwind/M/Enums.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/M/user_config.dart';

import '../C/Server.dart';
import 'hive.dart';

class AppUser extends NsUser {
  static var _idToken;

  AppUser() {
    print('AppUser');
    FirebaseAuth.instance.idTokenChanges().listen((firebaseUser) {
      if (firebaseUser != null) {
        firebaseUser.getIdToken().then((value) => _idToken = value);
        print('appUser firebase authStateChanges');
      } else {
        _idToken = null;
      }
    });
  }

  static getIdToken() {
    return _idToken;
  }

  static var configKey = "currentUser";

  static NsUser? getUser() {
    return (HiveBox.userConfigBox.get(configKey, defaultValue: UserConfig()) ?? UserConfig()).user;
  }

  static Future refreshUserData() {
    _userIsAdmin = null;
    return Server.apiGet("user/getUserData", {}).then((value) {
      Map res = value.data;
      NsUser nsUser = NsUser.fromJson(res["user"]);
      AppUser.setUser(nsUser);
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
    print(nsUser.toJson());
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
    listeners.forEach((element) {
      try {
        element();
      } catch (e) {
        print('EEEEEEEEEEEEEE');
      }
    });
  }

  static havePermissionFor(Permissions permission) {
    return (getUser()?.permissions.indexOf(permission.getValue()) ?? -1) > -1;
  }
}
