import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartwind/M/NsUser.dart';

class AppUser extends NsUser {
  static var _idToken;

  AppUser() {
    print('AppUser');
    FirebaseAuth.instance.idTokenChanges().listen((firebaseUser) {
      firebaseUser!.getIdToken().then((value) => _idToken = value);
      print('appUser firebase authStateChanges');
    });
  }

  static getIdToken() {
    return _idToken;
  }
}
