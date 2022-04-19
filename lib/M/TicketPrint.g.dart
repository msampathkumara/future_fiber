// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'TicketPrint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketPrint _$TicketPrintFromJson(Map<String, dynamic> json) => TicketPrint()
  ..id = json['id'] as int
  ..ticket = json['ticket'] == null
      ? null
      : Ticket.fromJson(json['ticket'] as Map<String, dynamic>)
  ..action = json['action'] as String?
  ..done = json['done'] as int? ?? 0
  ..doneOn = json['doneOn'] as String
  ..doneBy = json['doneBy'] as int? ?? 0;

Map<String, dynamic> _$TicketPrintToJson(TicketPrint instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ticket': instance.ticket?.toJson(),
      'action': instance.action,
      'done': instance.done,
      'doneOn': instance.doneOn,
      'doneBy': instance.doneBy,
    };
