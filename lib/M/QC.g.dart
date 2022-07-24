// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'QC.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QC _$QCFromJson(Map<String, dynamic> json) => QC()
  ..id = json['id'] as int
  ..ticketId = json['ticketId'] as int
  ..dnt = json['dnt'] as int
  ..image = json['image'] as String
  ..ticket = json['ticket'] == null ? null : Ticket.fromJson(json['ticket'] as Map<String, dynamic>)
  ..userId = json['userId'] as int
  ..userName = json['userName'] as String? ?? ''
  ..user = json['user'] == null ? null : NsUser.fromJson(json['user'] as Map<String, dynamic>)
  ..sectionId = json['sectionId'] as int? ?? 0
  ..quality = json['quality'] as String?
  ..qc = json['qc'] as int;

Map<String, dynamic> _$QCToJson(QC instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ticketId': instance.ticketId,
      'dnt': instance.dnt,
      'image': instance.image,
      'ticket': instance.ticket?.toJson(),
      'userId': instance.userId,
      'userName': instance.userName,
      'user': instance.user?.toJson(),
      'sectionId': instance.sectionId,
      'quality': instance.quality,
      'qc': instance.qc,
    };
