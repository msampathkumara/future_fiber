// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ServerResponceMap.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServerResponceMap _$ServerResponceMapFromJson(Map<String, dynamic> json) =>
    ServerResponceMap()
      ..userRFCredentials = json['userRFCredentials'] == null
          ? null
          : UserRFCredentials.fromJson(
              json['userRFCredentials'] as Map<String, dynamic>)
      ..operationMinMax = json['operationMinMax'] == null
          ? null
          : OperationMinMax.fromJson(
              json['operationMinMax'] as Map<String, dynamic>)
      ..errorResponce = json['errorResponce'] == null
          ? null
          : ErrorResponce.fromJson(
              json['errorResponce'] as Map<String, dynamic>)
      ..done = json['done'] as bool?
      ..progressList = (json['progressList'] as List<dynamic>?)
              ?.map((e) => Progress.fromJson(e as Map<String, dynamic>))
              .toList() ??
          []
      ..flags = (json['flags'] as List<dynamic>?)
              ?.map((e) => TicketFlag.fromJson(e as Map<String, dynamic>))
              .toList() ??
          []
      ..flagsHistory = (json['flagsHistory'] as List<dynamic>?)
              ?.map((e) => TicketFlag.fromJson(e as Map<String, dynamic>))
              .toList() ??
          []
      ..printList = (json['printList'] as List<dynamic>?)
              ?.map((e) => TicketPrint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          []
      ..ticketHistory = (json['ticketHistory'] as List<dynamic>?)
              ?.map((e) => TicketHistory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

Map<String, dynamic> _$ServerResponceMapToJson(ServerResponceMap instance) =>
    <String, dynamic>{
      'userRFCredentials': instance.userRFCredentials?.toJson(),
      'operationMinMax': instance.operationMinMax?.toJson(),
      'errorResponce': instance.errorResponce?.toJson(),
      'done': instance.done,
      'progressList': instance.progressList.map((e) => e.toJson()).toList(),
      'flags': instance.flags.map((e) => e.toJson()).toList(),
      'flagsHistory': instance.flagsHistory.map((e) => e.toJson()).toList(),
      'printList': instance.printList.map((e) => e.toJson()).toList(),
      'ticketHistory': instance.ticketHistory.map((e) => e.toJson()).toList(),
    };
