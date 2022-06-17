import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/Admin/Settings.dart';

import '../../../C/Api.dart';
import '../../../C/OnlineDB.dart';
import '../../../C/Validations.dart';

class WebAdmin extends StatefulWidget {
  const WebAdmin({Key? key}) : super(key: key);

  @override
  State<WebAdmin> createState() => _WebAdminState();
}

class _WebAdminState extends State<WebAdmin> {
  var searchController = TextEditingController();

  late Settings _settings;
  bool _loading = true;

  final _otpAdminEmailController = TextEditingController();

  @override
  initState() {
    loadSettings();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(title: const Text("Admin Settings"), backgroundColor: Colors.red),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Center(
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
                              const SizedBox(height: 20),
                              const Text("ERP Server", textScaleFactor: 2),
                              Card(
                                  child: Column(
                                children: [
                                  ListTile(
                                      title: const Text("ERP Server is not working"),
                                      subtitle: const Text("check if erp server is not working"),
                                      trailing: Checkbox(
                                          value: _settings.isErpNotWorking,
                                          onChanged: (x) {
                                            if (x != null) {
                                              saveSettings('erpNotWorking', x ? 1 : 0);
                                            }
                                          })),
                                ],
                              )),
                              const SizedBox(height: 20),
                              const ListTile(title: Text("OTP emails", textScaleFactor: 2)),
                              Card(
                                  child: _settings.otpAdminEmails.isNotEmpty
                                      ? ListView.separated(
                                          shrinkWrap: true,
                                          itemCount: _settings.otpAdminEmails.length + 1,
                                          itemBuilder: (BuildContext context, int index) {
                                            if (index == _settings.otpAdminEmails.length) {
                                              return ListTile(
                                                  title: TextFormField(
                                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                                controller: _otpAdminEmailController,
                                                onChanged: (email) {},
                                                onFieldSubmitted: (email) {
                                                  if (Validations.isValidEmail(email)) {
                                                    _settings.otpAdminEmails.add(email);
                                                    saveSettings('otpAdminEmails', _settings.otpAdminEmails.join(','));
                                                    _otpAdminEmailController.clear();
                                                    setState(() {});
                                                  }
                                                },
                                                validator: (input) => Validations.isValidEmail(input) ? null : "Check your email",
                                              ));
                                            }

                                            String e = _settings.otpAdminEmails[index];
                                            return ListTile(
                                                title: Text(e),
                                                trailing: _settings.otpAdminEmails.length == 1
                                                    ? null
                                                    : IconButton(
                                                        onPressed: () {
                                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                              backgroundColor: Colors.red,
                                                              content: const Text("Remove this Email Address"),
                                                              action: SnackBarAction(
                                                                  textColor: Colors.white,
                                                                  label: 'Delete',
                                                                  onPressed: () {
                                                                    _settings.otpAdminEmails.remove(e);
                                                                    saveSettings('otpAdminEmails', _settings.otpAdminEmails.join(','));
                                                                    setState(() {});
                                                                  })));
                                                        },
                                                        icon: const Icon(Icons.delete)));
                                          },
                                          separatorBuilder: (BuildContext context, int index) {
                                            return Divider(
                                              color: Colors.grey.shade200,
                                            );
                                          },
                                        )
                                      : const Padding(padding: EdgeInsets.all(24.0), child: Center(child: Text("No Emails")))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ));
  }

  void saveSettings(String settingName, value) {
    Api.post("admin/settings/setSetting", {'setting': settingName, 'value': value}).then((res) {
      Map data = res.data;
      loadSettings();
    }).whenComplete(() {
      setState(() {});
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err.toString()),
          action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                saveSettings(settingName, value);
              })));
      setState(() {
        // _dataLoadingError = true;
      });
    });
  }

  void loadSettings() {
    Api.get("admin/settings/getSettings", {}).then((res) {
      Map data = res.data;
      print(data);
      _settings = Settings.fromJson(data['settings']);
      _loading = false;
      setState(() {});
    }).whenComplete(() {
      setState(() {});
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err.toString()),
          action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                loadSettings();
              })));
      setState(() {
        // _dataLoadingError = true;
      });
    });
  }
}
