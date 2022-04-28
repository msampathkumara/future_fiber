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
      ..id = fields[100] == null ? -1 : fields[100] as int
      ..uptime = fields[101] == null ? 0 : fields[101] as int;
  }

  @override
  void write(BinaryWriter writer, UserConfig obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.user)
      ..writeByte(1)
      ..write(obj.welcomeScreenShown)
      ..writeByte(2)
      ..write(obj.selectedSection)
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

UserConfig _$UserConfigFromJson(Map<String, dynamic> json) => UserConfig()
  ..id = json['id'] as int
  ..uptime = json['uptime'] as int? ?? 0
  ..user = json['user'] == null ? null : NsUser.fromJson(json['user'] as Map<String, dynamic>)
  ..welcomeScreenShown = json['welcomeScreenShown'] as bool? ?? false
  ..selectedSection = json['selectedSection'] == null ? null : Section.fromJson(json['selectedSection'] as Map<String, dynamic>);

Map<String, dynamic> _$UserConfigToJson(UserConfig instance) => <String, dynamic>{
      'id': instance.id,
      'uptime': instance.uptime,
      'user': instance.user?.toJson(),
      'welcomeScreenShown': instance.welcomeScreenShown,
      'selectedSection': instance.selectedSection?.toJson(),
    };
