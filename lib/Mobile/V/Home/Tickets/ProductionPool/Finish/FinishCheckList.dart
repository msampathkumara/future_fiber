import 'dart:convert';

import 'package:dart_ping/dart_ping.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartwind_future_fibers/C/Api.dart';
import 'package:smartwind_future_fibers/C/Server.dart';
import 'package:smartwind_future_fibers/C/ServerResponse/OperationMinMax.dart';
import 'package:smartwind_future_fibers/M/AppUser.dart';
import 'package:smartwind_future_fibers/M/Ticket.dart';
import 'package:smartwind_future_fibers/Mobile/V/Home/Tickets/ProductionPool/Finish/SelectSectionBottomSheet.dart';
import 'package:smartwind_future_fibers/res.dart';
import 'package:uuid/uuid.dart';

import '../../../../../../C/ServerResponse/ServerResponceMap.dart';
import '../../../../../../M/EndPoints.dart';
import '../../../../../../globals.dart';
import 'PingFailedError.dart';
import 'RF.dart';
import 'package:dio/dio.dart';

class FinishCheckList extends StatefulWidget {
  final Ticket ticket;

  const FinishCheckList(this.ticket, {Key? key}) : super(key: key);

  @override
  _FinishCheckListState createState() {
    return _FinishCheckListState();
  }
}

class _FinishCheckListState extends State<FinishCheckList> {
  Map? checkListMap;

  late Ticket ticket;

  bool erpNotWorking = false;

  @override
  void initState() {
    super.initState();
    ticket = widget.ticket;
    firebaseDatabase.child("settings").once().then((DatabaseEvent databaseEvent) {
      DataSnapshot result = databaseEvent.snapshot;

      erpNotWorking = result.child("erpNotWorking").value == 1;
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _loadData(), // async work
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Text('Loading....');
            default:
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return AlertDialog(
                    actions: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, textStyle: const TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () async {
                            await finish("Excellent").then((value) {
                              Navigator.of(context).pop(true);
                            });
                          },
                          child: const Text("Excellent")),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen, textStyle: const TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () async {
                            await finish("Good").then((value) {
                              Navigator.of(context).pop(true);
                            });
                          },
                          child: const Text("Good")),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, textStyle: const TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () async {
                            var isQc = false;
                            var selectedSection = AppUser.getSelectedSection()?.id;
                            if (AppUser.getSelectedSection()?.sectionTitle.toLowerCase() == "qc") {
                              isQc = true;
                              selectedSection = await selectSection();
                              if (selectedSection == null) return;
                            }
                            var userCurrentSection = AppUser.getSelectedSection()?.id ?? 0;

                            await platform.invokeMethod('qcEdit', {
                              'userCurrentSection': userCurrentSection.toString(),
                              "qc": isQc,
                              "sectionId": "$selectedSection",
                              "serverUrl": await Server.getServerApiPath(EndPoints.tickets_qc_uploadEdits),
                              'ticket': {'id': ticket.id, "qc": isQc}.toString()
                            });
                            if (mounted) {
                              Navigator.pop(context, true);
                            }
                          },
                          child: const Text("Quality Reject"))
                    ],
                    content: SizedBox(
                        height: 200,
                        child: Scaffold(
                            body: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: const [
                          Text("Please Rate the quality of your work", textScaleFactor: 1.5, textAlign: TextAlign.center),
                          Text("කරුණාකර ඔබගේ කාර්යය ගුණාත්මකභාවය ඇගයීමට ලක්කරන්න", textScaleFactor: 1.2, textAlign: TextAlign.center)
                        ]))));
              }
          }
        });
  }

  static const platform = MethodChannel('editPdf');

  _loadData() async {
    var x = DefaultAssetBundle.of(context);
    var data = await x.loadString(Res.QACheckList);
    checkListMap = json.decode(data);
    return checkListMap;
  }

  Future<void> finish(String quality) async {
    var isQc = false;
    int? selectedSection = AppUser.getSelectedSection()?.id;
    if (AppUser.getSelectedSection()?.sectionTitle.toLowerCase() == "qc") {
      isQc = true;
    }

    var r = await Api.get(EndPoints.tickets_finish_getProgress, {'ticket': ticket.id.toString()});
    ServerResponseMap res1 = ServerResponseMap.fromJson((r.data));

    print('res1 ${res1.toJson()}');

    if (mounted) await Ticket.getFile(ticket, context);
    if (res1.done != null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.red, content: Text('Already Completed')));
    } else if (ticket.ticketFile != null) {
      print('erpNotWorking $erpNotWorking');

      // bool pingOk = await LoadingDialog(ping());
      // print('pingOk $pingOk');

      // return;

      if (erpNotWorking) {
        await showErpNotAvailableMsg(quality, isQc, selectedSection, res1.operationMinMax!);
        // await LoadingDialog(Api.post(EndPoints.tickets_qc_uploadEdits, {'quality': quality, 'ticketId': ticket.id, 'type': isQc, "sectionId": selectedSection}).then((res) {
        //   Map data = res.data;
        // }));
      } else if (mounted) {
        // Begin ping process and listen for output
        bool pingOk = await LoadingDialog(ping());

        // this will run when ping failed
        if (!pingOk) {
          if (mounted) {
            await showErpNotAvailableMsg(quality, isQc, selectedSection, res1.operationMinMax!);
          }
        } else {
          if (mounted) {
            var uuid = const Uuid();
            var x = await RF(ticket, res1.operationMinMax!, res1.ticketProgressDetails, key: Key(uuid.v1())).show(context);
            if (x != null || x == true) {
              await LoadingDialog(Api.post(EndPoints.tickets_qc_uploadEdits, {'quality': quality, 'ticketId': ticket.id, 'type': isQc, "sectionId": selectedSection}).then((res) {
                Map data = res.data;
              }));
            }
          }
        }
      }
    }
  }

  Future<bool> ping() async {
    // var address='https://v2.smartwind.nsslsupportservices.com';
    var address = 'http://10.200.4.24/WebClient/default.aspx';

    BaseOptions options = BaseOptions(baseUrl: address, connectTimeout: const Duration(seconds: 5), receiveTimeout: const Duration(seconds: 15));
    Dio dio = Dio(options);

    return dio.get(address).then((value) {
      return true;
    }).onError((error, stackTrace) {
      return false;
    });

    // final ping = Ping('v2.smartwind.nsslsupportservices.com', count: 2);
    final ping = Ping('10.200.4.24', count: 2);
    await for (final event in ping.stream) {
      print('ping event-----------------------');
      print(event);

      final summary = event.summary;
      if (summary != null) {
        print('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ${summary.received > 0}');
        return summary.received > 0;
      }
    }
    print('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
    return false;
  }

  Future LoadingDialog(Future future) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context1) {
          future.then((value) {
            Navigator.of(context1).pop(value);
          });

          return AlertDialog(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
              content: Builder(builder: (context) {
                return const SizedBox(height: 150, width: 50, child: Center(child: SizedBox(height: 50, width: 50, child: CircularProgressIndicator())));
              }));
        });
  }

  Future<int?> selectSection() async {
    int? selectedSectionId;

    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SelectSectionBottomSheet(widget.ticket.id, (_selectedSectionId) {
          selectedSectionId = _selectedSectionId;
        });
      },
    );
    return selectedSectionId;
  }

  Future<void> showErpNotAvailableMsg(quality, isQc, selectedSection, OperationMinMax operationMinMax) async {
    bool? b = await const PingFailedError().show(context);
    if (b == true) {
      await finish_(selectedSection, operationMinMax);

      await LoadingDialog(Api.post(EndPoints.tickets_qc_uploadEdits, {'quality': quality, 'ticketId': ticket.id, 'type': isQc, "sectionId": selectedSection}).then((res) {
        Map data = res.data;
        print(data);

        snackBarKey.currentState?.showSnackBar(
            SnackBar(content: const Text("Done"), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)), width: 200));
      }));
    } else {
      print("nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn");
    }
  }

  Future finish_(selectedSection, OperationMinMax operationMinMax) async {
    return await LoadingDialog(Api.post(
            EndPoints.tickets_finish, {'erpDone': 0, 'ticket': ticket.id.toString(), 'userSectionId': AppUser.getSelectedSection()?.id, 'doAt': operationMinMax.doAt.toString()})
        .then((res) {
      Map data = res.data;
      print(data);

      if (data["errorResponce"] != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${data["errorResponce"]["message"]}"), backgroundColor: Colors.red));
      }
      return data["errorResponce"] == null;
    }));
  }
}
