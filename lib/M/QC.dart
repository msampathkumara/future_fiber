import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:smartwind_future_fibers/M/EndPoints.dart';
import 'package:smartwind_future_fibers/M/NsUser.dart';
import 'package:smartwind_future_fibers/C/DB/hive.dart';

import '../C/Server.dart';
import '../Mobile/V/Widgets/ErrorMessageView.dart';
import 'AppUser.dart';
import 'Section.dart';
import 'Ticket.dart';

part 'QC.g.dart';

@JsonSerializable(explicitToJson: true)
class QC {
  int id = 0;
  int ticketId = 0;
  int dnt = 0;
  String image = "0";

  Ticket? ticket;

  int userId = 0;
  @JsonKey(defaultValue: "", includeIfNull: true)
  String? userName = "";

  NsUser? user;

  @JsonKey(defaultValue: 0, includeIfNull: true)
  int? sectionId;

  @JsonKey(defaultValue: null, includeIfNull: true)
  String? quality;

  NsUser? getUser() {
    user = user ?? HiveBox.usersBox.get(userId);
    return user;
  }

  int qc = 0;
  String? _dnt;

  QC();

  factory QC.fromJson(Map<String, dynamic> json) => _$QCFromJson(json);

  Map<String, dynamic> toJson() => _$QCToJson(this);

  isQc() {
    return qc == 1;
  }

  getDateTime() {
    if ((_dnt) != null) {
      return "";
    }
    var date = DateTime.fromMicrosecondsSinceEpoch((dnt) * 1000);
    var formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(date);
    return formattedDate;
  }

  static List<QC> fromJsonArray(qcList) {
    return List<QC>.from(qcList.map((model) {
      return QC.fromJson(model);
    }));
  }

  Future getFile(context, {onReceiveProgress}) async {
    var path = '${EndPoints.tickets_qc_qcImageView}?';
    String queryString = Uri(queryParameters: {"id": id.toString()}).query;
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

  Section? section;

  Section? getSection() {
    section = section ?? HiveBox.sectionsBox.get(sectionId);
    return section;
  }
}
