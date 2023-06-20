// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserConfigAdapter extends TypeAdapter<UserConfig> {
  @override
  final int typeId = 3;

  @override
  UserConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserConfig()
      ..user = fields[0] as NsUser?
      ..welcomeScreenShown = fields[1] == null ? false : fields[1] as bool
      ..selectedSection = fields[2] as Section?
      ..upon = fields[3] as Upons
      ..triggerEventTimes = fields[4] as TriggerEventTimes
      ..isTest = fields[5] == null ? false : fields[5] as bool
      ..id = fields[100] == null ? -1 : fields[100] as int
      ..uptime = fields[101] == null ? 0 : fields[101] as int;
  }

  @override
  void write(BinaryWriter writer, UserConfig obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.user)
      ..writeByte(1)
      ..write(obj.welcomeScreenShown)
      ..writeByte(2)
      ..write(obj.selectedSection)
      ..writeByte(3)
      ..write(obj.upon)
      ..writeByte(4)
      ..write(obj.triggerEventTimes)
      ..writeByte(5)
      ..write(obj.isTest)
      ..writeByte(100)
      ..write(obj.id)
      ..writeByte(101)
      ..write(obj.uptime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UserConfigAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserConfig _$UserConfigFromJson(Map<String, dynamic> json) =>
    UserConfig()
  ..id = json['id'] as int
  ..uptime = json['uptime'] as int? ?? 0
  ..user = json['user'] == null ? null : NsUser.fromJson(json['user'] as Map<String, dynamic>)
  ..welcomeScreenShown = json['welcomeScreenShown'] as bool? ?? false
  ..selectedSection = json['selectedSection'] == null ? null : Section.fromJson(json['selectedSection'] as Map<String, dynamic>)
  ..upon = Upons.fromJson(json['upon'] as Map<String, dynamic>)
  ..triggerEventTimes = TriggerEventTimes.fromJson(json['triggerEventTimes'] as Map<String, dynamic>)
  ..isTest = json['isTest'] as bool? ?? false;

Map<String, dynamic> _$UserConfigToJson(UserConfig instance) => <String, dynamic>{
      'id': instance.id,
      'uptime': instance.uptime,
      'user': instance.user?.toJson(),
      'welcomeScreenShown': instance.welcomeScreenShown,
      'selectedSection': instance.selectedSection?.toJson(),
      'upon': instance.upon.toJson(),
      'triggerEventTimes': instance.triggerEventTimes.toJson(),
      'isTest': instance.isTest,
    };
