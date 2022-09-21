// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ProgressSummery.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProgressSummery _$ProgressSummeryFromJson(Map<String, dynamic> json) => ProgressSummery()
  ..volume = ProgressSummery.intFromString(json['volume'])
  ..factory = json['factory'] as String?
  ..sectionTitle = json['sectionTitle'] as String?
  ..doAt = json['doAt'] as num?
  ..status = json['status'] as num?
  ..startAt = json['startAt'] as String?
  ..endAt = json['endAt'] as String?
  ..p = json['p'] as String?
  ..shiftName = json['shiftName'] as String?
  ..defects = ProgressSummery.intFromString(json['defects'])
  ..wip = ProgressSummery.intFromString(json['wip'])
  ..employeeCount = ProgressSummery.intFromString(json['employeeCount'])
  ..capacity = ProgressSummery.numFromString(json['capacity'])
  ..taktTime = ProgressSummery.numFromString(json['taktTime'])
  ..cycleTime = ProgressSummery.numFromString(json['cycleTime'])
  ..efficiency = ProgressSummery.numFromString(json['efficiency'])
  ..defectsRate = ProgressSummery.numFromString(json['defectsRate'])
  ..date = ProgressSummery.stringToDateTime(json['date']);

Map<String, dynamic> _$ProgressSummeryToJson(ProgressSummery instance) => <String, dynamic>{
      'volume': instance.volume,
      'factory': instance.factory,
      'sectionTitle': instance.sectionTitle,
      'doAt': instance.doAt,
      'status': instance.status,
      'startAt': instance.startAt,
      'endAt': instance.endAt,
      'p': instance.p,
      'shiftName': instance.shiftName,
      'defects': instance.defects,
      'wip': instance.wip,
      'employeeCount': instance.employeeCount,
      'capacity': instance.capacity,
      'taktTime': instance.taktTime,
      'cycleTime': instance.cycleTime,
      'efficiency': instance.efficiency,
      'defectsRate': instance.defectsRate,
      'date': ProgressSummery.dateTimeToString(instance.date),
    };
