import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
        direction: Axis.vertical,
        children: [
          ElevatedButton(
              child: Text("Update Files"),
              onPressed: () {
                OnlineDB.apiGet("tickets/updateFiles", {}).then((response) async {
                  print(response.data);
                });
              }),
          ElevatedButton(
              child: Text("Convert Tickets"),
              onPressed: () {
                OnlineDB.apiGet("admin/convertTickets", {}).then((response) async {
                  print(response.data);
                });
              }),
          ElevatedButton(
              child: Text("Reload Ticket DB"),
              onPressed: () {
                OnlineDB.apiGet("admin/reloadTicketDB", {}).then((response) async {
                  print(response.data);
                });
              }),
          ElevatedButton(
              child: Text("Update Ticket Availability (online Server)"),
              onPressed: () {
                OnlineDB.apiGet("admin/checkFile", {}, onlineServer: true).then((response) async {
                  print(response.data);
                });
              }),
        ],
      ),
    ));
  }
}
