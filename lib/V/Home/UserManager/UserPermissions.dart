import "package:collection/collection.dart";
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:group_list_view/group_list_view.dart';
import 'package:smartwind/M/Enums.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/M/user_permission.dart';
import 'package:smartwind/V/Widgets/SearchBar.dart';
import 'package:smartwind/Web/Widgets/DialogView.dart';

import '../../../C/OnlineDB.dart';

class UserPermissions extends StatefulWidget {
  final NsUser nsUser;

  UserPermissions(this.nsUser, {Key? key}) : super(key: Key("${nsUser.id}"));

  @override
  _UserPermissionsState createState() {
    return _UserPermissionsState();
  }

  show(context) {
    kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _UserPermissionsState extends State<UserPermissions> {
  var isLoading = true;

  var searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    loadPermissions();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<UserPermission> userPermissions = [];
  List<UserPermission> _userPermissions = [];
  Map saving = {};

  @override
  Widget build(BuildContext context) {
    return kIsWeb ? DialogView(child: getUi(), width: 500) : getUi();
  }

  getUi() {
    return isLoading
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : Scaffold(
            appBar: AppBar(
              title: const Text("Set User Permissions"),
              bottom: SearchBar(
                  delay: 300,
                  onSearchTextChanged: (t) {
                    _userPermissions = userPermissions.where((e) => t.containsInArrayIgnoreCase([e.name, e.category, e.description])).toList();
                    userPermissionsGrouped = groupBy(_userPermissions, (a) => a.category);
                    setState(() {});
                  },
                  searchController: searchController),
              toolbarHeight: 100,
            ),
            body: Padding(
              padding: const EdgeInsets.only(bottom: 62.0),
              child: Column(
                children: [
                  Expanded(
                    child: GroupListView(
                        sectionsCount: userPermissionsGrouped.keys.toList().length,
                        countOfItemInSection: (int section) {
                          return userPermissionsGrouped.values.toList()[section].length;
                        },
                        itemBuilder: (BuildContext context, IndexPath index) {
                          UserPermission userPermission = userPermissionsGrouped.values.toList()[index.section][index.index];
                          return Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: SwitchListTile(
                              title: Text(userPermission.name, textScaleFactor: 1),
                              subtitle: Text(userPermission.description),
                              value: userPermission.hasPermit,
                              onChanged: (bool value) {
                                setState(() {
                                  userPermission.permit = value ? 1 : 0;
                                  print(userPermissions.where((element) => element.permit == 1));
                                });
                              },
                            ),
                          );
                        },
                        groupHeaderBuilder: (BuildContext context, int section) {
                          String catName = userPermissionsGrouped.keys.toList()[section];
                          return ListTile(
                              title: Text(catName.isEmpty ? 'Other' : catName, textScaleFactor: 1, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                              tileColor: Colors.grey.shade100);
                        },
                        separatorBuilder: (context, index) => const Divider(
                              height: 0.1,
                            )),
                  ),
                ],
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                save();
              },
              child: const Icon(Icons.save_rounded, size: 24, color: Colors.white),
            ),
          );
  }

  late Map<String, List<UserPermission>> userPermissionsGrouped = {};

  void loadPermissions() {
    OnlineDB.apiGet("permissions/userPermissions", {'userId': widget.nsUser.id}).then((value) {
      Map data = value.data;
      userPermissions = UserPermission.fromJsonArray(data['userPermissions']);
      userPermissionsGrouped = groupBy(userPermissions, (a) => a.category);
      setLoading(false);
    });
  }

  void save() {
    setLoading(true);
    List permitionsIds = userPermissions.where((element) => element.permit == 1).map((e) => e.id).toList();

    OnlineDB.apiPost("permissions/saveUserPermissions", {'userId': widget.nsUser.id, 'permissions': permitionsIds}).then((v) {
      setLoading(false);
    });
  }

  void setLoading(bool bool) {
    setState(() {
      isLoading = bool;
    });
  }
}
