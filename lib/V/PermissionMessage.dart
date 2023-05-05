import 'package:flutter/material.dart';
import 'package:smartwind_future_fibers/res.dart';

import '../M/AppUser.dart';

class PermissionMessage extends StatefulWidget {
  const PermissionMessage({Key? key}) : super(key: key);

  @override
  State<PermissionMessage> createState() => _PermissionMessageState();
}

class _PermissionMessageState extends State<PermissionMessage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 256, child: Image.asset(Res.noPermissions)),
          const Text('You don\'t have permissions ', textScaleFactor: 1.2, style: TextStyle(color: Colors.red)),
          const SizedBox(height: 36),
          ElevatedButton(onPressed: () => {AppUser.logout(context)}, child: const Text("Logout"))
        ],
      )),
    );
  }
}
