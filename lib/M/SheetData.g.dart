// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SheetData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SheetData _$SheetDataFromJson(Map<String, dynamic> json) => SheetData()
  ..mo = json['mo'] as String?
  ..oe = json['oe'] as String?
  ..operationNo = json['operationNo'] as int?
  ..next = json['next'] as int
  ..operation = json['operation'] as String?
  ..pool = json['pool'] as String?
  ..deliveryDate = json['deliveryDate'] as String?
  ..done = json['done'] as int? ?? 0
  ..user = json['user'] as int?
  ..uptime = json['uptime'] as String?
  ..ticketId = json['ticketId'] as int? ?? 0
  ..shipDate = json['shipDate'] as String?;

Map<String, dynamic> _$SheetDataToJson(SheetData instance) => <String, dynamic>{
      'mo': instance.mo,
      'oe': instance.oe,
      'operationNo': instance.operationNo,
      'next': instance.next,
      'operation': instance.operation,
      'pool': instance.pool,
      'deliveryDate': instance.deliveryDate,
      'done': instance.done,
      'user': instance.user,
      'uptime': instance.uptime,
      'ticketId': instance.ticketId,
      'shipDate': instance.shipDate,
    };
