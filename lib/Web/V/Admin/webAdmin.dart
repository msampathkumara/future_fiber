import 'package:flutter/material.dart';
import 'package:smartwind_future_fibers/M/Admin/Settings.dart';
import 'package:smartwind_future_fibers/M/EndPoints.dart';

import '../../../C/Api.dart';
import '../../../C/Validations.dart';
import '../../../M/AppUser.dart';
import '../../../M/PermissionsEnum.dart';

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

  final Map _loadings = {};

  @override
  Widget build(BuildContext context) {
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
                              ElevatedButton(
                                  onPressed: () {
                                    Api.get(EndPoints.restart, {}).then((response) async {
                                      print(response.data);
                                    });
                                  },
                                  child: const Text("Restart server")),
                              const Text("Files", textScaleFactor: 2),
                              Card(
                                  child: Column(
                                children: [
                                  if (AppUser.havePermissionFor(NsPermissions.ADMIN_UPDATE_FILES))
                                    ListTile(
                                        title: const Text("Update Files"),
                                        subtitle: const Text("Update Files on server with production pool tickets "),
                                        trailing: ElevatedButton.icon(
                                            onPressed: () {
                                              Api.get(EndPoints.tickets_updateFiles, {}).then((response) async {
                                                print(response.data);
                                              });
                                            },
                                            label: const Text("Update"),
                                            icon: const Icon(Icons.system_update))),
                                  if (AppUser.havePermissionFor(NsPermissions.ADMIN_DELETE_TEMP_PDFS))
                                    ListTile(
                                        title: const Text("Delete Temp PDFs"),
                                        subtitle: const Text("Delete temp pdfs create for production pool"),
                                        trailing: ElevatedButton.icon(onPressed: () {}, label: const Text("Delete"), icon: const Icon(Icons.delete_rounded))),
                                  if (AppUser.havePermissionFor(NsPermissions.ADMIN_UPDATE_STANDARD_LIBRARY_USAGE))
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
                              )),
                              const SizedBox(height: 20),
                              const Text("Database", textScaleFactor: 2),
                              Card(
                                  child: Column(
                                children: [
                                  if (AppUser.havePermissionFor(NsPermissions.ADMIN_RELOAD_IN_MEMORY_DATABASE))
                                    ListTile(
                                        title: const Text("Reload In memory Database"),
                                        subtitle: const Text("in case of missing data or not update properly "),
                                        trailing: isLoading("reloadInMemoryDB")
                                            ? const CircularProgressIndicator()
                                            : ElevatedButton.icon(
                                                onPressed: () {
                                                  setLoading("reloadInMemoryDB");

                                                  Api.get(EndPoints.admin_reloadInMemoryDB, {}).then((res) {
                                                    removeLoading("reloadInMemoryDB");
                                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reload In memory Database done")));
                                                    setState(() {
                                                      // _dataLoadingError = true;
                                                    });
                                                  }).whenComplete(() {
                                                    setState(() {});
                                                  }).catchError((err) {});
                                                },
                                                label: const Text("Reload"),
                                                icon: const Icon(Icons.memory_rounded))),
                                  ListTile(
                                      title: const Text("Update Ticket Production"),
                                      subtitle: const Text("in case of missing or incorrect Production On Ticket "),
                                      trailing: isLoading("updateTicketProduction")
                                          ? const CircularProgressIndicator()
                                          : ElevatedButton.icon(
                                              onPressed: () {
                                                setLoading("updateTicketProduction");

                                                Api.get(EndPoints.admin_updateTicketProduction, {}).then((res) {
                                                  removeLoading("updateTicketProduction");
                                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Update Ticket Production done")));
                                                  setState(() {
                                                    // _dataLoadingError = true;
                                                  });
                                                }).whenComplete(() {
                                                  setState(() {});
                                                }).catchError((err) {});
                                              },
                                              label: const Text("Update"),
                                              icon: const Icon(Icons.factory)))
                                ],
                              )),
                              const SizedBox(height: 20),
                              const Text("Devices", textScaleFactor: 2),
                              Card(
                                  child: Column(
                                children: [
                                  if (AppUser.havePermissionFor(NsPermissions.ADMIN_CLEAN_RELOAD_DEVICES))
                                    ListTile(
                                        title: const Text("Clean  Reload Devices "),
                                        subtitle: const Text("in case of missing data or not update properly this will clean and update all device database when online"),
                                        trailing: isLoading("cleanReloadDevices")
                                            ? const CircularProgressIndicator()
                                            : ElevatedButton.icon(
                                                onPressed: () {
                                                  setLoading("cleanReloadDevices");
                                                  Api.get(EndPoints.admin_cleanReloadDevices, {}).then((res) {
                                                    removeLoading("cleanReloadDevices");
                                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reload In memory Database done")));
                                                    setState(() {
                                                      // _dataLoadingError = true;
                                                    });
                                                  }).whenComplete(() {
                                                    setState(() {});
                                                  }).catchError((err) {});
                                                },
                                                label: const Text("Reload"),
                                                icon: const Icon(Icons.cleaning_services))),
                                ],
                              )),
                              const Text("convert tickets", textScaleFactor: 2),
                              Card(
                                  child: Column(
                                children: [
                                  if (AppUser.havePermissionFor(NsPermissions.ADMIN_CLEAN_RELOAD_DEVICES))
                                    ListTile(
                                        title: const Text("convert tickets"),
                                        subtitle: const Text("After update"),
                                        trailing: isLoading("convertTickets")
                                            ? const CircularProgressIndicator()
                                            : ElevatedButton.icon(
                                                onPressed: () {
                                                  setLoading("convertTickets");
                                                  Api.get(EndPoints.admin_convertTickets, {}).then((res) {
                                                    removeLoading("convertTickets");
                                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Update Production done")));
                                                    setState(() {
                                                      // _dataLoadingError = true;
                                                    });
                                                  }).whenComplete(() {
                                                    setState(() {});
                                                  }).catchError((err) {});
                                                },
                                                label: const Text("Update"),
                                                icon: const Icon(Icons.update))),
                                ],
                              )),
                              const SizedBox(height: 20),
                              const Text("ERP Server", textScaleFactor: 2),
                              Card(
                                  child: Column(
                                children: [
                                  if (AppUser.havePermissionFor(NsPermissions.ADMIN_ERP_SERVER_IS_NOT_WORKING))
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
                                              return (AppUser.havePermissionFor(NsPermissions.ADMIN_OTP_EMAILS))
                                                  ? ListTile(
                                                      title: Container(
                                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), color: Colors.grey.shade200),
                                                      child: SizedBox(
                                                        height: 50,
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(left: 0.0),
                                                          child: TextFormField(
                                                            decoration: InputDecoration(
                                                                fillColor: Colors.transparent,
                                                                focusColor: Colors.transparent,
                                                                border: InputBorder.none,
                                                                focusedBorder: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.circular(24.0),
                                                                ),
                                                                enabledBorder: InputBorder.none,
                                                                hintText: 'Email',
                                                                hintStyle: const TextStyle(color: Colors.grey),
                                                                prefixIcon: const Icon(Icons.email_rounded)),
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
                                                          ),
                                                        ),
                                                      ),
                                                    ))
                                                  : Container();
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
    Api.post(EndPoints.admin_settings_setSetting, {'setting': settingName, 'value': value}).then((res) {
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
    Api.get(EndPoints.admin_settings_getSettings, {}).then((res) {
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

  void setLoading(String s) {
    setState(() {
      _loadings[s] = true;
    });
  }

  bool isLoading(String s) {
    return _loadings[s] == true;
  }

  void removeLoading(String s) {
    setState(() {
      _loadings.removeWhere((key, value) => key == s);
    });
  }
}
