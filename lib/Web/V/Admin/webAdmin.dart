import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../C/OnlineDB.dart';

class WebAdmin extends StatefulWidget {
  const WebAdmin({Key? key}) : super(key: key);

  @override
  State<WebAdmin> createState() => _WebAdminState();
}

class _WebAdminState extends State<WebAdmin> {
  var searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(title: Text("Admin Settings"), backgroundColor: Colors.red),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 700,
              child: Column(
                children: [
                  // Padding(padding: const EdgeInsets.all(8.0), child: SizedBox(width: 500, child: SearchBar(onSearchTextChanged: (t) {}, searchController: searchController))),
                  Expanded(
                    child: ListView(
                      children: [
                        const Text("Files", textScaleFactor: 2),
                        Card(
                            child: Column(
                          children: [
                            ListTile(
                                title: const Text("Update Files"),
                                subtitle: const Text("Update Files on server with production pool tickets "),
                                trailing: ElevatedButton.icon(
                                    onPressed: () {
                                      OnlineDB.apiGet("tickets/updateFiles", {}).then((response) async {
                                        print(response.data);
                                      });
                                    },
                                    label: const Text("Update"),
                                    icon: const Icon(Icons.system_update))),
                            ListTile(
                                title: const Text("Delete Temp PDFs"),
                                subtitle: const Text("Delete temp pdfs create for production pool"),
                                trailing: ElevatedButton.icon(onPressed: () {}, label: const Text("Delete"), icon: const Icon(Icons.delete_rounded))),
                          ],
                        )),
                        const SizedBox(height: 20),
                        const Text("Database", textScaleFactor: 2),
                        Card(
                            child: Column(
                          children: [
                            ListTile(
                                title: const Text("Reload In memory Database"),
                                subtitle: const Text("in case of missing data or not update properly "),
                                trailing: ElevatedButton.icon(onPressed: () {}, label: const Text("Reload"), icon: const Icon(Icons.memory_rounded)))
                          ],
                        )),
                        const SizedBox(height: 20),
                        const Text("Devices", textScaleFactor: 2),
                        Card(
                            child: Column(
                          children: [
                            ListTile(
                                title: const Text("Clean  Reload Device "),
                                subtitle: const Text("in case of missing data or not update properly this will clean and update all device database when online"),
                                trailing: ElevatedButton.icon(onPressed: () {}, label: const Text("Reload"), icon: const Icon(Icons.cleaning_services))),
                          ],
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
