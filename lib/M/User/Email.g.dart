// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Email.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmailAdapter extends TypeAdapter<Email> {
  @override
  final int typeId = 24;

  @override
  Email read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Email()
      ..id = fields[1] as int?
      ..userId = fields[2] as int?
      ..email = fields[3] as String?
      ..verified = fields[4] == null ? 0 : fields[4] as int;
  }

  @override
  void write(BinaryWriter writer, Email obj) {
    writer
      ..writeByte(4)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.verified);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is EmailAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Email _$EmailFromJson(Map<String, dynamic> json) => Email()
  ..id = json['id'] as int?
  ..userId = json['userId'] as int?
  ..email = json['email'] as String?
  ..verified = json['verified'] as int? ?? 0;

Map<String, dynamic> _$EmailToJson(Email instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'email': instance.email,
      'verified': instance.verified,
    };
