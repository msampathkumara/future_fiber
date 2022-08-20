// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CPR.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CPR _$CPRFromJson(Map<String, dynamic> json) => CPR()
  ..ticket = json['ticket'] == null ? null : Ticket.fromJson(json['ticket'] as Map<String, dynamic>)
  ..sailType = json['sailType'] as String? ?? ''
  ..shortageType = json['shortageType'] as String? ?? ''
  ..cprType = json['cprType'] as String? ?? ''
  ..client = json['client'] as String? ?? ''
  ..comment = json['comment'] as String? ?? ''
  ..image = json['image'] as String? ?? ''
  ..items = (json['items'] as List<dynamic>?)?.map((e) => CprItem.fromJson(e as Map<String, dynamic>)).toList() ?? []
  ..suppliers = json['suppliers'] == null ? [] : CPR.arrayFromObject(json['suppliers'])
  ..status = json['status'] as String? ?? ''
  ..id = json['id'] as int? ?? 0
  ..sentUserId = json['sentUserId'] as int?
  ..receivedUserId = json['receivedUserId'] as int?
  ..sentOn = json['sentOn'] as String?
  ..addedUserId = json['addedUserId'] as int? ?? 0
  ..addedOn = json['addedOn'] as String? ?? ''
  ..isExpanded = json['isExpanded'] as bool? ?? false
  ..cprs = (json['cprs'] as List<dynamic>?)?.map((e) => CprActivity.fromJson(e as Map<String, dynamic>)).toList() ?? []
  ..shipDate = json['shipDate'] as String? ?? ''
  ..formType = json['formType'] as String? ?? '';

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
      'status': instance.status,
      'id': instance.id,
      'sentUserId': instance.sentUserId,
      'receivedUserId': instance.receivedUserId,
      'sentOn': instance.sentOn,
      'addedUserId': instance.addedUserId,
      'addedOn': instance.addedOn,
      'isExpanded': instance.isExpanded,
      'cprs': instance.cprs.map((e) => e.toJson()).toList(),
      'shipDate': instance.shipDate,
      'formType': instance.formType,
    };
