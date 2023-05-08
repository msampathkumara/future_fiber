// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'KitItem.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KitItem _$KitItemFromJson(Map<String, dynamic> json) => KitItem()
  ..item = json['item'] as String? ?? ''
  ..qty = json['qty'] as String? ?? ''
  ..checked = json['checked'] as int? ?? 0
  ..dnt = json['dnt'] as String? ?? ''
  ..userId = json['userId'] as int? ?? -1
  ..id = json['id'] as int? ?? 0
  ..selected = json['selected'] as bool? ?? false
  ..saved = json['saved'] as bool? ?? false;

Map<String, dynamic> _$KitItemToJson(KitItem instance) =>
    <String, dynamic>{
      'item': instance.item,
      'qty': instance.qty,
      'checked': instance.checked,
      'dnt': instance.dnt,
      'userId': instance.userId,
      'id': instance.id,
      'selected': instance.selected,
      'saved': instance.saved,
    };
