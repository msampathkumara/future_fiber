import 'package:json_annotation/json_annotation.dart';

import 'Ticket.dart';

part 'TicketPrint.g.dart';

@JsonSerializable(explicitToJson: true)
class TicketPrint {
  int id = 0;
  Ticket? ticket;
  String? action;
  int done = 0;
  String doneOn = "";

  TicketPrint();

  factory TicketPrint.fromJson(Map<String, dynamic> json) => _$TicketPrintFromJson(json);

  Map<String, dynamic> toJson() => _$TicketPrintToJson(this);
}