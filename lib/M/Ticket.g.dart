// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Ticket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ticket _$TicketFromJson(Map<String, dynamic> json) {
  return Ticket()
    ..mo = json['mo'] as String?
    ..oe = json['oe'] as String?
    ..finished = json['finished'] as int
    ..uptime = json['uptime'] as int
    ..file = json['file'] as int
    ..sheet = json['sheet'] as int
    ..dir = json['dir'] as int
    ..id = json['id'] as int
    ..isRed = json['isRed'] as int
    ..isRush = json['isRush'] as int
    ..isSk = json['isSk'] as int
    ..inPrint = json['inPrint'] as int
    ..isGr = json['isGr'] as int
    ..isError = json['isError'] as int
    ..canOpen = json['canOpen'] as int
    ..isSort = json['isSort'] as int
    ..isHold = json['isHold'] as int
    ..fileVersion = json['fileVersion'] as int
    ..production = json['production'] as String?
    ..progress = (json['progress'] as num).toDouble();
}

Map<String, dynamic> _$TicketToJson(Ticket instance) => <String, dynamic>{
      'mo': instance.mo,
      'oe': instance.oe,
      'finished': instance.finished,
      'uptime': instance.uptime,
      'file': instance.file,
      'sheet': instance.sheet,
      'dir': instance.dir,
      'id': instance.id,
      'isRed': instance.isRed,
      'isRush': instance.isRush,
      'isSk': instance.isSk,
      'inPrint': instance.inPrint,
      'isGr': instance.isGr,
      'isError': instance.isError,
      'canOpen': instance.canOpen,
      'isSort': instance.isSort,
      'isHold': instance.isHold,
      'fileVersion': instance.fileVersion,
      'production': instance.production,
      'progress': instance.progress,
    };
