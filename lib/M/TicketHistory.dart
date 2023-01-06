import 'package:json_annotation/json_annotation.dart';

import 'Section.dart';

part 'TicketHistory.g.dart';

@JsonSerializable(explicitToJson: true)
class TicketHistory {
  int? id;

  String? action;
  String? uptime;
  var data;
  int? doneBy;
  Section? section;

  TicketHistory();

  factory TicketHistory.fromJson(Map<String, dynamic> json) => _$TicketHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$TicketHistoryToJson(this);

  static List<TicketHistory> fromJsonArray(historyList) {
    return List<TicketHistory>.from(historyList.map((model) => TicketHistory.fromJson(model)));
  }
}
