import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:deebugee_plugin/DialogView.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';

import '../../../M/CPR/CprItem.dart';

class DropMaterialList extends StatefulWidget {
  const DropMaterialList({Key? key}) : super(key: key);

  @override
  State<DropMaterialList> createState() => _DropMaterialListState();

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _DropMaterialListState extends State<DropMaterialList> {
  @override
  Widget build(BuildContext context) {
    return DialogView(child: getWebUi());
  }

  late DropzoneViewController controller1;
  late DropzoneViewController controller2;
  String message1 = 'Drop something here';
  String message2 = 'Drop something here';
  bool highlighted1 = false;

  bool sheetUploading = false;
  bool sheetUploadingDone = false;
  bool sheetUploadingError = false;
  String errorMessage = "";

  getWebUi() {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close))
      ]),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.all(64.0),
            child: DottedBorder(
              color: highlighted1 ? Colors.lightBlue : Colors.black,
              borderType: BorderType.RRect,
              radius: const Radius.circular(8),
              padding: const EdgeInsets.all(6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: buildZone1(context),
              ),
            ),
          ),
          Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.cloud_upload_rounded, color: Colors.grey, size: 64)),
              const Text("Drop csv file", textScaleFactor: 1),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    List l = (await controller1.pickFiles(mime: ['text/csv']));
                    await upload(l[0]);
                  },
                  child: const Text('Pick file'),
                ),
              )
            ],
          )),
        ],
      ),
    );
  }

  Widget buildZone1(BuildContext context) => Builder(
        builder: (context) => DropzoneView(
          mime: const ['text/csv'],
          operation: DragOperation.copy,
          cursor: CursorType.grab,
          onCreated: (ctrl) => controller1 = ctrl,
          onLoaded: () => print('Zone 1 loaded'),
          onError: (ev) => print('Zone 1 error: $ev'),
          onHover: () {
            setState(() => highlighted1 = true);
            print('Zone 1 hovered');
          },
          onLeave: () {
            setState(() => highlighted1 = false);
            print('Zone 1 left');
          },
          onDrop: (ev) async {
            print('selected');

            await upload(ev);

            print('dddddddddddddddddddddddddddd');
            setState(() => highlighted1 = false);
          },
          onDropMultiple: (ev) async {
            print('Zone 1 drop multiple: $ev');
          },
        ),
      );

  upload(ev) async {
    List<CprItem> cprItems = [];
    await controller1.getFileData(ev).then((bytes) {
      String bar = utf8.decode(bytes);
      List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter().convert(bar);

      for (var element in rowsAsListOfValues) {
        print("${element[0]}---${element[1]} ${element[2]}");

        CprItem item = CprItem();
        item.item = "${element[0]}";
        item.qty = "${element[1]} ${element[2]}";
        cprItems.add(item);
      }

      Navigator.pop(context, cprItems);
    });
  }
}
