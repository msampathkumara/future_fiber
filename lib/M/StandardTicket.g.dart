// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'StandardTicket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StandardTicket _$StandardTicketFromJson(Map<String, dynamic> json) =>
    StandardTicket()
      ..mo = json['mo'] as String?
      ..oe = json['oe'] as String?
      ..finished = json['finished'] as int? ?? 0
      ..file = json['file'] as int? ?? 0
      ..sheet = json['sheet'] as int? ?? 0
      ..dir = json['dir'] as int? ?? 0
      ..id = json['id'] as int? ?? 0
      ..isRed = json['isRed'] as int? ?? 0
      ..isRush = json['isRush'] as int? ?? 0
      ..isSk = json['isSk'] as int? ?? 0
      ..inPrint = json['inPrint'] as int? ?? 0
      ..isGr = json['isGr'] as int? ?? 0
      ..isError = json['isError'] as int? ?? 0
      ..canOpen = json['canOpen'] as int? ?? 0
      ..isSort = json['isSort'] as int? ?? 0
      ..isHold = json['isHold'] as int? ?? 0
      ..fileVersion = json['fileVersion'] as int? ?? 0
      ..progress = json['progress'] as int? ?? 0
      ..completed = json['completed'] as int? ?? 0
      ..nowAt = json['nowAt'] as int? ?? 0
      ..crossPro = json['crossPro'] as int? ?? 0
      ..crossProList = json['crossProList'] as String? ?? ''
      ..openSections = json['openSections'] as String? ?? ''
      ..shipDate = json['shipDate'] as int? ?? 0
      ..production = json['production'] as String?
      ..usedCount = json['usedCount'] as int? ?? 0
      ..uptime = json['uptime'] as int? ?? 0;

Map<String, dynamic> _$StandardTicketToJson(StandardTicket instance) =>
    <String, dynamic>{
      'mo': instance.mo,
      'oe': instance.oe,
      'finished': instance.finished,
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
      'progress': instance.progress,
      'completed': instance.completed,
      'nowAt': instance.nowAt,
      'crossPro': instance.crossPro,
      'crossProList': instance.crossProList,
      'openSections': instance.openSections,
      'shipDate': instance.shipDate,
      'production': instance.production,
      'usedCount': instance.usedCount,
      'uptime': instance.uptime,
    };
