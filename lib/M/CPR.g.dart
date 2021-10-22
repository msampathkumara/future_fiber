// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CPR.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CPR _$CPRFromJson(Map<String, dynamic> json) => CPR()
  ..ticket = json['ticket'] == null
      ? null
      : Ticket.fromJson(json['ticket'] as Map<String, dynamic>)
  ..sailType = json['sailType'] as String?
  ..shortageType = json['shortageType'] as String?
  ..cprType = json['cprType'] as String?
  ..client = json['client'] as String?
  ..comment = json['comment'] as String? ?? ''
  ..image = json['image'] as String? ?? ''
  ..items = (json['items'] as List<dynamic>?)
          ?.map((e) => CprItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      []
  ..suppliers =
      (json['suppliers'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          []
  ..mo = json['mo']
  ..oe = json['oe']
  ..status = json['status'] as String
  ..id = json['id'] as int
  ..dnt = json['dnt']
  ..supplier = json['supplier'] as String
  ..sentBy = json['sentBy'] == null
      ? null
      : NsUser.fromJson(json['sentBy'] as Map<String, dynamic>)
  ..recivedBy = json['recivedBy'] == null
      ? null
      : NsUser.fromJson(json['recivedBy'] as Map<String, dynamic>)
  ..sentOn = json['sentOn'] as String?
  ..recivedOn = json['recivedOn'] as String?
  ..user = json['user'] == null
      ? null
      : NsUser.fromJson(json['user'] as Map<String, dynamic>);

Map<String, dynamic> _$CPRToJson(CPR instance) => <String, dynamic>{
      'ticket': instance.ticket?.toJson(),
      'sailType': instance.sailType,
      'shortageType': instance.shortageType,
      'cprType': instance.cprType,
      'client': instance.client,
      'comment': instance.comment,
      'image': instance.image,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'suppliers': instance.suppliers,
      'mo': instance.mo,
      'oe': instance.oe,
      'status': instance.status,
      'id': instance.id,
      'dnt': instance.dnt,
      'supplier': instance.supplier,
      'sentBy': instance.sentBy?.toJson(),
      'recivedBy': instance.recivedBy?.toJson(),
      'sentOn': instance.sentOn,
      'recivedOn': instance.recivedOn,
      'user': instance.user?.toJson(),
    };
