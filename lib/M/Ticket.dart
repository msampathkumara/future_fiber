import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smartwind/C/DB/DB.dart';
import 'package:smartwind/C/OnlineDB.dart';
import 'package:smartwind/C/Server.dart';
import 'package:smartwind/M/TicketFlag.dart';
import 'package:smartwind/V/Widgets/ErrorMessageView.dart';
import 'package:smartwind/V/Widgets/Loading.dart';
import 'package:smartwind/V/Widgets/PDFScreen.dart';

part 'Ticket.g.dart';

@JsonSerializable(explicitToJson: true)
class Ticket {
  String? mo;
  String? oe;
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int finished = 0;
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int uptime = 0;
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int file = 0;
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int sheet = 0;
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int dir = 0;
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int id = 0;
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int isRed = 0;
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int isRush = 0;
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int isSk = 0;
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int inPrint = 0;
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int isGr = 0;
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int isError = 0;
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int canOpen = 1;
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int isSort = 0;
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int isHold = 0;
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int fileVersion = 0;
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int progress = 0;
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int completed = 0;
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int nowAt = 0;
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int crossPro = 0;
  @JsonKey(defaultValue: "", includeIfNull: true)
  String crossProList = "";

  @JsonKey(defaultValue: "", includeIfNull: true)
  String openSections = "";

  String? production;

  @JsonKey(ignore: true)
  File? ticketFile;

  Ticket() {}

  String getUpdateDateTime() {
    var date = DateTime.fromMicrosecondsSinceEpoch(uptime * 1000);
    var formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
    return formattedDate;
  }

  Future<int> getLocalFileVersion() {
    return DB.getDB().then((db) {
      return db!.rawQuery("select  ver  from files where ticket=$id ").then((value) {
        if (value.length > 0) {
          String uptime = value[0]["ver"].toString();
          print("getLocalFileVersion == $uptime");
          return int.parse(uptime);
        } else {
          return 0;
        }
      });
    });
  }

  Future<File> _getFile(context, {onReceiveProgress}) async {
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
    var filePath = ed!.path + '/$id.pdf';

    var response;
    try {
      await dio.download(Server.getServerApiPath('/tickets/getTicketFile?' + queryString), filePath, onReceiveProgress: (received, total) {
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
        await setLocalFileVersion(fileVersion);
      });
    } on DioError catch (e) {
      if (e.response != null) {
        print('"******************************************** responce');
        if (e.response!.statusCode == 404) {
          loadingWidget.close(context);
          var errorView = ErrorMessageView(
            errorMessage: "File Not Found",
            icon: Icons.sd_card_alert,
          );
          errorView.show(context);
          throw ("file not found");
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
    var i = await getLocalFileVersion();
    var isNew = await isFileNew();
    if (isNew && file.existsSync()) {
      return ticketFile;
    } else {
      await _getFile(context);
    }
    return ticketFile;
  }

  Future<void> open(context, {onReceiveProgress}) async {
    File file = await getLocalFile();
    var i = await getLocalFileVersion();
    var isNew = await isFileNew();
    print(isNew);

    if (isNew && file.existsSync()) {
      print("File exists ");
      var data = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PDFScreen(this)),
      );
      if (data != null && data) {
        open(context);
      }
    } else {
      _getFile(context).then((file) async {
        var data = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PDFScreen(this)),
        );
        if (data != null && data) {
          open(context);
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

  Future OpenEditor() async {
    return await platform.invokeMethod('editPdf', {'path': ticketFile!.path, 'fileID': id, 'ticket': toJson().toString()});
  }

  static const platform = const MethodChannel('editPdf');

  isFileNew() async {
    print('fffff=' + fileVersion.toString());
    print('fffff=' + (await getLocalFileVersion()).toString());
    print("SELECT * FROM tickets t left join  files f on f.ticket=t.id    where t.id=$id and f.ver=t.fileVersion ");
    return DB.getDB().then((db) {
      return db!.rawQuery("SELECT * FROM tickets t left join  files f on f.ticket=t.id    where t.id=$id and  fileVersion > ver ").then((value) {
        print(value);
        if (value.length > 0) {
          return false;
        } else {
          return true;
        }
      });
    });
  }

  setLocalFileVersion(newFileVersion) {
    return DB.getDB().then((db) => db!.rawQuery("replace into files (ticket,ver)values(?,?) ", [id, newFileVersion]).then((data) {
          print(data);
        }));
  }

  Future<List> getFlagList(String FlagType) async {
    print("tickets/flags/getList");
    return OnlineDB.apiGet("tickets/flags/getList", {"ticket": id.toString(), "type": FlagType}).then((response) {
      print(response.body);
      print("----------------------------------------");
      Map res = (json.decode(response.body) as Map);
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
}
