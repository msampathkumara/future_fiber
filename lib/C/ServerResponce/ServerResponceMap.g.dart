// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ServerResponceMap.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServerResponceMap _$ServerResponceMapFromJson(Map<String, dynamic> json) {
  return ServerResponceMap()
    ..userRFCredentials = json['userRFCredentials'] == null
        ? null
        : UserRFCredentials.fromJson(
            json['userRFCredentials'] as Map<String, dynamic>)
    ..operationMinMax = json['operationMinMax'] == null
        ? null
        : OperationMinMax.fromJson(
            json['operationMinMax'] as Map<String, dynamic>)
    ..done = json['done'] as bool?;
}

Map<String, dynamic> _$ServerResponceMapToJson(ServerResponceMap instance) =>
    <String, dynamic>{
      'userRFCredentials': instance.userRFCredentials?.toJson(),
      'operationMinMax': instance.operationMinMax?.toJson(),
      'done': instance.done,
    };
