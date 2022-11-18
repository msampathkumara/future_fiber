// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Ticket.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TicketAdapter extends TypeAdapter<Ticket> {
  @override
  final int typeId = 1;

  @override
  Ticket read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Ticket()
      ..mo = fields[0] as String?
      ..oe = fields[1] as String?
      ..uptime = fields[3] == null ? 0 : fields[3] as int
      ..file = fields[4] == null ? 0 : fields[4] as int
      ..sheet = fields[5] == null ? 0 : fields[5] as int
      ..dir = fields[6] == null ? 0 : fields[6] as int
      ..id = fields[7] == null ? 0 : fields[7] as int
      ..isRed = fields[8] == null ? 0 : fields[8] as int
      ..isRush = fields[9] == null ? 0 : fields[9] as int
      ..isSk = fields[10] == null ? 0 : fields[10] as int
      ..inPrint = fields[11] == null ? 0 : fields[11] as int
      ..isGr = fields[12] == null ? 0 : fields[12] as int
      ..isError = fields[13] == null ? 0 : fields[13] as int
      ..canOpen = fields[14] == null ? 0 : fields[14] as int
      ..isSort = fields[15] == null ? 0 : fields[15] as int
      ..isHold = fields[16] == null ? 0 : fields[16] as int
      ..fileVersion = fields[17] == null ? 0 : fields[17] as int
      ..progress = fields[18] == null ? 0 : fields[18] as int
      ..completed = fields[19] == null ? 0 : fields[19] as int
      ..nowAt = fields[20] == null ? 0 : fields[20] as int
      ..openSections = fields[23] == null ? [] : (fields[23] as List).cast<dynamic>()
      ..shipDate = fields[24] == null ? '' : fields[24] as String
      ..deliveryDate = fields[25] == null ? '' : fields[25] as String
      ..production = fields[26] as String?
      ..isQc = fields[28] == null ? 0 : fields[28] as int
      ..isQa = fields[29] == null ? 0 : fields[29] as int
      ..completedOn = fields[30] as String?
      ..isStarted = fields[31] == null ? false : fields[31] as bool
      ..haveComments = fields[32] == null ? false : fields[32] as bool
      ..openAny = fields[33] == null ? false : fields[33] as bool
      ..kit = fields[34] == null ? 0 : fields[34] as int
      ..cpr = fields[35] == null ? 0 : fields[35] as int
      ..haveKit = fields[36] == null ? 0 : fields[36] as int
      ..haveCpr = fields[37] == null ? 0 : fields[37] as int
      ..cprReport = fields[38] == null ? [] : (fields[38] as List).cast<CprReport>()
      ..pool = fields[39] as String?;
  }

  @override
  void write(BinaryWriter writer, Ticket obj) {
    writer
      ..writeByte(36)
      ..writeByte(0)
      ..write(obj.mo)
      ..writeByte(1)
      ..write(obj.oe)
      ..writeByte(3)
      ..write(obj.uptime)
      ..writeByte(4)
      ..write(obj.file)
      ..writeByte(5)
      ..write(obj.sheet)
      ..writeByte(6)
      ..write(obj.dir)
      ..writeByte(7)
      ..write(obj.id)
      ..writeByte(8)
      ..write(obj.isRed)
      ..writeByte(9)
      ..write(obj.isRush)
      ..writeByte(10)
      ..write(obj.isSk)
      ..writeByte(11)
      ..write(obj.inPrint)
      ..writeByte(12)
      ..write(obj.isGr)
      ..writeByte(13)
      ..write(obj.isError)
      ..writeByte(14)
      ..write(obj.canOpen)
      ..writeByte(15)
      ..write(obj.isSort)
      ..writeByte(16)
      ..write(obj.isHold)
      ..writeByte(17)
      ..write(obj.fileVersion)
      ..writeByte(18)
      ..write(obj.progress)
      ..writeByte(19)
      ..write(obj.completed)
      ..writeByte(20)
      ..write(obj.nowAt)
      ..writeByte(23)
      ..write(obj.openSections)
      ..writeByte(24)
      ..write(obj.shipDate)
      ..writeByte(25)
      ..write(obj.deliveryDate)
      ..writeByte(26)
      ..write(obj.production)
      ..writeByte(28)
      ..write(obj.isQc)
      ..writeByte(29)
      ..write(obj.isQa)
      ..writeByte(30)
      ..write(obj.completedOn)
      ..writeByte(31)
      ..write(obj.isStarted)
      ..writeByte(32)
      ..write(obj.haveComments)
      ..writeByte(33)
      ..write(obj.openAny)
      ..writeByte(34)
      ..write(obj.kit)
      ..writeByte(35)
      ..write(obj.cpr)
      ..writeByte(36)
      ..write(obj.haveKit)
      ..writeByte(37)
      ..write(obj.haveCpr)
      ..writeByte(38)
      ..write(obj.cprReport)
      ..writeByte(39)
      ..write(obj.pool);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TicketAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ticket _$TicketFromJson(Map<String, dynamic> json) => Ticket()
  ..mo = json['mo'] as String?
  ..oe = json['oe'] as String?
  ..uptime = json['uptime'] as int? ?? 0
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
  ..openSections = json['openSections'] == null ? [] : Ticket.stringToList(json['openSections'])
  ..shipDate = json['shipDate'] as String? ?? ''
  ..deliveryDate = json['deliveryDate'] as String? ?? ''
  ..production = json['production'] as String?
  ..isQc = json['isQc'] as int? ?? 0
  ..isQa = json['isQa'] as int? ?? 0
  ..completedOn = json['completedOn'] as String?
  ..isStarted = json['isStarted'] == null ? false : Ticket.boolFromO(json['isStarted'])
  ..haveComments = json['haveComments'] == null ? false : Ticket.boolFromO(json['haveComments'])
  ..openAny = json['openAny'] == null ? false : Ticket.boolFromO(json['openAny'])
  ..kit = json['kit'] as int? ?? 0
  ..cpr = json['cpr'] as int? ?? 0
  ..haveKit = json['haveKit'] as int? ?? 0
  ..haveCpr = json['haveCpr'] as int? ?? 0
  ..cprReport = json['cprReport'] == null ? [] : Ticket.stringToCprReportList(json['cprReport'])
  ..pool = json['pool'] as String?
  ..loading = json['loading'] as bool? ?? false;

Map<String, dynamic> _$TicketToJson(Ticket instance) => <String, dynamic>{
      'mo': instance.mo,
      'oe': instance.oe,
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
      'progress': instance.progress,
      'completed': instance.completed,
      'nowAt': instance.nowAt,
      'openSections': instance.openSections,
      'shipDate': instance.shipDate,
      'deliveryDate': instance.deliveryDate,
      'production': instance.production,
      'isQc': instance.isQc,
      'isQa': instance.isQa,
      'completedOn': instance.completedOn,
      'isStarted': Ticket.boolToInt(instance.isStarted),
      'haveComments': Ticket.boolToInt(instance.haveComments),
      'openAny': Ticket.boolToInt(instance.openAny),
      'kit': instance.kit,
      'cpr': instance.cpr,
      'haveKit': instance.haveKit,
      'haveCpr': instance.haveCpr,
      'cprReport': instance.cprReport.map((e) => e.toJson()).toList(),
      'pool': instance.pool,
      'loading': instance.loading,
    };
