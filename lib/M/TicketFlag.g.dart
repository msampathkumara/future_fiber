// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'TicketFlag.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TicketFlagAdapter extends TypeAdapter<TicketFlag> {
  @override
  final int typeId = 2;

  @override
  TicketFlag read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TicketFlag()
      ..ticket = fields[1] == null ? 0 : fields[1] as int
      ..type = fields[2] == null ? '' : fields[2] as String
      ..comment = fields[3] == null ? '' : fields[3] as String
      ..user = fields[4] == null ? 0 : fields[4] as int
      ..dnt = fields[5] == null ? '' : fields[5] as String
      ..flaged = fields[6] == null ? 0 : fields[6] as int;
  }

  @override
  void write(BinaryWriter writer, TicketFlag obj) {
    writer
      ..writeByte(6)
      ..writeByte(1)
      ..write(obj.ticket)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.comment)
      ..writeByte(4)
      ..write(obj.user)
      ..writeByte(5)
      ..write(obj.dnt)
      ..writeByte(6)
      ..write(obj.flaged);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TicketFlagAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketFlag _$TicketFlagFromJson(Map<String, dynamic> json) => TicketFlag()
  ..ticket = json['ticket'] as int? ?? 0
  ..type = json['type'] as String? ?? ''
  ..comment = json['comment'] as String? ?? '-'
  ..user = json['user'] as int? ?? 0
  ..dnt = TicketFlag._stringFromInt(json['dnt'])
  ..flaged = json['flaged'] as int? ?? 0;

Map<String, dynamic> _$TicketFlagToJson(TicketFlag instance) =>
    <String, dynamic>{
      'ticket': instance.ticket,
      'type': instance.type,
      'comment': instance.comment,
      'user': instance.user,
      'dnt': instance.dnt,
      'flaged': instance.flaged,
    };
