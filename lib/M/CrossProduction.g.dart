// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CrossProduction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CrossProductionAdapter extends TypeAdapter<CrossProduction> {
  @override
  final int typeId = 25;

  @override
  CrossProduction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CrossProduction()
      ..id = fields[1] == null ? 0 : fields[1] as int
      ..ticketId = fields[2] == null ? 0 : fields[2] as int
      ..fromFactoryId = fields[3] == null ? 0 : fields[3] as int
      ..toFactoryId = fields[4] == null ? 0 : fields[4] as int
      ..uptime = fields[101] == null ? 0 : fields[101] as int;
  }

  @override
  void write(BinaryWriter writer, CrossProduction obj) {
    writer
      ..writeByte(5)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.ticketId)
      ..writeByte(3)
      ..write(obj.fromFactoryId)
      ..writeByte(4)
      ..write(obj.toFactoryId)
      ..writeByte(101)
      ..write(obj.uptime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CrossProductionAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CrossProduction _$CrossProductionFromJson(Map<String, dynamic> json) => CrossProduction()
  ..uptime = json['uptime'] as int? ?? 0
  ..id = json['id'] as int? ?? 0
  ..ticketId = json['ticketId'] as int? ?? 0
  ..fromFactoryId = json['fromFactoryId'] as int? ?? 0
  ..toFactoryId = json['toFactoryId'] as int? ?? 0;

Map<String, dynamic> _$CrossProductionToJson(CrossProduction instance) => <String, dynamic>{
      'uptime': instance.uptime,
      'id': instance.id,
      'ticketId': instance.ticketId,
      'fromFactoryId': instance.fromFactoryId,
      'toFactoryId': instance.toFactoryId,
    };
