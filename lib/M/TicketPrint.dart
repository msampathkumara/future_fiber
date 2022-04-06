import 'package:json_annotation/json_annotation.dart';

import 'Ticket.dart';

part 'TicketPrint.g.dart';

@JsonSerializable(explicitToJson: true)
class TicketPrint {
  int id = 0;
  Ticket? ticket;
  String? action;
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int done = 0;
  String doneOn = "";

  @JsonKey(defaultValue: 0, includeIfNull: true)
  int doneBy = 0;

  TicketPrint();

  factory TicketPrint.fromJson(Map<String, dynamic> json) => _$TicketPrintFromJson(json);

  Map<String, dynamic> toJson() => _$TicketPrintToJson(this);

  static List<TicketPrint> fromJsonArray(ticketPrintList) {
    return List<TicketPrint>.from(ticketPrintList.map((model) => TicketPrint.fromJson(model)));
  }
}
