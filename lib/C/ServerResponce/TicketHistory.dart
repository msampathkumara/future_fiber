import 'package:json_annotation/json_annotation.dart';
import 'package:json_annotation/json_annotation.dart';


@JsonSerializable(explicitToJson: true)
part 'TicketHistory.g.dart';
@JsonSerializable()
class TicketHistory{

  int? id;

  String? action;
  String? uptime;

  TicketHistory();


factory TicketHistory.fromJson(Map<String, dynamic> json) => _$TicketHistoryFromJson(json);

Map<String, dynamic> toJson() => _$TicketHistoryToJson(this);
}