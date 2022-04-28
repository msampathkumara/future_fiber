// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'LocalFileVersion.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalFileVersionAdapter extends TypeAdapter<LocalFileVersion> {
  @override
  final int typeId = 8;

  @override
  LocalFileVersion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalFileVersion(
      fields[0] == null ? 0 : fields[0] as int,
      fields[1] == null ? 0 : fields[1] as int,
      fields[2] == null ? '' : fields[2] as String,
    )
      ..id = fields[100] == null ? -1 : fields[100] as int
      ..uptime = fields[101] == null ? 0 : fields[101] as int;
  }

  @override
  void write(BinaryWriter writer, LocalFileVersion obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.ticketId)
      ..writeByte(1)
      ..write(obj.version)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(100)
      ..write(obj.id)
      ..writeByte(101)
      ..write(obj.uptime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is LocalFileVersionAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocalFileVersion _$LocalFileVersionFromJson(Map<String, dynamic> json) => LocalFileVersion(
      json['ticketId'] as int? ?? 0,
      json['version'] as int? ?? 0,
      json['type'] as String? ?? '',
    )
      ..id = json['id'] as int
      ..uptime = json['uptime'] as int? ?? 0;

Map<String, dynamic> _$LocalFileVersionToJson(LocalFileVersion instance) => <String, dynamic>{
      'id': instance.id,
      'uptime': instance.uptime,
      'ticketId': instance.ticketId,
      'version': instance.version,
      'type': instance.type,
    };
