import 'package:json_annotation/json_annotation.dart';

part 'TicketPrint.g.dart';

@JsonSerializable(explicitToJson: true)
class TicketPrint {
  int? id;

  String? doneOn;

  String? action;

  int? doneBy;

  TicketPrint();

  factory TicketPrint.fromJson(Map<String, dynamic> json) => _$TicketPrintFromJson(json);

  Map<String, dynamic> toJson() => _$TicketPrintToJson(this);
}
