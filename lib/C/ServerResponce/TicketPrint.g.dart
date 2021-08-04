// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'TicketPrint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketPrint _$TicketPrintFromJson(Map<String, dynamic> json) {
  return TicketPrint()
    ..id = json['id'] as int?
    ..doneOn = json['doneOn'] as String?
    ..action = json['action'] as String?
    ..doneBy = json['doneBy'] as int?;
}

Map<String, dynamic> _$TicketPrintToJson(TicketPrint instance) =>
    <String, dynamic>{
      'id': instance.id,
      'doneOn': instance.doneOn,
      'action': instance.action,
      'doneBy': instance.doneBy,
    };
