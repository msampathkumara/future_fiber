import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smartwind/C/Server.dart';
import 'package:smartwind/M/LocalFileVersion.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/M/hive.dart';
import 'package:smartwind/V/Widgets/ErrorMessageView.dart';
import 'package:smartwind/V/Widgets/Loading.dart';
import 'package:smartwind/V/Widgets/PdfEditor.dart';

import '../V/Widgets/TicketPdfViwer.dart';

part 'StandardTicket.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 9)
class StandardTicket extends Ticket {
  @HiveField(50, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? production;

  @HiveField(51, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int usedCount = 0;

  @HiveField(52, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int uptime = 0;

  StandardTicket();

  Future<void> open(context, {onReceiveProgress}) async {
    File file = await getLocalFile();
    var isNew = await isFileNew();
    print(isNew);
    if (isNew && file.existsSync()) {
      print("File exists ");
      // var data = await Navigator.push(  context,   MaterialPageRoute(builder: (context) => PDFScreen(this))   );
      var data = await Navigator.push(context, MaterialPageRoute(builder: (context) => TicketPdfViwer(this)));
      if (data != null && data) {
        open(context);
      }
    } else {
      print("File not exists or old ${id}");
      _getFile(context).then((file) async {
        // var data = await Navigator.push(  context, MaterialPageRoute(builder: (context) => PDFScreen(this)) );
        var data = await Navigator.push(context, MaterialPageRoute(builder: (context) => TicketPdfViwer(this)));
        if (data != null && data) {
          open(context);
        }
      });
    }
  }

  Future<File> getLocalFile() async {
    var ed = await getExternalStorageDirectory();
    var filePath = ed!.path + '/st$id.pdf';
    File file = new File(filePath);
    ticketFile = file;
    return file;
  }

  // setLocalFileVersion(newFileVersion) {
  //   LocalFileVersion f = HiveBox.localFileVersionsBox.values.where((element) => element.type == TicketTypes.Standard.getValue() && element.ticketId == id).first;
  //   f.version = newFileVersion;
  //
  //   HiveBox.localFileVersionsBox.toMap().forEach((key, value) {
  //     if (value.type == TicketTypes.Standard.getValue() && value.ticketId == id) {
  //       value.version = newFileVersion;
  //       HiveBox.localFileVersionsBox.put(key, value);
  //     }
  //   });
  //
  //   HiveBox.localFileVersionsBox.toMap().forEach((key, value) {
  //     print(key + " ${value.toJson()}");
  //   });
  //
  //   // return DB.getDB().then((db) => db!.rawQuery("replace into files (ticket,ver,type)values(?,?,?) ", [id, newFileVersion, 'standardTicket']).then((data) {
  //   //       print(data);
  //   //     }));
  // }

  isFileNew() async {
    var standardTicket = HiveBox.standardTicketsBox.get(id);
    var f = HiveBox.localFileVersionsBox.values.where((element) => element.type == TicketTypes.Standard.getValue() && element.ticketId == id);
    if (f.isNotEmpty) {
      LocalFileVersion fileVersion = f.first;
      print("---------------------------fileVersion.toJson()");
      print(fileVersion.toJson());

      if (standardTicket != null && f.isNotEmpty) {
        if (standardTicket.fileVersion > fileVersion.version) {
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
    var filePath = ed!.path + '/st$id.pdf';

    var response;
    try {
      await dio.download(Server.getServerApiPath('tickets/standard/getPdf?' + queryString), filePath, onReceiveProgress: (received, total) {
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
        await setLocalFileVersion(int.parse(fileVersion),TicketTypes.Standard);
      });
    } on DioError catch (e) {
      if (e.response != null) {
        print('"******************************************** response');
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

  factory StandardTicket.fromJson(Map<String, dynamic> json) => _$StandardTicketFromJson(json);

  Map<String, dynamic> toJson() => _$StandardTicketToJson(this);

  static List<StandardTicket> fromJsonArray(StandardTickets) {
    return List<StandardTicket>.from(StandardTickets.map((model) => StandardTicket.fromJson(model)));
  }
}
