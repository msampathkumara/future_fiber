// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ShiftFactorySummery.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShiftFactorySummery _$ShiftFactorySummeryFromJson(Map<String, dynamic> json) => ShiftFactorySummery()
  ..volume = ShiftFactorySummery.intFromString(json['volume'])
  ..factory = json['factory'] as String?
  ..sectionTitle = json['sectionTitle'] as String?
  ..doAt = json['doAt'] as num?
  ..status = json['status'] as num?
  ..startAt = json['startAt'] as String?
  ..endAt = json['endAt'] as String?
  ..p = json['p'] as String?
  ..shiftName = json['shiftName'] as String?
  ..defects = ShiftFactorySummery.intFromString(json['defects'])
  ..wip = ShiftFactorySummery.intFromString(json['wip'])
  ..employeeCount = ShiftFactorySummery.intFromString(json['employeeCount'])
  ..startedTicketCount = ShiftFactorySummery.intFromString(json['startedTicketCount'])
  ..capacity = ShiftFactorySummery.numFromString(json['capacity'])
  ..taktTime = ShiftFactorySummery.numFromString(json['taktTime'])
  ..cycleTime = ShiftFactorySummery.numFromString(json['cycleTime'])
  ..efficiency = ShiftFactorySummery.numFromString(json['efficiency'])
  ..defectsRate = ShiftFactorySummery.numFromString(json['defectsRate'])
  ..backLog = ShiftFactorySummery.numFromString(json['backLog'])
  ..isCurrentShift = json['isCurrentShift'] == null ? false : ShiftFactorySummery.boolFromInt(json['isCurrentShift'] as int);

Map<String, dynamic> _$ShiftFactorySummeryToJson(ShiftFactorySummery instance) => <String, dynamic>{
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
      'startedTicketCount': instance.startedTicketCount,
      'capacity': instance.capacity,
      'taktTime': instance.taktTime,
      'cycleTime': instance.cycleTime,
      'efficiency': instance.efficiency,
      'defectsRate': instance.defectsRate,
      'backLog': instance.backLog,
      'isCurrentShift': instance.isCurrentShift,
    };
