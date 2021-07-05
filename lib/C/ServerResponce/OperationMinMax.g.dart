// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'OperationMinMax.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OperationMinMax _$OperationMinMaxFromJson(Map<String, dynamic> json) {
  return OperationMinMax()
    ..min = json['min'] as int?
    ..max = json['max'] as int?
    ..doAt = json['doAt'] as int?;
}

Map<String, dynamic> _$OperationMinMaxToJson(OperationMinMax instance) =>
    <String, dynamic>{
      'min': instance.min,
      'max': instance.max,
      'doAt': instance.doAt,
    };
