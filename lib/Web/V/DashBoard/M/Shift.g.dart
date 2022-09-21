// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Shift.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Shift _$ShiftFromJson(Map<String, dynamic> json) => Shift()
  ..id = json['id'] as int? ?? 0
  ..startAt = Shift.stringToDateTime(json['startAt'])
  ..endAt = Shift.stringToDateTime(json['endAt'])
  ..shiftName = json['shiftName'] as String?
  ..deleted = json['deleted'] as int? ?? 0
  ..duration = (json['duration'] as num?)?.toDouble() ?? 0
  ..factoryId = json['factoryId'] as int? ?? 0
  ..factoryName = json['factoryName'] as String? ?? '';

Map<String, dynamic> _$ShiftToJson(Shift instance) => <String, dynamic>{
      'id': instance.id,
      'startAt': Shift.dateTimeToString(instance.startAt),
      'endAt': Shift.dateTimeToString(instance.endAt),
      'shiftName': instance.shiftName,
      'deleted': instance.deleted,
      'duration': instance.duration,
      'factoryId': instance.factoryId,
      'factoryName': instance.factoryName,
    };
