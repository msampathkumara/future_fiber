import 'package:json_annotation/json_annotation.dart';
import 'package:smartwind/M/Ticket.dart';

part 'TicketProgressDetails.g.dart';

@JsonSerializable()
class TicketProgressDetails {
  int id = 0;
  String operation = "";
  String finishedOn = "";
  int finishedBy = 0;
  String finishedAt = "";
  int status = 0;
  int operationNo = 0;
  int ticketId = 0;
  int nextOperationNo = 0;
  int doAt = 0;
  String upon = "";
  int erpDone = 0;
  int erpLater = 0;

  Ticket? ticket;

  TicketProgressDetails();

  factory TicketProgressDetails.fromJson(Map<String, dynamic> json) => _$TicketProgressDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$TicketProgressDetailsToJson(this);

  static List<TicketProgressDetails> fromJsonArray(ticketProgressDetailsList) {
    return List<TicketProgressDetails>.from(ticketProgressDetailsList.map((model) => TicketProgressDetails.fromJson(model)));
  }
}
