// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SheetData.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SheetDataAdapter extends TypeAdapter<SheetData> {
  @override
  final int typeId = 16;

  @override
  SheetData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SheetData()
      ..mo = fields[1] as String?
      ..oe = fields[2] as String?
      ..operationNo = fields[3] as int?
      ..next = fields[4] as int
      ..operation = fields[5] as String?
      ..pool = fields[6] as String?
      ..deliveryDate = fields[7] as String?
      ..done = fields[8] == null ? 0 : fields[8] as int?
      ..user = fields[9] as int?
      ..uptime = fields[10] as String?
      ..ticketId = fields[11] == null ? 0 : fields[11] as int
      ..shipDate = fields[12] as String?
      ..jobId = fields[13] as String?
      ..config = fields[14] as String?;
  }

  @override
  void write(BinaryWriter writer, SheetData obj) {
    writer
      ..writeByte(14)
      ..writeByte(1)
      ..write(obj.mo)
      ..writeByte(2)
      ..write(obj.oe)
      ..writeByte(3)
      ..write(obj.operationNo)
      ..writeByte(4)
      ..write(obj.next)
      ..writeByte(5)
      ..write(obj.operation)
      ..writeByte(6)
      ..write(obj.pool)
      ..writeByte(7)
      ..write(obj.deliveryDate)
      ..writeByte(8)
      ..write(obj.done)
      ..writeByte(9)
      ..write(obj.user)
      ..writeByte(10)
      ..write(obj.uptime)
      ..writeByte(11)
      ..write(obj.ticketId)
      ..writeByte(12)
      ..write(obj.shipDate)
      ..writeByte(13)
      ..write(obj.jobId)
      ..writeByte(14)
      ..write(obj.config);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SheetDataAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

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
  ..shipDate = json['shipDate'] as String?
  ..jobId = SheetData.intToString(json['jobId'])
  ..config = SheetData.intToString(json['config']);

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
      'jobId': instance.jobId,
      'config': instance.config,
    };
