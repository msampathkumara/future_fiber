// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cprActivity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CprActivity _$CprActivityFromJson(Map<String, dynamic> json) => CprActivity()
  ..supplier = json['supplier'] as String? ?? ''
  ..status = json['status'] as String? ?? ''
  ..items = (json['items'] as List<dynamic>?)?.map((e) => CprItem.fromJson(e as Map<String, dynamic>)).toList() ?? []
  ..addedBy = json['addedBy'] == null ? null : NsUser.fromJson(json['addedBy'] as Map<String, dynamic>)
  ..sentBy = json['sentBy'] == null ? null : NsUser.fromJson(json['sentBy'] as Map<String, dynamic>)
  ..addedOn = json['addedOn'] as String? ?? ''
  ..sentOn = json['sentOn'] as String? ?? ''
  ..id = json['id'] as int? ?? 0
  ..isExpanded = json['isExpanded'] as bool? ?? false;

Map<String, dynamic> _$CprActivityToJson(CprActivity instance) => <String, dynamic>{
      'supplier': instance.supplier,
      'status': instance.status,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'addedBy': instance.addedBy?.toJson(),
      'sentBy': instance.sentBy?.toJson(),
      'addedOn': instance.addedOn,
      'sentOn': instance.sentOn,
      'id': instance.id,
      'isExpanded': instance.isExpanded,
    };
