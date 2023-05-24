import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind_future_fibers/M/Device.dart';
import 'package:smartwind_future_fibers/M/EndPoints.dart';
import 'package:deebugee_plugin/DialogView.dart';
import 'package:smartwind_future_fibers/Web/Widgets/DialogView.dart';

import '../../../C/Api.dart';

class DeviceRenameDialog extends StatefulWidget {
  final Device device;

  const DeviceRenameDialog(this.device, {Key? key}) : super(key: key);

  @override
  State<DeviceRenameDialog> createState() => _DeviceRenameDialogState();

  show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _DeviceRenameDialogState extends State<DeviceRenameDialog> {
  bool saving = false;

  @override
  Widget build(BuildContext context) {
    return DialogView(
      width: 400,
      height: 150,
      child: Scaffold(
        appBar: AppBar(actions: const []),
        body: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 8),
            child: TextFormField(
              autovalidateMode: AutovalidateMode.always,
              enabled: !saving,
              validator: (d) {
                return _duplicate ? 'duplicate name' : null;
              },
              initialValue: widget.device.name,
              onFieldSubmitted: (text) {
                if (text.trim().isNotEmpty && text.trim() != widget.device.name) {
                  saving = true;
                  setState(() {});
                  saveName(text);
                }
              },
            )),
      ),
    );
  }

  bool _duplicate = false;

  void saveName(String text) {
    Api.post(EndPoints.tabs_rename, {'name': text, 'id': widget.device.id}).then((res) {
      Map data = res.data;
      if (data['saved'] == true) {
        Navigator.pop(context);
      } else {
        if (data['duplicate'] == true) {
          _duplicate = true;
        }
      }
      saving = false;
      setState(() {});
    }).whenComplete(() {
      setState(() {});
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err.toString()),
          action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                saveName(text);
              })));
      setState(() {
        // _dataLoadingError = true;
      });
    });
  }
}
