// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CprReport.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CprReportAdapter extends TypeAdapter<CprReport> {
  @override
  final int typeId = 5;

  @override
  CprReport read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CprReport()
      ..status = fields[0] as String?
      ..type = fields[1] as String?
      ..count = fields[2] == null ? 0 : fields[2] as int
      ..itemCount = fields[3] == null ? 0 : fields[3] as int;
  }

  @override
  void write(BinaryWriter writer, CprReport obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.status)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.count)
      ..writeByte(3)
      ..write(obj.itemCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CprReportAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CprReport _$CprReportFromJson(Map<String, dynamic> json) => CprReport()
  ..status = json['status'] as String?
  ..type = json['type'] as String?
  ..count = json['count'] == null ? 0 : CprReport.intFromString(json['count'] as String)
  ..itemCount = json['itemCount'] == null ? 0 : CprReport.intFromString(json['itemCount'] as String);

Map<String, dynamic> _$CprReportToJson(CprReport instance) =>
    <String, dynamic>{
      'status': instance.status,
      'type': instance.type,
      'count': instance.count,
      'itemCount': instance.itemCount,
    };
