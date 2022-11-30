import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:smartwind/M/EndPoints.dart';
import 'package:smartwind/Web/V/SheetData/ErrorSheetObjectList.dart';
import 'package:uuid/uuid.dart';

import '../../../C/Api.dart';

class AddSheet extends StatefulWidget {
  final bool isUpdate;

  const AddSheet({Key? key, this.isUpdate = false}) : super(key: key);

  @override
  State<AddSheet> createState() => _AddSheetState();

  void show(context) {
    kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _AddSheetState extends State<AddSheet> {
  late DropzoneViewController controller1;
  late DropzoneViewController controller2;
  String message1 = 'Drop something here';
  String message2 = 'Drop something here';
  bool highlighted1 = false;

  bool sheetUploading = false;
  bool sheetUploadingDone = false;
  bool sheetUploadingError = false;
  String errorMessage = "";

  String? progressMsg;

  List errorObjects = [];

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: (width - 1000) > 10 ? EdgeInsets.fromLTRB((width - 1000) / 2, 16, (width - 1000) / 2, 16) : const EdgeInsets.all(16),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Scaffold(
              appBar: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: widget.isUpdate ? Colors.red : null,
                  actions: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                  title: widget.isUpdate ? const Text("Upload Updated Data Sheet") : const Text("Upload Data Sheet"),
                  centerTitle: true),
              backgroundColor: Colors.white,
              body: Row(
                children: [
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 500, maxWidth: 500),
                      width: 500,
                      child: sheetUploadingError
                          ? Center(
                              child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.error_rounded, color: Colors.red, size: 48),
                                ),
                                Text(errorMessage == 'error objects' ? "Found Some data with error. please fix them and upload sheet again" : errorMessage,
                                    style: const TextStyle(color: Colors.red)),
                                if (errorMessage == 'error objects')
                                  Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: ElevatedButton(
                                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                                        onPressed: () => {ErrorSheetObjectList(errorObjects).show(context)},
                                        child: const Text("Show Error Data", style: TextStyle(color: Colors.white))),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: ElevatedButton(onPressed: reset, child: const Text("Upload Another")),
                                )
                              ],
                            ))
                          : sheetUploadingDone
                              ? Center(
                                  child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(Icons.done_rounded, color: Colors.green, size: 48),
                                    ),
                                    const Text("Done"),
                                    Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: ElevatedButton(onPressed: reset, child: const Text("Upload Another")),
                                    )
                                  ],
                                ))
                              : sheetUploading
                                  ? Center(
                                      child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: CircularProgressIndicator(),
                                        ),
                                        Text(progressMsg ?? "Uploading data")
                                      ],
                                    ))
                                  : Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(64.0),
                                          child: DottedBorder(
                                            color: highlighted1 ? Theme.of(context).primaryColor : Colors.black,
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
                    ),
                  )
                ],
              ),
            )),
      ),
    );
  }

  Widget buildZone1(BuildContext context) => Builder(
        builder: (context) => DropzoneView(
          mime: const ['text/csv', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'],
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

  void reset() {
    sheetUploading = false;
    sheetUploadingDone = false;
    sheetUploadingError = false;
    errorMessage = "";
    setState(() {});
  }

  var uuid = const Uuid();

  Future<void> upload(ev) async {
    var id = uuid.v4();
    DatabaseReference ref = FirebaseDatabase.instance.ref('sheetUploadProgress/$id');
    ref.onValue.listen((DatabaseEvent event) {
      Map<dynamic, dynamic>? data = event.snapshot.value as Map?;
      setState(() {
        if (data != null) progressMsg = data["progress"];
      });
    });

    final bytes = await controller1.getFileData(ev);
    FormData formData = FormData.fromMap({"sheet": MultipartFile.fromBytes(bytes, filename: ev.name), 'id': id, 'isUpdate': widget.isUpdate});

    Api.post((EndPoints.sheet_upload), {}, formData: formData, onSendProgress: (int sent, int total) {}).then((value) {
      print('done');
      print(value.data["err"]);

      if (value.data["err"] == true) {
        errorMessage = value.data["errorMsg"];
        errorObjects = value.data["objects"];
        sheetUploadingError = true;
      } else {
        sheetUploadingDone = true;
      }
      setState(() {});
    }).onError((error, stackTrace) {
      print(error);
      print(stackTrace);
      sheetUploadingError = true;
      errorMessage = stackTrace.toString();
      print('error');
    }).whenComplete(() {
      print('Complete');
      setState(() {});
    });
    sheetUploading = true;
    setState(() {});
  }
}
