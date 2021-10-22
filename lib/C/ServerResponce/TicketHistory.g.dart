// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'TicketHistory.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketHistory _$TicketHistoryFromJson(Map<String, dynamic> json) =>
    TicketHistory()
      ..id = json['id'] as int?
      ..action = json['action'] as String?
      ..uptime = json['uptime'] as String?
      ..doneBy = json['doneBy'] as int?;

Map<String, dynamic> _$TicketHistoryToJson(TicketHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'action': instance.action,
      'uptime': instance.uptime,
      'doneBy': instance.doneBy,
    };
