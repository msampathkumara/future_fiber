// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Section.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SectionAdapter extends TypeAdapter<Section> {
  @override
  final int typeId = 7;

  @override
  Section read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Section()
      ..id = fields[0] == null ? 0 : fields[0] as int
      ..sectionTitle = fields[1] == null ? '' : fields[1] as String
      ..factory = fields[2] == null ? '' : fields[2] as String
      ..loft = fields[3] == null ? 0 : fields[3] as int
      ..uptime = fields[101] == null ? 0 : fields[101] as int;
  }

  @override
  void write(BinaryWriter writer, Section obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sectionTitle)
      ..writeByte(2)
      ..write(obj.factory)
      ..writeByte(3)
      ..write(obj.loft)
      ..writeByte(101)
      ..write(obj.uptime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Section _$SectionFromJson(Map<String, dynamic> json) => Section()
  ..uptime = json['uptime'] as int? ?? 0
  ..id = json['id'] as int? ?? 0
  ..sectionTitle = json['sectionTitle'] as String? ?? '-'
  ..factory = json['factory'] as String? ?? '-'
  ..loft = json['loft'] as int? ?? 0;

Map<String, dynamic> _$SectionToJson(Section instance) => <String, dynamic>{
      'uptime': instance.uptime,
      'id': instance.id,
      'sectionTitle': instance.sectionTitle,
      'factory': instance.factory,
      'loft': instance.loft,
    };
