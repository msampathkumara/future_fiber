import 'package:flutter/material.dart';
import 'package:smartwind/M/NsUser.dart';

class UserPermissions extends StatefulWidget {
  NsUser nsUser;
  UserPermissions(this.nsUser,{Key? key}) : super(key: key);

  @override
  _UserPermissionsState createState() {
    return _UserPermissionsState();
  }

  static show(context, nsUser) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserPermissions(nsUser)),
    );
  }
}

class _UserPermissionsState extends State<UserPermissions> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold();
  }
}