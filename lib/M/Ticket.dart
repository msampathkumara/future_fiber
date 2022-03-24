import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smartwind/C/OnlineDB.dart';
import 'package:smartwind/C/Server.dart';
import 'package:smartwind/M/StandardTicket.dart';
import 'package:smartwind/M/TicketFlag.dart';
import 'package:smartwind/V/Home/CPR/AddCPR.dart';
import 'package:smartwind/V/Home/Tickets/CS/CS.dart';
import 'package:smartwind/V/Home/Tickets/ShippingSystem/ShippingSystem.dart';
import 'package:smartwind/V/Widgets/ErrorMessageView.dart';
import 'package:smartwind/V/Widgets/Loading.dart';
import 'package:smartwind/V/Widgets/TicketPdfViwer.dart';

import 'DataObject.dart';
import 'LocalFileVersion.dart';
import 'hive.dart';

part 'Ticket.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 1)
class Ticket extends DataObject {
  @HiveField(0, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? mo;

  @HiveField(1, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? oe;

  @HiveField(2, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int finished = 0;

  @HiveField(3, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int uptime = 0;

  @HiveField(4, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int file = 0;

  @HiveField(5, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int sheet = 0;

  @HiveField(6, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int dir = 0;

  @HiveField(7, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int id = 0;

  @HiveField(8, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int isRed = 0;

  @HiveField(9, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int isRush = 0;

  @HiveField(10, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int isSk = 0;

  @HiveField(11, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int inPrint = 0;

  @HiveField(12, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int isGr = 0;

  @HiveField(13, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int isError = 0;

  @HiveField(14, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int canOpen = 1;

  @HiveField(15, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int isSort = 0;

  @HiveField(16, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int isHold = 0;

  @HiveField(17, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int fileVersion = 0;

  @HiveField(18, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int progress = 0;

  @HiveField(19, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int completed = 0;

  @HiveField(20, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int nowAt = 0;

  @HiveField(21, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int crossPro = 0;

  @HiveField(22, defaultValue: '')
  @JsonKey(defaultValue: "", includeIfNull: true)
  String crossProList = "";

  @HiveField(23, defaultValue: [])
  @JsonKey(defaultValue: [], includeIfNull: true, fromJson: stringToList)
  List openSections = [];

  @HiveField(24, defaultValue: '')
  @JsonKey(defaultValue: "", includeIfNull: true)
  String shipDate = "";

  @HiveField(25, defaultValue: '')
  @JsonKey(defaultValue: "", includeIfNull: true)
  String deliveryDate = "";

  @HiveField(26, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? production;

  @JsonKey(ignore: true)
  File? ticketFile;

  Ticket();

  static stringToList(string) => (string == null || string.toString().isEmpty) ? [] : json.decode(string);

  String getUpdateDateTime() {
    var date = DateTime.fromMicrosecondsSinceEpoch(uptime * 1000);
    var formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
    return formattedDate;
  }

  int getLocalFileVersion() {
    try {
      var f = HiveBox.localFileVersionsBox.values.where((element) => element.type == TicketTypes.Ticket.getValue() && element.ticketId == id).first;
      return f.version;
    } catch (e) {
      return 0;
    }
  }

  Future<File?> _getFile(context, {onReceiveProgress}) async {
    var loadingWidget = Loading(
      loadingText: "Downloading Ticket",
    );
    loadingWidget.show(context);

    var dio = Dio();
    var ed = await getExternalStorageDirectory();
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user!.getIdToken();
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = '$idToken';
    String queryString = Uri(queryParameters: {"id": id.toString()}).query;
    var filePath = isStandard ? ed!.path + '/st$id.pdf' : ed!.path + '/$id.pdf';

    var response;
    try {
      var path = isStandard ? "tickets/standard/getPdf?" : 'tickets/getTicketFile?';

      await dio.download(Server.getServerApiPath(path + queryString), filePath, deleteOnError: true, onReceiveProgress: (received, total) {
        // print("${received}/${total}");
        int percentage = ((received / total) * 100).floor();
        loadingWidget.setProgress(percentage);
        if (onReceiveProgress != null) {
          onReceiveProgress(percentage);
        }
      }).then((value) async {
        response = value;
        print('+++++++++++++++++++++++++++++++++++++++++++++');
        print(response.headers["fileVersion"]);
        String fileVersion = response.headers["fileVersion"][0];
        await setLocalFileVersion(int.parse(fileVersion), getTicketType());
      });
    } on DioError catch (e) {
      if (e.response != null) {
        print('"******************************************** response');
        print(e.response);
        if (e.response!.statusCode == 404) {
          loadingWidget.close(context);
          var errorView = ErrorMessageView(
            errorMessage: "File Not Found",
            icon: Icons.sd_card_alert,
          );
          await errorView.show(context);
          return Future.value(null);
        }

        print(e.response!.statusCode);
        print(e.response!.data);
        print(e.response!.headers);
      } else {
        print(e.message);
      }
    }

    loadingWidget.close(context);
    File file = new File(filePath);
    ticketFile = file;
    return file;
  }

  Future<File?> getFile(context, {onReceiveProgress}) async {
    File file = await getLocalFile();
    // var i = await getLocalFileVersion();
    var isNew = await isFileNew();
    if (isNew && file.existsSync()) {
      return ticketFile;
    } else {
      ticketFile = await _getFile(context);
    }
    return ticketFile;
  }

  Future<void> open(context, {onReceiveProgress}) async {
    File file = await getLocalFile();
    var isNew = await isFileNew();

    print('file ${file.existsSync()}');

    if (isNew && file.existsSync()) {
      print("File exists ");
      var data = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TicketPdfViwer(this, onClickEdit: () async {
                    Navigator.of(context).pop();
                    var x = await openEditor();
                    if (x == true) {
                      await HiveBox.getDataFromServer();
                    }
                  })));
    } else {
      print("File not exists or old ");
      _getFile(context).then((file) async {
        if (file != null) {
          var data = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TicketPdfViwer(this, onClickEdit: () async {
                        Navigator.of(context).pop();
                        var x = await openEditor();
                        if (x == true) {
                          await HiveBox.getDataFromServer();
                        }
                      })));
        }
      });
    }
  }

  factory Ticket.fromJson(Map<String, dynamic> json) => _$TicketFromJson(json);

  Map<String, dynamic> toJson() => _$TicketToJson(this);

  Future<File> getLocalFile() async {
    var ed = await getExternalStorageDirectory();
    var filePath = ed!.path + '/$id.pdf';
    File file = new File(filePath);
    ticketFile = file;
    return file;
  }

  Future openEditor() async {
    Map t = toJson();
    t["openSections"] = "";
    t["crossProList"] = "";
    t.keys.where((k) => (t[k] ?? "").toString().isEmpty).toList().forEach(t.remove);
    print("____________________________________________________________________________________________________________________________*****");
    print(t);
    var serverUrl = Server.getServerApiPath(isStandard ? "tickets/standard/uploadEdits" : "tickets/uploadEdits");
    return await platform.invokeMethod('editPdf', {'path': ticketFile!.path, 'fileID': id, 'ticket': t.toString(), "serverUrl": serverUrl});
  }

  static const platform = const MethodChannel('editPdf');

  isFileNew() async {
    var ticket = isStandard ? HiveBox.standardTicketsBox.get(id) : HiveBox.ticketBox.get(id);
    var f = HiveBox.localFileVersionsBox.values.where((element) => element.type == getTicketType().getValue() && element.ticketId == id);
    if (f.isNotEmpty) {
      LocalFileVersion fileVersion = f.first;
      print("---------------------------fileVersion.toJson()");
      print(fileVersion.toJson());
      print(ticket?.fileVersion);

      if (ticket != null) {
        if (ticket.fileVersion > fileVersion.version) {
          return false;
        }
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  setLocalFileVersion(newFileVersion, TicketTypes ticketType) {
    // LocalFileVersion f = HiveBox.fileVersionsBox.values.where((element) => element.type == TicketTypes.Ticket && element.ticketId == id).first;
    // f.version = newFileVersion;
    // HiveBox.localFileVersionsBox.clear();
    var fv = HiveBox.localFileVersionsBox.values
        .singleWhere((value) => (value.type == ticketType.getValue() && value.ticketId == id), orElse: () => LocalFileVersion(id, newFileVersion, ticketType.getValue()));

    print("-------------------------------------------------00000");
    print(fv.toJson());

    fv.version = newFileVersion;
    fileVersion = newFileVersion;

    if (fv.isInBox) {
      fv.save();
    } else {
      HiveBox.localFileVersionsBox.put(ticketType.getValue() + '$id', fv);
    }
  }

  Future<List> getFlagList(String flagType) async {
    print("tickets/flags/getList");
    return OnlineDB.apiGet("tickets/flags/getList", {"ticket": id.toString(), "type": flagType}).then((response) {
      print(response.data);
      print("-----------------vvvvvvvvvvv-----------------------");
      Map<String, dynamic> res = response.data;
      List l = ((res["flags"] ?? []));

      List<TicketFlag> list = List<TicketFlag>.from(l.map((model) {
        return TicketFlag.fromJson(model);
      }));
      print(list.length);
      return list;
    }).catchError((onError) {
      print(onError);
    });
  }

  sharePdf(context) async {
    // var status = await Permission.storage.isDenied;
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }
    File? file = await getFile(context);
    if (file != null && file.existsSync()) {
      print('--------------------- ${file.path}');

      File? file1 = await file.copy("${file.parent.path}/${(mo ?? oe ?? id)}.pdf");
      print('copied');
      await FlutterShare.shareFile(
        chooserTitle: "Share Ticket",
        title: mo ?? oe ?? "$id.pdf",
        text: "share ticket file",
        filePath: file1.path,
      );
      // file.delete();
    } else {
      ErrorMessageView(errorMessage: "File Not Found", icon: Icons.insert_drive_file_outlined).show(context);
    }
  }

  addCPR(BuildContext context) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => AddCPR(this)));
  }

  Future openInShippingSystem(BuildContext context) async {
    await getFile(context);
    return Navigator.push(context, MaterialPageRoute(builder: (context) => ShippingSystem(this)));
  }

  Future openInCS(BuildContext context) async {
    await getFile(context);
    return Navigator.push(context, MaterialPageRoute(builder: (context) => CS(this)));
  }

  getName() {
    return mo ?? oe;
  }

  static List<Ticket> fromJsonArray(tickets) {
    return List<Ticket>.from(tickets.map((model) => Ticket.fromJson(model)));
  }

  get isStandard => this is StandardTicket;

  TicketTypes getTicketType() {
    return isStandard ? TicketTypes.Standard : TicketTypes.Ticket;
  }
}
