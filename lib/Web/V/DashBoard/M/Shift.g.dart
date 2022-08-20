// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Shift.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Shift _$ShiftFromJson(Map<String, dynamic> json) => Shift()
  ..id = json['id'] as int? ?? 0
  ..startAt = json['startAt'] as String?
  ..endAt = json['endAt'] as String?
  ..shiftName = json['shiftName'] as String?
  ..deleted = json['deleted'] as int? ?? 0;

Map<String, dynamic> _$ShiftToJson(Shift instance) => <String, dynamic>{
      'id': instance.id,
      'startAt': instance.startAt,
      'endAt': instance.endAt,
      'shiftName': instance.shiftName,
      'deleted': instance.deleted,
    };
