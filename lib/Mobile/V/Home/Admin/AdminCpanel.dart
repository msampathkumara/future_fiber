import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/Web/V/Admin/webAdmin.dart';

import '../../../../C/Api.dart';

class AdminCpanel extends StatefulWidget {
  const AdminCpanel({Key? key}) : super(key: key);

  @override
  _AdminCpanelState createState() => _AdminCpanelState();
}

class _AdminCpanelState extends State<AdminCpanel> {
  @override
  Widget build(BuildContext context) {
    return kIsWeb
        ? const WebAdmin()
        : Scaffold(
            body: Center(
            child: Wrap(
              direction: Axis.vertical,
              children: [
                ElevatedButton(
                    child: const Text("Update Files"),
                    onPressed: () {
                      Api.get("tickets/updateFiles", {}).then((response) async {
                        print(response.data);
                      });
                    }),
                ElevatedButton(
                    child: const Text("Convert Tickets"),
                    onPressed: () {
                      Api.get("admin/convertTickets", {}).then((response) async {
                        print(response.data);
                      });
                    }),
                ElevatedButton(
                    child: const Text("Reload Ticket DB"),
                    onPressed: () {
                      Api.get("admin/reloadTicketDB", {}).then((response) async {
                        print(response.data);
                      });
                    }),
                ElevatedButton(
                    child: const Text("Update Ticket Availability (online Server)"),
                    onPressed: () {
                      Api.get("admin/checkFile", {}, onlineServer: true).then((response) async {
                        print(response.data);
                      });
                    }),
                ListTile(
                    title: const Text("Update Standard Library Usage"),
                    subtitle: const Text(""),
                    trailing: ElevatedButton.icon(
                        onPressed: () {
                          Api.get("admin/updateStandardLibUsage", {}).then((response) async {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Update Standard Library Usage success")));
                          });
                        },
                        label: const Text("Update"),
                        icon: const Icon(Icons.update))),
              ],
            ),
          ));
  }
}
