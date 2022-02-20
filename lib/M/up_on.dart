
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:smartwind/M/HiveClass.dart';

part 'up_on.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 8)
class Upons extends HiveClass {
  @HiveField(0, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int tickets = 0;

  @HiveField(1, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int deletedTicketsIds = 0;

  @HiveField(2, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int completedTicketsIds = 0;

  @HiveField(3, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int users = 0;

  @HiveField(4, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int factorySections = 0;

  @HiveField(5, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int standardTickets = 0;

  Upons();

  factory Upons.fromJson(Map<String, dynamic> json) => _$UponsFromJson(json);

  Map<String, dynamic> toJson() => _$UponsToJson(this);
}
