// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'up_on.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UponsAdapter extends TypeAdapter<Upons> {
  @override
  final int typeId = 4;

  @override
  Upons read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Upons()
      ..tickets = fields[1] == null ? 0 : fields[1] as int
      ..deletedTicketsIds = fields[2] == null ? 0 : fields[2] as int
      ..completedTicketsIds = fields[3] == null ? 0 : fields[3] as int
      ..users = fields[4] == null ? 0 : fields[4] as int
      ..factorySections = fields[5] == null ? 0 : fields[5] as int
      ..standardTickets = fields[6] == null ? 0 : fields[6] as int
      ..id = fields[100] == null ? -1 : fields[100] as int
      ..uptime = fields[101] == null ? 0 : fields[101] as int;
  }

  @override
  void write(BinaryWriter writer, Upons obj) {
    writer
      ..writeByte(8)
      ..writeByte(1)
      ..write(obj.tickets)
      ..writeByte(2)
      ..write(obj.deletedTicketsIds)
      ..writeByte(3)
      ..write(obj.completedTicketsIds)
      ..writeByte(4)
      ..write(obj.users)
      ..writeByte(5)
      ..write(obj.factorySections)
      ..writeByte(6)
      ..write(obj.standardTickets)
      ..writeByte(100)
      ..write(obj.id)
      ..writeByte(101)
      ..write(obj.uptime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UponsAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Upons _$UponsFromJson(Map<String, dynamic> json) => Upons()
  ..id = json['id'] as int
  ..uptime = json['uptime'] as int? ?? 0
  ..tickets = json['tickets'] as int? ?? 0
  ..deletedTicketsIds = json['deletedTicketsIds'] as int? ?? 0
  ..completedTicketsIds = json['completedTicketsIds'] as int? ?? 0
  ..users = json['users'] as int? ?? 0
  ..factorySections = json['factorySections'] as int? ?? 0
  ..standardTickets = json['standardTickets'] as int? ?? 0;

Map<String, dynamic> _$UponsToJson(Upons instance) => <String, dynamic>{
      'id': instance.id,
      'uptime': instance.uptime,
      'tickets': instance.tickets,
      'deletedTicketsIds': instance.deletedTicketsIds,
      'completedTicketsIds': instance.completedTicketsIds,
      'users': instance.users,
      'factorySections': instance.factorySections,
      'standardTickets': instance.standardTickets,
    };
