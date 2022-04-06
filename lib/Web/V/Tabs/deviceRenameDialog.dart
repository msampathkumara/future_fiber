import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/Device.dart';
import 'package:smartwind/Web/Widgets/DialogView.dart';

class DeviceRenameDialog extends StatefulWidget {
  final Device device;

  const DeviceRenameDialog(this.device, {Key? key}) : super(key: key);

  @override
  State<DeviceRenameDialog> createState() => _DeviceRenameDialogState();

  void show(context) {
    kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _DeviceRenameDialogState extends State<DeviceRenameDialog> {
  @override
  Widget build(BuildContext context) {
    return DialogView(
      child: Stack(
        children: [
          Align(
              alignment: Alignment.topRight,
              child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close))),
          Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 64, 8, 8),
              child: TextFormField(
                initialValue: widget.device.name,
                onFieldSubmitted: (text) {
                  print('xxxxxxxxxx == ${text}');
                },
              )),
        ],
      ),
      width: 400,
      height: 150,
    );
  }
}
