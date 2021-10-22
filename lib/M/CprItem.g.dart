// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CprItem.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CprItem _$CprItemFromJson(Map<String, dynamic> json) => CprItem()
  ..item = json['item'] as String
  ..qty = json['qty'] as String
  ..checked = json['checked'] as int
  ..dnt = json['dnt'] as String
  ..user = json['user'] == null
      ? null
      : NsUser.fromJson(json['user'] as Map<String, dynamic>);

Map<String, dynamic> _$CprItemToJson(CprItem instance) => <String, dynamic>{
      'item': instance.item,
      'qty': instance.qty,
      'checked': instance.checked,
      'dnt': instance.dnt,
      'user': instance.user?.toJson(),
    };
