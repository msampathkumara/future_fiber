import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:smartwind/C/Api.dart';

class AddTicket extends StatefulWidget {
  const AddTicket({Key? key}) : super(key: key);

  @override
  State<AddTicket> createState() => _AddTicketState();

  void show(context) {
    kIsWeb
        ? showDialog(
            context: context,
            builder: (_) => this,
          )
        : Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => this),
          );
  }
}

class _AddTicketState extends State<AddTicket> {
  late DropzoneViewController controller1;
  late DropzoneViewController controller2;
  String message1 = 'Drop something here';
  String message2 = 'Drop something here';
  bool highlighted1 = false;
  List<UploadFile> fileList = [];

  @override
  Widget build(BuildContext context) {
    int errorCount = fileList.where((element) => element.haveError).length;
    var width = MediaQuery.of(context).size.width;
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: (width - 1000) > 10 ? EdgeInsets.fromLTRB((width - 1000) / 2, 16, (width - 1000) / 2, 16) : EdgeInsets.all(16),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Scaffold(
              appBar: AppBar(title: Text("Upload Ticket")),
              backgroundColor: Colors.white,
              body: Row(
                children: [
                  Expanded(
                    child: Container(
                      constraints: BoxConstraints(minWidth: 500, maxWidth: 500),
                      width: 500,
                      color: highlighted1 ? Colors.lightBlue : Colors.transparent,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          buildZone1(context),
                          Center(
                              child: Wrap(
                            direction: Axis.vertical,
                            alignment: WrapAlignment.center,
                            children: [
                              Text(message1),
                              ElevatedButton(
                                onPressed: () async {
                                  print(await controller1.pickFiles(mime: ['application/pdf']));
                                },
                                child: const Text('Pick file'),
                              )
                            ],
                          )),
                        ],
                      ),
                    ),
                  ),
                  if (fileList.length > 0)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        width: 500,
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                child: ListView.separated(
                                  itemCount: fileList.length,
                                  itemBuilder: (context, index) {
                                    var f = fileList[index];
                                    return ListTile(
                                        title: Text("${f.name}"),
                                        trailing: SizedBox(
                                            child: f.haveError
                                                ? Icon(Icons.error_rounded, color: Colors.red)
                                                : (f.uploaded ? Icon(Icons.done, color: Colors.green) : CircularProgressIndicator(strokeWidth: 2)),
                                            height: 20,
                                            width: 20),
                                        subtitle: f.haveError
                                            ? Row(children: [
                                                Text("failed to upload "),
                                                TextButton(
                                                    onPressed: () {
                                                      f.upload(() {
                                                        setState(() {});
                                                      });
                                                      setState(() {});
                                                    },
                                                    child: Text("retry ?"))
                                              ])
                                            : Text(f.uploaded ? ("Uploaded") : "uploading"));
                                  },
                                  separatorBuilder: (BuildContext context, int index) {
                                    return Divider();
                                  },
                                ),
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
                                              Text("${errorCount} of ${fileList.length} failed to upload "),
                                              TextButton(
                                                onPressed: () {
                                                  fileList.where((element) => element.haveError).forEach((element) {
                                                    element.upload(() {
                                                      setState(() {});
                                                    });
                                                  });
                                                  setState(() {});
                                                },
                                                child: Text("retry ?"),
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
          mime: ['application/pdf'],
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
            UploadFile uploadFile = UploadFile(ev);

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

            print(bytes.sublist(0, 20));
          },
          onDropMultiple: (ev) async {
            print('Zone 1 drop multiple: $ev');
          },
        ),
      );
}

class UploadFile {
  var error;

  UploadFile(this.file);

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
    FormData formData = FormData.fromMap({
      "ticket": MultipartFile.fromBytes(_bytes!, filename: name),
    });

    Api.post(("tickets/upload"), {}, formData: formData, onSendProgress: (int sent, int total) {
      sent = sent;
      total = total;
      print('progress: ${getProgress()}% ($sent/$total)');
    }).then((value) {
      uploaded = true;
    }).onError((error, stackTrace) {
      this.error = error;
    }).whenComplete(() {
      callback();
    });
  }
}
