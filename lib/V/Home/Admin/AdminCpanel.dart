import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:smartwind/C/OnlineDB.dart';

class AdminCpanel extends StatefulWidget {
  const AdminCpanel({Key? key}) : super(key: key);

  @override
  _AdminCpanelState createState() => _AdminCpanelState();
}

class _AdminCpanelState extends State<AdminCpanel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Wrap(
      children: [
          ElevatedButton(
              child: Text("Update Files"),
              onPressed: () {
                OnlineDB.apiGet("tickets/updateFiles", {}).then((Response response) async {
                  print(response.body);
                });
              })
      ],
    ),
        ));
  }
}
