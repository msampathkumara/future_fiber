import 'package:json_annotation/json_annotation.dart';

part 'TicketHistory.g.dart';

@JsonSerializable(explicitToJson: true)
class TicketHistory {
  int? id;

  String? action;
  String? uptime;

  int? doneBy;

  TicketHistory();

  factory TicketHistory.fromJson(Map<String, dynamic> json) => _$TicketHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$TicketHistoryToJson(this);
}
