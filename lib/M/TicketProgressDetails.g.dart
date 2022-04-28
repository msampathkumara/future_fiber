// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'TicketProgressDetails.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketProgressDetails _$TicketProgressDetailsFromJson(Map<String, dynamic> json) => TicketProgressDetails()
  ..id = json['id'] as int
  ..operation = json['operation'] as String
  ..finishedOn = json['finishedOn'] as String
  ..finishedBy = json['finishedBy'] as int
  ..finishedAt = json['finishedAt'] as String
  ..status = json['status'] as int
  ..operationNo = json['operationNo'] as int
  ..ticketId = json['ticketId'] as int
  ..nextOperationNo = json['nextOperationNo'] as int
  ..doAt = json['doAt'] as int
  ..upon = json['upon'] as String
  ..erpDone = json['erpDone'] as int
  ..erpLater = json['erpLater'] as int
  ..ticket = json['ticket'] == null ? null : Ticket.fromJson(json['ticket'] as Map<String, dynamic>);

Map<String, dynamic> _$TicketProgressDetailsToJson(TicketProgressDetails instance) => <String, dynamic>{
      'id': instance.id,
      'operation': instance.operation,
      'finishedOn': instance.finishedOn,
      'finishedBy': instance.finishedBy,
      'finishedAt': instance.finishedAt,
      'status': instance.status,
      'operationNo': instance.operationNo,
      'ticketId': instance.ticketId,
      'nextOperationNo': instance.nextOperationNo,
      'doAt': instance.doAt,
      'upon': instance.upon,
      'erpDone': instance.erpDone,
      'erpLater': instance.erpLater,
      'ticket': instance.ticket,
    };
