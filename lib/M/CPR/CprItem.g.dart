// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CprItem.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CprItem _$CprItemFromJson(Map<String, dynamic> json) => CprItem()
  ..item = json['item'] as String? ?? ''
  ..qty = json['qty'] as String? ?? ''
  ..checked = json['checked'] as int? ?? 0
  ..dnt = json['dnt'] as String? ?? ''
  ..userId = json['userId'] as int? ?? -1
  ..id = json['id'] as int? ?? 0
  ..supplier = json['supplier'] as String?
  ..selected = json['selected'] as bool? ?? false;

Map<String, dynamic> _$CprItemToJson(CprItem instance) => <String, dynamic>{
      'item': instance.item,
      'qty': instance.qty,
      'checked': instance.checked,
      'dnt': instance.dnt,
      'userId': instance.userId,
      'id': instance.id,
      'supplier': instance.supplier,
      'selected': instance.selected,
    };
