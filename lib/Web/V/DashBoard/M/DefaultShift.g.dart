// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DefaultShift.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DefaultShift _$DefaultShiftFromJson(Map<String, dynamic> json) => DefaultShift()
  ..id = json['id'] as int? ?? 0
  ..startAt = json['startAt'] as String?
  ..endAt = json['endAt'] as String?
  ..shiftName = json['shiftName'] as String?
  ..deleted = json['deleted'] as int? ?? 0
  ..duration = (json['duration'] as num?)?.toDouble() ?? 0
  ..factory = json['factory'] as String?;

Map<String, dynamic> _$DefaultShiftToJson(DefaultShift instance) => <String, dynamic>{
      'id': instance.id,
      'startAt': instance.startAt,
      'endAt': instance.endAt,
      'shiftName': instance.shiftName,
      'deleted': instance.deleted,
      'duration': instance.duration,
      'factory': instance.factory,
    };
