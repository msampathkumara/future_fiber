// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Progress _$ProgressFromJson(Map<String, dynamic> json) {
  return Progress()
    ..doAt = json['doAt'] as int?
    ..finishedAt = json['finishedAt']
    ..finishedBy = json['finishedBy']
    ..finishedOn = json['finishedOn'] as String?
    ..id = json['id'] as int?
    ..nextOperationNo = json['nextOperationNo'] as int?
    ..operation = json['operation'] as String?
    ..operationNo = json['operationNo'] as int?
    ..status = json['status'] as int?
    ..ticketId = json['ticketId'] as int?
    ..upon = json['upon'] as String?;
}

Map<String, dynamic> _$ProgressToJson(Progress instance) => <String, dynamic>{
      'doAt': instance.doAt,
      'finishedAt': instance.finishedAt,
      'finishedBy': instance.finishedBy,
      'finishedOn': instance.finishedOn,
      'id': instance.id,
      'nextOperationNo': instance.nextOperationNo,
      'operation': instance.operation,
      'operationNo': instance.operationNo,
      'status': instance.status,
      'ticketId': instance.ticketId,
      'upon': instance.upon,
    };