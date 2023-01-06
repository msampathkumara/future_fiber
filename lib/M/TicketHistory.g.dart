// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'TicketHistory.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketHistory _$TicketHistoryFromJson(Map<String, dynamic> json) => TicketHistory()
  ..id = json['id'] as int?
  ..action = json['action'] as String?
  ..uptime = json['uptime'] as String?
  ..data = json['data']
  ..doneBy = json['doneBy'] as int?
  ..section = json['section'] == null ? null : Section.fromJson(json['section'] as Map<String, dynamic>);

Map<String, dynamic> _$TicketHistoryToJson(TicketHistory instance) => <String, dynamic>{
      'id': instance.id,
      'action': instance.action,
      'uptime': instance.uptime,
      'data': instance.data,
      'doneBy': instance.doneBy,
      'section': instance.section?.toJson(),
    };
