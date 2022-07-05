// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'TicketComment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketComment _$TicketCommentFromJson(Map<String, dynamic> json) => TicketComment()
  ..id = json['id'] as int?
  ..comment = json['comment'] as String? ?? ''
  ..dnt = json['dnt'] as String? ?? ''
  ..userId = json['userId'] as int? ?? 0
  ..ticketId = json['ticketId'] as int? ?? 0;

Map<String, dynamic> _$TicketCommentToJson(TicketComment instance) => <String, dynamic>{
      'id': instance.id,
      'comment': instance.comment,
      'dnt': instance.dnt,
      'userId': instance.userId,
      'ticketId': instance.ticketId,
    };
