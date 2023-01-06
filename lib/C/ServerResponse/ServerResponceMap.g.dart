// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ServerResponceMap.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServerResponseMap _$ServerResponseMapFromJson(Map<String, dynamic> json) => ServerResponseMap()
  ..userRFCredentials = json['userRFCredentials'] == null ? null : UserRFCredentials.fromJson(json['userRFCredentials'] as Map<String, dynamic>)
  ..operationMinMax = json['operationMinMax'] == null ? null : OperationMinMax.fromJson(json['operationMinMax'] as Map<String, dynamic>)
  ..done = json['done'] as bool?
  ..ticketProgress = json['ticketProgress'] as Map<String, dynamic>? ?? {}
  ..ticketProgressDetails = (json['ticketProgressDetails'] as List<dynamic>?)?.map((e) => Progress.fromJson(e as Map<String, dynamic>)).toList() ?? []
  ..flags = (json['flags'] as List<dynamic>?)?.map((e) => TicketFlag.fromJson(e as Map<String, dynamic>)).toList() ?? []
  ..flagsHistory = (json['flagsHistory'] as List<dynamic>?)?.map((e) => TicketFlag.fromJson(e as Map<String, dynamic>)).toList() ?? []
  ..ticketComments = (json['ticketComments'] as List<dynamic>?)?.map((e) => TicketComment.fromJson(e as Map<String, dynamic>)).toList() ?? []
  ..cprItems = (json['cprItems'] as List<dynamic>?)?.map((e) => CprItem.fromJson(e as Map<String, dynamic>)).toList() ?? []
  ..cprs = (json['cprs'] as List<dynamic>?)?.map((e) => CPR.fromJson(e as Map<String, dynamic>)).toList() ?? [];

Map<String, dynamic> _$ServerResponseMapToJson(ServerResponseMap instance) =>
    <String, dynamic>{
      'userRFCredentials': instance.userRFCredentials?.toJson(),
      'operationMinMax': instance.operationMinMax?.toJson(),
      'done': instance.done,
      'ticketProgress': instance.ticketProgress,
      'ticketProgressDetails': instance.ticketProgressDetails.map((e) => e.toJson()).toList(),
      'flags': instance.flags.map((e) => e.toJson()).toList(),
      'flagsHistory': instance.flagsHistory.map((e) => e.toJson()).toList(),
      'ticketComments': instance.ticketComments.map((e) => e.toJson()).toList(),
      'cprItems': instance.cprItems.map((e) => e.toJson()).toList(),
      'cprs': instance.cprs.map((e) => e.toJson()).toList(),
    };
