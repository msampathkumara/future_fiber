// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'TicketFlag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketFlag _$TicketFlagFromJson(Map<String, dynamic> json) {
  return TicketFlag()
    ..id = json['id'] as int? ?? 0
    ..ticket = json['ticket'] as int? ?? 0
    ..type = json['type'] as String? ?? ''
    ..comment = json['comment'] as String? ?? '-'
    ..user = json['user'] as int? ?? 0
    ..dnt = json['dnt'] as String? ?? '-'
    ..flaged = json['flaged'] as int? ?? 0;
}

Map<String, dynamic> _$TicketFlagToJson(TicketFlag instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ticket': instance.ticket,
      'type': instance.type,
      'comment': instance.comment,
      'user': instance.user,
      'dnt': instance.dnt,
      'flaged': instance.flaged,
    };
