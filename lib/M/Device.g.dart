// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Device.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeviceAdapter extends TypeAdapter<Device> {
  @override
  final int typeId = 22;

  @override
  Device read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Device()
      ..id = fields[1] as int?
      ..name = fields[2] == null ? '' : fields[2] as String
      ..imei = fields[3] as String?
      ..model = fields[4] as String?
      ..modelNumber = fields[5] as String?
      ..serialNumber = fields[6] as String?
      ..tab = fields[7] == null ? 0 : fields[7] as int?
      ..stylus = fields[8] == null ? 0 : fields[8] as int
      ..logOn = fields[9] as String?
      ..outOn = fields[10] as String?
      ..userId = fields[11] as int?
      ..longitude = fields[12] as int?
      ..latitude = fields[13] as int?
      ..upon = fields[14] == null ? 0 : fields[14] as int?
      ..battery = fields[15] as int?
      ..ip = fields[16] as String?;
  }

  @override
  void write(BinaryWriter writer, Device obj) {
    writer
      ..writeByte(16)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.imei)
      ..writeByte(4)
      ..write(obj.model)
      ..writeByte(5)
      ..write(obj.modelNumber)
      ..writeByte(6)
      ..write(obj.serialNumber)
      ..writeByte(7)
      ..write(obj.tab)
      ..writeByte(8)
      ..write(obj.stylus)
      ..writeByte(9)
      ..write(obj.logOn)
      ..writeByte(10)
      ..write(obj.outOn)
      ..writeByte(11)
      ..write(obj.userId)
      ..writeByte(12)
      ..write(obj.longitude)
      ..writeByte(13)
      ..write(obj.latitude)
      ..writeByte(14)
      ..write(obj.upon)
      ..writeByte(15)
      ..write(obj.battery)
      ..writeByte(16)
      ..write(obj.ip);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DeviceAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Device _$DeviceFromJson(Map<String, dynamic> json) => Device()
  ..id = json['id'] as int?
  ..name = json['name'] as String? ?? ''
  ..imei = json['imei'] as String?
  ..model = json['model'] as String?
  ..modelNumber = json['modelNumber'] as String?
  ..serialNumber = json['serialNumber'] as String?
  ..tab = json['tab'] as int? ?? 0
  ..stylus = json['stylus'] as int? ?? 0
  ..logOn = json['logOn'] as String?
  ..outOn = json['outOn'] as String?
  ..userId = json['userId'] as int?
  ..longitude = json['longitude'] as int?
  ..latitude = json['latitude'] as int?
  ..upon = json['upon'] as int? ?? 0
  ..battery = json['battery'] as int?
  ..ip = json['ip'] as String?;

Map<String, dynamic> _$DeviceToJson(Device instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'imei': instance.imei,
      'model': instance.model,
      'modelNumber': instance.modelNumber,
      'serialNumber': instance.serialNumber,
      'tab': instance.tab,
      'stylus': instance.stylus,
      'logOn': instance.logOn,
      'outOn': instance.outOn,
      'userId': instance.userId,
      'longitude': instance.longitude,
      'latitude': instance.latitude,
      'upon': instance.upon,
      'battery': instance.battery,
      'ip': instance.ip,
    };
