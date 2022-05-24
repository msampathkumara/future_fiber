// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Phones.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PhonesAdapter extends TypeAdapter<Phones> {
  @override
  final int typeId = 3;

  @override
  Phones read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Phones()
      ..id = fields[1] as int?
      ..number = fields[2] as String?
      ..userId = fields[3] as int?
      ..verified = fields[4] == null ? 0 : fields[4] as int;
  }

  @override
  void write(BinaryWriter writer, Phones obj) {
    writer
      ..writeByte(4)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.number)
      ..writeByte(3)
      ..write(obj.userId)
      ..writeByte(4)
      ..write(obj.verified);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PhonesAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Phones _$PhonesFromJson(Map<String, dynamic> json) => Phones()
  ..id = json['id'] as int?
  ..number = json['number'] as String?
  ..userId = json['userId'] as int?
  ..verified = json['verified'] as int? ?? 0;

Map<String, dynamic> _$PhonesToJson(Phones instance) => <String, dynamic>{
      'id': instance.id,
      'number': instance.number,
      'userId': instance.userId,
      'verified': instance.verified,
    };
