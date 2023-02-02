// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'TriggerEventTimes.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TriggerEventTimesAdapter extends TypeAdapter<TriggerEventTimes> {
  @override
  final int typeId = 25;

  @override
  TriggerEventTimes read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TriggerEventTimes()
      ..dbUpon = (fields[0] as Map).cast<dynamic, dynamic>()
      ..ticketComplete = fields[1] == null ? 0 : fields[1] as int
      ..standardLibrary = fields[2] == null ? 0 : fields[2] as int
      ..resetDb = fields[3] == null ? 0 : fields[3] as int
      ..users = fields[4] == null ? 0 : fields[4] as int;
  }

  @override
  void write(BinaryWriter writer, TriggerEventTimes obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.dbUpon)
      ..writeByte(1)
      ..write(obj.ticketComplete)
      ..writeByte(2)
      ..write(obj.standardLibrary)
      ..writeByte(3)
      ..write(obj.resetDb)
      ..writeByte(4)
      ..write(obj.users);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is TriggerEventTimesAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TriggerEventTimes _$TriggerEventTimesFromJson(Map<String, dynamic> json) => TriggerEventTimes()
  ..dbUpon = json['dbUpon'] as Map<String, dynamic>
  ..ticketComplete = json['ticketComplete'] as int? ?? 0
  ..standardLibrary = json['standardLibrary'] as int? ?? 0
  ..resetDb = json['resetDb'] as int? ?? 0
  ..users = json['users'] as int? ?? 0;

Map<String, dynamic> _$TriggerEventTimesToJson(TriggerEventTimes instance) => <String, dynamic>{
      'dbUpon': instance.dbUpon,
      'ticketComplete': instance.ticketComplete,
      'standardLibrary': instance.standardLibrary,
      'resetDb': instance.resetDb,
      'users': instance.users,
    };
