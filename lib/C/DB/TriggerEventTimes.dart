import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'TriggerEventTimes.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 25)
class TriggerEventTimes {
  TriggerEventTimes();

  @HiveField(0)
  @JsonKey(includeIfNull: true)
  Map dbUpon = {};

  @HiveField(1, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int ticketComplete = 0;

  @HiveField(2, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int standardLibrary = 0;

  @HiveField(3, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int resetDb = 0;

  @HiveField(4, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int users = 0;

  factory TriggerEventTimes.fromJson(Map<String, dynamic> json) => _$TriggerEventTimesFromJson(json);

  Map<String, dynamic> toJson() => _$TriggerEventTimesToJson(this);
}
