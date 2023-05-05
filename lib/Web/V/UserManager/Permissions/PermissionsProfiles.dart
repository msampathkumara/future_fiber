import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind_future_fibers/M/EndPoints.dart';
import 'package:smartwind_future_fibers/Web/Widgets/DialogView.dart';
import 'package:smartwind_future_fibers/Web/Widgets/IfWeb.dart';

import '../../../../C/Api.dart';
import '../../../../M/User/PermissionProfile.dart';

class PermissionsProfiles extends StatefulWidget {
  final Function(List<int>) onSelect;

  const PermissionsProfiles(this.onSelect, {Key? key}) : super(key: key);

  @override
  State<PermissionsProfiles> createState() => _PermissionsProfilesState();

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _PermissionsProfilesState extends State<PermissionsProfiles> {
  @override
  void initState() {
    loadProfiles();
    super.initState();
  }

  var isLoading = true;

  void setLoading(bool bool) {
    setState(() {
      isLoading = bool;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getUi(), child: DialogView(width: 300, height: 400, child: getWebUi()));
  }

  getWebUi() {
    return isLoading
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : Scaffold(
            appBar: AppBar(title: Text("${permissionProfileList.length}")),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.separated(
                itemCount: (permissionProfileList.length + 1),
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider();
                },
                itemBuilder: (BuildContext context, int index) {
                  print('index == $index');

                  if (permissionProfileList.length == index) {
                    return const Text("ddddddddd", style: TextStyle(color: Colors.red));
                  }
                  var permissionProfile = permissionProfileList.elementAt(index);

                  return ListTile(
                      title: Text(permissionProfile.name),
                      onTap: () {
                        widget.onSelect(permissionProfile.permissions);
                      });
                },
              ),
            ));
  }

  getUi() {}

  List<PermissionProfile> permissionProfileList = [];

  loadProfiles() {
    setLoading(true);
    Api.get(EndPoints.permissions_profilesList, {}).then((res) {
      Map data = res.data;
      permissionProfileList = PermissionProfile.fromJsonArray(data['profiles']);
    }).whenComplete(() {
      setLoading(false);
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err.toString()),
          action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                loadProfiles();
              })));
      setState(() {
        // _dataLoadingError = true;
      });
    });
  }
}
