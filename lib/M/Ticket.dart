import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smartwind_future_fibers/C/Server.dart';
import 'package:smartwind_future_fibers/M/StandardTicket.dart';
import 'package:smartwind_future_fibers/M/TicketFlag.dart';

import 'package:smartwind_future_fibers/Mobile/V/Home/Tickets/CS/CS.dart';
import 'package:smartwind_future_fibers/Mobile/V/Home/Tickets/ShippingSystem/ShippingSystem.dart';
import 'package:smartwind_future_fibers/Mobile/V/Widgets/ErrorMessageView.dart';
import 'package:smartwind_future_fibers/Mobile/V/Widgets/Loading.dart';
import 'package:universal_html/html.dart' as html;

import '../C/Api.dart';
import '../Mobile/V/Widgets/TicketPdfViwer.dart';
import 'AppUser.dart';
import 'DataObject.dart';
import 'EndPoints.dart';
import 'LocalFileVersion.dart';
import 'PermissionsEnum.dart';
import 'Ticket/CprReport.dart';
import '../C/DB/hive.dart';
import 'package:collection/collection.dart';

part 'Ticket.g.dart';

part 'Ticket.options.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 1)
class Ticket extends DataObject {
  @HiveField(0, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? mo;

  @HiveField(1, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? oe;

  @override
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

  @override
  @HiveField(7, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int id = 0;

  @HiveField(8, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int isRed = 0;

  @HiveField(9, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int isRush = 0;

  // @HiveField(10, defaultValue: 0)
  // @JsonKey(defaultValue: 0, includeIfNull: true)
  // int isSk = 0;

  @HiveField(11, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int inPrint = 0;

  // @HiveField(12, defaultValue: 0)
  // @JsonKey(defaultValue: 0, includeIfNull: true)
  // int isGr = 0;

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

  @HiveField(28, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int isQc = 0;

  @HiveField(29, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int isQa = 0;

  @HiveField(30, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? completedOn;

  @HiveField(31, defaultValue: false)
  @JsonKey(defaultValue: false, includeIfNull: true, fromJson: boolFromO, toJson: boolToInt)
  bool isStarted = false;

  @HiveField(32, defaultValue: false)
  @JsonKey(defaultValue: false, includeIfNull: true, fromJson: boolFromO, toJson: boolToInt)
  bool haveComments = false;

  @HiveField(33, defaultValue: false)
  @JsonKey(defaultValue: false, includeIfNull: true, fromJson: boolFromO, toJson: boolToInt)
  bool openAny = false;

  @JsonKey(ignore: true)
  File? ticketFile;

  @HiveField(34, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int kit = 0;

  @HiveField(35, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int cpr = 0;

  @HiveField(36, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int haveKit = 0;

  @HiveField(37, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int haveCpr = 0;

  @HiveField(38, defaultValue: [])
  @JsonKey(defaultValue: [], includeIfNull: true, fromJson: stringToCprReportList)
  List<CprReport> cprReport = [];

  @HiveField(39, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? pool;

  @HiveField(40, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  int? custom;

  @HiveField(41, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true, fromJson: intToString)
  String? jobId;

  @HiveField(42, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true, fromJson: intToString)
  String? config;

  @HiveField(43, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int isYellow = 0;

  static String intToString(string) => '${string ?? ''}';

  bool get isCustom => custom == 1;

  bool get isStandard => custom == 0;

  String? get atSection {
    var x = HiveBox.sectionsBox.get(nowAt)?.sectionTitle;

    return x;
  }

  @JsonKey(defaultValue: false, includeIfNull: true)
  bool loading = false;

  Ticket();

  bool get hasFile => file == 1;

  bool get hasNoFile => file != 1;

  bool get isCompleted => completed == 1;

  bool get isNotCompleted => completed == 0;

  bool get error => isError == 1;

  bool get isNotHold => isHold == 0;

  static List stringToList(string) => (string == null || string.toString().isEmpty) ? [] : json.decode(string);

  static List<CprReport> stringToCprReportList(string) {
    List<CprReport> r = (string == null || string.toString().isEmpty) ? [] : CprReport.fromJsonArray(json.decode(string));
    return r;
  }

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

  static Future<File?> getFile(Ticket ticket, context, {onReceiveProgress}) async {
    File file = await ticket.getLocalFile();
    var isNew = await Ticket.isFileNew(ticket);
    if (isNew && file.existsSync()) {
      return ticket.ticketFile;
    } else {
      ticket.ticketFile = await _getFile(ticket, context);
    }
    return ticket.ticketFile;
  }

  static Future getFileAsData(ticket, context, {onReceiveProgress}) async {
    var path = "${EndPoints.tickets_getTicketFile}?";

    String queryString = Uri(queryParameters: {"id": ticket.id.toString()}).query;
    final idToken = await AppUser.getIdToken(false);

    Dio dio = Dio();
    dio.options.headers["authorization"] = "$idToken";
    Response<List<int>>? rs;
    try {
      rs = await dio.get<List<int>>(await Server.getServerApiPath(path + queryString), options: Options(responseType: ResponseType.bytes));
    } catch (e) {
      if (e is DioError) {
        print("------------------------------------------------------------------------${e.response?.statusCode}");
        // print(e);
        if (e.response?.statusCode == 404) {
          print('404');
          const ErrorMessageView(errorMessage: 'Ticket Not Found', icon: Icons.broken_image_rounded).show(context);
        } else {
          print(e.message);
        }
      } else {}
      // loadingWidget.close(context);
    }

    return rs?.data;
  }

  static Future<void> open(context, Ticket ticket, {onReceiveProgress, isPreCompleted = false}) async {
    print('"Downloading Ticket"');

    if ((!AppUser.havePermissionFor(NsPermissions.TICKET_EDIT_ANY_PDF)) && ticket.isHold == 1) {
      return;
    }

    if (kIsWeb) {
      var loadingWidget = const Loading(loadingText: "Downloading Ticket");
      loadingWidget.show(context);

      var path = ticket.isStandardFile ? "${EndPoints.tickets_standard_getPdf}?" : '${EndPoints.tickets_getTicketFile}?';
      String queryString = Uri(queryParameters: {"id": ticket.id.toString()}).query;
      final idToken = await AppUser.getIdToken(false);
      Dio dio = Dio();
      dio.options.headers["authorization"] = "$idToken";
      Response<List<int>>? rs;
      try {
        rs = await dio.get<List<int>>(await Server.getServerApiPath(path + queryString), options: Options(responseType: ResponseType.bytes));
      } catch (e) {
        loadingWidget.close(context);
        if (e is DioError) {
          print("------------------------------------------------------------------------${e.response?.statusCode}");
          // print(e);
          if (e.response?.statusCode == 404) {
            print('404');
            const ErrorMessageView(errorMessage: 'Ticket Not Found', icon: Icons.broken_image_rounded).show(context);
          } else {
            const ErrorMessageView(errorMessage: 'Oops! Something went wrong. Try again or check internet connection.', icon: Icons.broken_image_rounded).show(context);
            print(e.message);
          }
        } else {}
      }

      if (rs != null) {
        loadingWidget.close(context);
        final blob = html.Blob([rs.data], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.window.open(url, "_blank");

        // var windowBase = html.window.open(url, "_blank");

        // html.Url.revokeObjectUrl(url);
      }

      return;
    }

    File file = await ticket.getLocalFile();
    var isNew = await Ticket.isFileNew(ticket);

    print('file ${file.existsSync()}');

    if (isNew && file.existsSync()) {
      print("File exists ");
      viewTicket(ticket, context, isPreCompleted: isPreCompleted);
    } else {
      print("File not exists or old ");
      _getFile(ticket, context).then((file) async {
        if (file != null) {
          viewTicket(ticket, context, isPreCompleted: isPreCompleted);
        }
      });
    }
  }

  factory Ticket.fromJson(Map<String, dynamic> json) => _$TicketFromJson(json);

  Map<String, dynamic> toJson() => _$TicketToJson(this);

  Future<File> getLocalFile() async {
    var ed = await getExternalStorageDirectory();
    var filePath = '${ed!.path}/$id.pdf';
    File file = File(filePath);
    ticketFile = file;
    return file;
  }

  static Future openEditor(Ticket ticket) async {
    Map t = ticket.toJson();
    t["openSections"] = "";
    t["crossProList"] = "";
    t["crossPro"] = "";
    t["loading"] = "";
    t["production"] = "";
    t["completedOn"] = "";
    t.keys.where((k) => (t[k] ?? "").toString().isEmpty).toList().forEach(t.remove);
    print("____________________________________________________________________________________________________________________________*****");
    print(t.toString());
    String serverUrl = await Server.getServerApiPath(ticket.isStandardFile ? EndPoints.tickets_standard_uploadEdits : EndPoints.tickets_uploadEdits);
    var userCurrentSection = (AppUser.getSelectedSection()?.id ?? 0).toString();
    return await platform.invokeMethod(
        'editPdf', {'path': ticket.ticketFile!.path, 'userCurrentSection': userCurrentSection.toString(), 'fileID': ticket.id, 'ticket': t.toString(), "serverUrl": serverUrl});
  }

  static const platform = MethodChannel('editPdf');

  static Future<bool> isFileNew(Ticket ticket) async {
    // var ticket1 = ticket.isStandardFile ? HiveBox.standardTicketsBox.get(ticket.id) : HiveBox.ticketBox.get(ticket.id);
    print('Ticket id == ${ticket.id}');
    var ticket1 = HiveBox.ticketBox.get(ticket.id);

    var f = HiveBox.localFileVersionsBox.values.where((element) => element.type == ticket.getTicketType().getValue() && element.ticketId == ticket.id);
    if (f.isNotEmpty) {
      LocalFileVersion fileVersion = f.first;
      print("---------------------------fileVersion.toJson()");
      print(fileVersion.toJson().toString());
      print(ticket1?.toJson().toString());
      print(ticket1?.fileVersion.toString());

      if (ticket1 != null) {
        if (ticket1.fileVersion != fileVersion.version) {
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
    print(fv.toJson().toString());

    fv.version = newFileVersion;
    fileVersion = newFileVersion;

    if (fv.isInBox) {
      fv.save();
    } else {
      HiveBox.localFileVersionsBox.put('${ticketType.getValue()}$id', fv);
    }
  }

  static Future<List<TicketFlag>> getFlagList(String flagType, Ticket ticket) async {
    print("tickets/flags/getList");
    return Api.get(EndPoints.tickets_flags_getList, {"ticket": ticket.id.toString(), "type": flagType}).then((response) {
      print(response.data);
      print("-----------------vvvvvvvvvvv-----------------------");
      Map<String, dynamic> res = response.data;
      List l = ((res["flags"] ?? []));

      List<TicketFlag> list = List<TicketFlag>.from(l.map((model) {
        return TicketFlag.fromJson(model);
      }));
      print(list.length.toString());
      return list;
    }).catchError((onError) {
      print(onError);
    });
  }

  static Future sharePdf(context, Ticket ticket) async {
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }
    File? file = await getFile(ticket, context);
    if (file != null && file.existsSync()) {
      print('--------------------- ${file.path}');

      File? file1 = await file.copy("${file.parent.path}/${(ticket.mo ?? ticket.oe ?? ticket.id)}.pdf");
      print('copied');
      await FlutterShare.shareFile(
        chooserTitle: "Share Ticket",
        title: ticket.mo ?? ticket.oe ?? "${ticket.id}.pdf",
        text: "share ticket file",
        filePath: file1.path,
      );
      // file.delete();
    } else {
      const ErrorMessageView(errorMessage: "File Not Found", icon: Icons.insert_drive_file_outlined).show(context);
    }
  }

  Future openInShippingSystem(BuildContext context) async {
    await getFile(this, context).then((value) {
      return Navigator.push(context, MaterialPageRoute(builder: (context) => ShippingSystem(this)));
    });
  }

  Future openInCS(BuildContext context) async {
    return await getFile(this, context).then((file) {
      if (file == null) {
        return false;
      }
      return Navigator.push(context, MaterialPageRoute(builder: (context) => CS(this)));
    });
  }

  String? getName() {
    return mo ?? oe;
  }

  static List<Ticket> fromJsonArray(tickets) {
    return List<Ticket>.from(tickets.map((model) => Ticket.fromJson(model)));
  }

  bool get isStandardFile => this is StandardTicket;

  TicketTypes getTicketType() {
    return isStandardFile ? TicketTypes.Standard : TicketTypes.Ticket;
  }

  static bool boolFromInt(int done) => done == 1;

  static int boolToInt(bool done) => done ? 1 : 0;

  static bool boolFromO(done) => (done == 1 || done == true);

  static Ticket? fromId(id) {
    return HiveBox.ticketBox.get(id, defaultValue: null);
  }

  static Future start(Ticket ticket, context) {
    return Api.post(EndPoints.tickets_start, {"ticket": ticket.id.toString()}).then((response) {
      if (kDebugMode) {
        print(response.data);
        print("-----------------vvvvvvvvxxxxxxxxxxvvv-----------------------");
      }

      return true;
    }).catchError((error, stackTrace) {
      var e = error as DioError;
      var errmsg = '';
      if (e.type == DioErrorType.unknown) {
        print('catched');
      } else if (e.type == DioErrorType.connectionTimeout) {
        print('check your connection');
        errmsg = 'check your connection';
      } else if (e.type == DioErrorType.receiveTimeout) {
        print('unable to connect to the server');
        errmsg = 'unable to connect to the server';
      } else {
        print('Something went wrong');
        errmsg = 'Something went wrong';
      }
      print(e);

      // print(stackTrace.toString());
      ErrorMessageView(errorMessage: errmsg, errorDescription: e.message ?? '').show(context);

      print(error);
    });
  }

  static Future viewTicket(Ticket ticket, context, {isPreCompleted = false}) async {
    TicketPdfViewer ticketPdfViwer;
    GlobalKey<TicketPdfViewerState> myKey = GlobalKey();

    print('widget. isPreCompleted ===== 1 $isPreCompleted');

    ticketPdfViwer = TicketPdfViewer(ticket, onClickEdit: () async {
      var x = await Ticket.openEditor(ticket);
      if (x == true) {
        await showDialog(
            context: context,
            builder: (_) {
              HiveBox.getDataFromServer(afterLoad: () => {Navigator.of(context, rootNavigator: true).pop()});
              return AlertDialog(
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  content: Builder(builder: (context) {
                    return const SizedBox(height: 150, width: 50, child: Center(child: SizedBox(height: 50, width: 50, child: CircularProgressIndicator())));
                  }));
            });

        File file = await ticket.getLocalFile();
        await file.delete(recursive: true);
        await Ticket.getFile(ticket, context);
        myKey.currentState?.close();
        viewTicket(ticket, context, isPreCompleted: isPreCompleted);
      }
    }, isPreCompleted: isPreCompleted, key: myKey);
    return await ticketPdfViwer.show(context);
  }

  CprReport? _kitReport;
  List<CprReport>? _cprReport;

  CprReport? getKitReport() {
    _kitReport = _kitReport ?? cprReport.firstWhereOrNull((element) => element.type == 'kit');

    return _kitReport;
  }

  List<CprReport> getCprReport() {
    return _cprReport = _cprReport ?? cprReport.where((element) => element.type == 'cpr').toList();
  }
}
