import "package:collection/collection.dart";
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:group_list_view/group_list_view.dart';
import 'package:smartwind_future_fibers/M/EndPoints.dart';
import 'package:smartwind_future_fibers/M/user_permission.dart';
import 'package:smartwind_future_fibers/Web/Widgets/DialogView.dart';
import 'package:smartwind_future_fibers/Web/Widgets/IfWeb.dart';

import '../../../../C/Api.dart';

class PermissionsSelector extends StatefulWidget {
  const PermissionsSelector({Key? key}) : super(key: key);

  @override
  State<PermissionsSelector> createState() => _PermissionsSelectorState();

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _PermissionsSelectorState extends State<PermissionsSelector> {
  @override
  void initState() {
    // TODO: implement initState
    loadPermissions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getUi(), child: DialogView(child: getWebUi()));
  }

  List<UserPermission> userPermissions = [];
  Map saving = {};
  late Map<String, List<UserPermission>> userPermissionsGrouped = {};

  void loadPermissions() {
    Api.get(EndPoints.permissions_permissionsList, {}).then((value) {
      Map data = value.data;
      userPermissions = UserPermission.fromJsonArray(data['permissions']);
      userPermissionsGrouped = groupBy(userPermissions, (a) => a.category);
      setLoading(false);
    });
  }

  getWebUi() {
    return Scaffold(
        body: Expanded(
      child: Padding(
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
    ));
  }

  getUi() {}
  var isLoading = true;

  void setLoading(bool bool) {
    setState(() {
      isLoading = bool;
    });
  }
}
