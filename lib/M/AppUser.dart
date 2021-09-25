import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartwind/M/NsUser.dart';

class AppUser extends NsUser {
  static var _idToken;

  AppUser() {
    print('AppUser');
    FirebaseAuth.instance.idTokenChanges().listen((firebaseUser) {
      if (firebaseUser != null) {
        firebaseUser.getIdToken().then((value) => _idToken = value);
        print('appUser firebase authStateChanges');
      }else{
        _idToken=null;
      }
    });
  }

  static getIdToken() {
    return _idToken;
  }
}
