// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DeviceLog.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeviceLogAdapter extends TypeAdapter<DeviceLog> {
  @override
  final int typeId = 23;

  @override
  DeviceLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeviceLog()
      ..id = fields[1] as int?
      ..tab = fields[2] == null ? 0 : fields[2] as int
      ..stylus = fields[3] == null ? 0 : fields[3] as int
      ..dnt = fields[4] as int?
      ..userId = fields[5] as int?
      ..tabId = fields[6] as int?;
  }

  @override
  void write(BinaryWriter writer, DeviceLog obj) {
    writer
      ..writeByte(6)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.tab)
      ..writeByte(3)
      ..write(obj.stylus)
      ..writeByte(4)
      ..write(obj.dnt)
      ..writeByte(5)
      ..write(obj.userId)
      ..writeByte(6)
      ..write(obj.tabId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DeviceLogAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceLog _$DeviceLogFromJson(Map<String, dynamic> json) => DeviceLog()
  ..id = json['id'] as int?
  ..tab = json['tab'] as int? ?? 0
  ..stylus = json['stylus'] as int? ?? 0
  ..dnt = json['dnt'] as int?
  ..userId = json['userId'] as int?
  ..tabId = json['tabId'] as int?;

Map<String, dynamic> _$DeviceLogToJson(DeviceLog instance) => <String, dynamic>{
      'id': instance.id,
      'tab': instance.tab,
      'stylus': instance.stylus,
      'dnt': instance.dnt,
      'userId': instance.userId,
      'tabId': instance.tabId,
    };
