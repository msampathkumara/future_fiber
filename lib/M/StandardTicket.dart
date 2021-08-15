import 'package:json_annotation/json_annotation.dart';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smartwind/C/DB/DB.dart';
import 'package:smartwind/C/Server.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/V/Widgets/ErrorMessageView.dart';
import 'package:smartwind/V/Widgets/Loading.dart';
import 'package:smartwind/V/Widgets/PdfEditor.dart';

 
part 'StandardTicket.g.dart';
@JsonSerializable(explicitToJson: true)
class StandardTicket extends Ticket {
  String? production;
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int usedCount = 0;
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
      var data = await Navigator.push(context, MaterialPageRoute(builder: (context) => PdfEditor(this)));
      if (data != null && data) {
        open(context);
      }
    } else {
      print("File not exists or old ");
      _getFile(context).then((file) async {
        // var data = await Navigator.push(  context, MaterialPageRoute(builder: (context) => PDFScreen(this)) );
        var data = await Navigator.push(context, MaterialPageRoute(builder: (context) => PdfEditor(this)));
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

  setLocalFileVersion(newFileVersion) {
    return DB.getDB().then((db) => db!.rawQuery("replace into files (ticket,ver,type)values(?,?,?) ", [id, newFileVersion, 'standardTicket']).then((data) {
          print(data);
        }));
  }

  isFileNew() async {
    return DB.getDB().then((db) {
      return db!.rawQuery("SELECT * FROM standardTickets t left join  files f on f.ticket=t.id    where t.id=$id and type='standardTicket' and  fileVersion > ver ").then((value) {
        print(value);
        if (value.length > 0) {
          return false;
        } else {
          return true;
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
    var filePath = ed!.path + '/st$id.pdf';

    var response;
    try {
      await dio.download(Server.getServerApiPath('/tickets/standard/getPdf?' + queryString), filePath, onReceiveProgress: (received, total) {
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
}
