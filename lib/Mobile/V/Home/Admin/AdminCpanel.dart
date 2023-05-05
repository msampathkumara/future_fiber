import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind_future_fibers/M/EndPoints.dart';
import 'package:smartwind_future_fibers/Web/V/Admin/webAdmin.dart';

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
                    onPressed: () {
                      Api.get(EndPoints.restart, {}).then((response) async {
                        print(response.data);
                      });
                    },
                    child: const Text("Restart server")),
                ElevatedButton(
                    child: const Text("Update Files"),
                    onPressed: () {
                      Api.get(EndPoints.tickets_updateFiles, {}).then((response) async {
                        print(response.data);
                      });
                    }),
                ElevatedButton(
                    child: const Text("Convert Tickets"),
                    onPressed: () {
                      Api.get(EndPoints.admin_convertTickets, {}).then((response) async {
                        print(response.data);
                      });
                    }),
                ElevatedButton(
                    child: const Text("Reload Ticket DB"),
                    onPressed: () {
                      Api.get(EndPoints.admin_reloadTicketDB, {}).then((response) async {
                        print(response.data);
                      });
                    }),
                ElevatedButton(
                    child: const Text("Update Ticket Availability (online Server)"),
                    onPressed: () {
                      Api.get(EndPoints.admin_checkFile, {}, onlineServer: true).then((response) async {
                        print(response.data);
                      });
                    }),
                ListTile(
                    title: const Text("Update Standard Library Usage"),
                    subtitle: const Text(""),
                    trailing: ElevatedButton.icon(
                        onPressed: () {
                          Api.get(EndPoints.admin_updateStandardLibUsage, {}).then((response) async {
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
