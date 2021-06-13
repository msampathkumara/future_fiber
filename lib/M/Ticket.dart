import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smartwind/C/DB/DB.dart';
import 'package:smartwind/C/Server.dart';
import 'package:smartwind/V/Widgets/ErrorMessageView.dart';
import 'package:smartwind/V/Widgets/Loading.dart';
import 'package:smartwind/V/Widgets/PDFScreen.dart';

part 'Ticket.g.dart';

@JsonSerializable(explicitToJson: true)
class Ticket {
  String? mo;
  String? oe;
  int finished = 0;
  int uptime = 0;
  int file = 0;
  int sheet = 0;
  int dir = 0;
  int id = 0;
  int isRed = 0;
  int isRush = 0;
  int isSk = 0;
  int inPrint = 0;
  int isGr = 0;
  int isError = 0;
  int canOpen = 1;
  int isSort = 0;
  int isHold = 0;
  int fileVersion = 0;
  String? production;
  double progress = 0.0;
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

  Future<File> getFile(context, {onReceiveProgress}) async {
    var loadingWidget = Loading(
      loadingText: "Downloading Ticket",
    );
    loadingWidget.show(context);

    var dio = Dio();
    var ed = await getExternalStorageDirectory();

    dio.options.headers['content-Type'] = 'application/json';
    // dio.options.headers["authorization"] = "token ${token}";
    String queryString = Uri(queryParameters: {"id": id.toString()}).query;
    var filePath = ed!.path + '/$id.pdf';

    var response;
    try {
      await dio.download(Server.getServerApiPath('/tickets/getTicket?' + queryString), filePath, onReceiveProgress: (received, total) {
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
      getFile(context).then((file) async {
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
}
