// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'HiveClass.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveClassAdapter extends TypeAdapter<HiveClass> {
  @override
  final int typeId = 100;

  @override
  HiveClass read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveClass()
      ..id = fields[100] == null ? -1 : fields[100] as int
      ..uptime = fields[101] == null ? 0 : fields[101] as int;
  }

  @override
  void write(BinaryWriter writer, HiveClass obj) {
    writer
      ..writeByte(2)
      ..writeByte(100)
      ..write(obj.id)
      ..writeByte(101)
      ..write(obj.uptime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is HiveClassAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HiveClass _$HiveClassFromJson(Map<String, dynamic> json) => HiveClass()
  ..id = json['id'] as int
  ..uptime = json['uptime'] as int? ?? 0;

Map<String, dynamic> _$HiveClassToJson(HiveClass instance) => <String, dynamic>{
      'id': instance.id,
      'uptime': instance.uptime,
    };
