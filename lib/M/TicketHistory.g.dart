// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'TicketHistory.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketHistory _$TicketHistoryFromJson(Map<String, dynamic> json) => TicketHistory()
  ..id = json['id'] as int?
  ..action = json['action'] as String?
  ..uptime = json['uptime'] as String?
  ..data = json['data'] as Map<String, dynamic>?
  ..doneBy = json['doneBy'] as int?;

Map<String, dynamic> _$TicketHistoryToJson(TicketHistory instance) => <String, dynamic>{
      'id': instance.id,
      'action': instance.action,
      'uptime': instance.uptime,
      'data': instance.data,
      'doneBy': instance.doneBy,
    };
