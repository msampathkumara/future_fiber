import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:smartwind/C/Api.dart';
import 'package:smartwind/M/Enums.dart';

class AddTicket extends StatefulWidget {
  final bool standard;
  final Production? production;

  const AddTicket({Key? key, this.standard = false, this.production}) : super(key: key);

  @override
  State<AddTicket> createState() => _AddTicketState();

  void show(context) {
    kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _AddTicketState extends State<AddTicket> {
  late DropzoneViewController controller1;
  late DropzoneViewController controller2;
  String message1 = 'Drop something here';
  String message2 = 'Drop something here';
  bool highlighted1 = false;
  List<UploadFile> fileList = [];

  late bool standard;
  Production? production;

  @override
  initState() {
    standard = widget.standard;
    production = widget.production;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int errorCount = fileList.where((element) => element.haveError).length;
    var width = MediaQuery.of(context).size.width;
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: (width - 1000) > 10 ? EdgeInsets.fromLTRB((width - 1000) / 2, 16, (width - 1000) / 2, 16) : const EdgeInsets.all(16),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Scaffold(
              appBar: AppBar(title: Text(standard ? "Upload Standard Ticket (${production?.getValue()})" : "Upload Ticket")),
              backgroundColor: Colors.white,
              body: Row(
                children: [
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 500, maxWidth: 500),
                      width: 500,
                      color: highlighted1 ? Theme.of(context).primaryColor : Colors.transparent,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          buildZone1(context),
                          Center(
                              child: Wrap(
                            direction: Axis.vertical,
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("Drop ticket PDF here", textScaleFactor: 2),
                              ),
                              const Padding(padding: EdgeInsets.all(8.0), child: Text("Or")),
                              OutlinedButton(
                                  onPressed: () async {
                                    var z = await controller1.pickFiles(mime: ['application/pdf']);

                                    for (var file in z) {
                                      UploadFile uploadFile = UploadFile(file, standard, production);
                                      fileList.add(uploadFile);
                                      print('Zone 1 drop: ${uploadFile.name}');
                                      setState(() {
                                        highlighted1 = false;
                                      });
                                      final bytes = await controller1.getFileData(file);

                                      uploadFile.bytes = (bytes);

                                      uploadFile.upload(() {
                                        setState(() {});
                                      });
                                    }
                                  },
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
                                  ),
                                  child: const Text('Pick file'))
                            ],
                          )),
                        ],
                      ),
                    ),
                  ),
                  if (fileList.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: VerticalDivider(color: Theme.of(context).primaryColor),
                    ),
                  if (fileList.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: 500,
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.separated(
                                itemCount: fileList.length,
                                itemBuilder: (context, index) {
                                  var f = fileList[index];
                                  return ListTile(
                                      title: Text("${f.name}"),
                                      trailing: SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: f.haveError
                                              ? const Icon(Icons.error_rounded, color: Colors.red)
                                              : (f.errorMessage != null
                                                  ? const Icon(Icons.error, color: Colors.red)
                                                  : f.uploaded
                                                      ? const Icon(Icons.done, color: Colors.green)
                                                      : const CircularProgressIndicator(strokeWidth: 2))),
                                      subtitle: f.haveError
                                          ? Row(children: [
                                              const Text("failed to upload "),
                                              TextButton(
                                                  onPressed: () {
                                                    f.upload(() {
                                                      setState(() {});
                                                    });
                                                    setState(() {});
                                                  },
                                                  child: const Text("retry ?"))
                                            ])
                                          : f.errorMessage != null
                                              ? Text(f.errorMessage ?? '', style: const TextStyle(color: Colors.red))
                                              : Text(f.uploaded ? ("Uploaded") : "uploading"));
                                },
                                separatorBuilder: (BuildContext context, int index) {
                                  return const Divider();
                                },
                              ),
                            ),
                            Container(
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                    title: Text("${fileList.length} Files Uploading"),
                                    trailing: Text("${fileList.where((element) => element.uploaded).length} / ${fileList.length} "),
                                    subtitle: errorCount > 0
                                        ? Row(
                                            children: [
                                              Text("$errorCount of ${fileList.length} failed to upload "),
                                              TextButton(
                                                onPressed: () {
                                                  fileList.where((element) => element.haveError).forEach((element) {
                                                    element.upload(() {
                                                      setState(() {});
                                                    });
                                                  });
                                                  setState(() {});
                                                },
                                                child: const Text("retry ?"),
                                              ),
                                            ],
                                          )
                                        : null),
                              ),
                            )
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
          mime: const ['application/pdf'],
          operation: DragOperation.copy,
          cursor: CursorType.grab,
          onCreated: (ctrl) => controller1 = ctrl,
          onLoaded: () => print('Zone 1 loaded'),
          onError: (ev) => print('Zone 1 error: $ev'),
          onHover: () {
            setState(() => highlighted1 = true);
            // print('Zone 1 hovered');
          },
          onLeave: () {
            setState(() => highlighted1 = false);
            // print('Zone 1 left');
          },
          onDrop: (ev) async {
            onDrop(ev);
          },
          onDropMultiple: (ev) async {
            print('Zone 1 drop multiple: $ev');

            for (var file in ev ?? []) {
              onDrop(file);
            }
          },
        ),
      );

  Future<void> onDrop(ev) async {
    UploadFile uploadFile = UploadFile(ev, standard, production);

    fileList.add(uploadFile);
    print('Zone 1 drop: ${uploadFile.name}');
    setState(() {
      highlighted1 = false;
    });
    final bytes = await controller1.getFileData(ev);

    uploadFile.bytes = (bytes);

    uploadFile.upload(() {
      setState(() {});
    });
  }
}

class UploadFile {
  var error;
  late bool standard;
  Production? production;

  String? errorMessage;

  UploadFile(this.file, this.standard, this.production);

  final file;
  int sent = 0;
  int total = 0;
  bool uploaded = false;

  get name => file.name;

  get haveError => error != null;

  Uint8List? _bytes;

  set bytes(Uint8List bytes) => _bytes = bytes;

  getProgress() {
    return (sent / total * 100).toStringAsFixed(0);
  }

  void upload(Null Function() callback) {
    error = null;
    if (_bytes == null || name == null) {
      print('------------------------------- null');
      return;
    }
    FormData formData = FormData.fromMap({"ticket": MultipartFile.fromBytes(_bytes!, filename: name), "production": standard ? production?.getValue() : ''});
    print(standard ? ("tickets/standard/upload") : ("tickets/upload"));
    Api.post(standard ? ("tickets/standard/upload") : ("tickets/upload"), {}, formData: formData, onSendProgress: (int sent, int total) {
      sent = sent;
      total = total;
      print('progress: ${getProgress()}% ($sent/$total)');
    }).then((value) {
      Map m = value.data;

      if (m['error'] == true) {
        errorMessage = m['invalidFileName'] == true ? 'Invalid File Name' : null;
      }

      uploaded = true;
    }).onError((error, stackTrace) {
      this.error = error;
    }).whenComplete(() {
      callback();
    });
  }
}
