import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:smartwind/M/NsUser.dart';

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
    return List<QC>.from(qcList.map((model) => QC.fromJson(model)));
  }
}
