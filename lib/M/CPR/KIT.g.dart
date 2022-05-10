// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'KIT.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KIT _$KITFromJson(Map<String, dynamic> json) => KIT()
  ..ticket = json['ticket'] == null ? null : Ticket.fromJson(json['ticket'] as Map<String, dynamic>)
  ..sailType = json['sailType'] as String? ?? ''
  ..shortageType = json['shortageType'] as String? ?? ''
  ..kitType = json['kitType'] as String? ?? ''
  ..client = json['client'] as String? ?? ''
  ..comment = json['comment'] as String? ?? ''
  ..image = json['image'] as String? ?? ''
  ..items = (json['items'] as List<dynamic>?)?.map((e) => KitItem.fromJson(e as Map<String, dynamic>)).toList() ?? []
  ..suppliers = (json['suppliers'] as List<dynamic>?)?.map((e) => e as String).toList() ?? []
  ..status = json['status'] as String? ?? ''
  ..id = json['id'] as int? ?? 0
  ..sentUserId = json['sentUserId'] as int?
  ..receivedUserId = json['receivedUserId'] as int?
  ..sentOn = json['sentOn'] as String?
  ..addedUserId = json['addedUserId'] as int? ?? 0
  ..addedOn = json['addedOn'] as String? ?? ''
  ..isExpanded = json['isExpanded'] as bool? ?? false;

Map<String, dynamic> _$KITToJson(KIT instance) =>
    <String, dynamic>{
      'ticket': instance.ticket?.toJson(),
      'sailType': instance.sailType,
      'shortageType': instance.shortageType,
      'kitType': instance.kitType,
      'client': instance.client,
      'comment': instance.comment,
      'image': instance.image,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'suppliers': instance.suppliers,
      'status': instance.status,
      'id': instance.id,
      'sentUserId': instance.sentUserId,
      'receivedUserId': instance.receivedUserId,
      'sentOn': instance.sentOn,
      'addedUserId': instance.addedUserId,
      'addedOn': instance.addedOn,
      'isExpanded': instance.isExpanded,
    };
