import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'DefaultShift.g.dart';

@JsonSerializable(explicitToJson: true)
class DefaultShift {
  DefaultShift();

  @JsonKey(defaultValue: 0, includeIfNull: true)
  int id = 0;

  @JsonKey(defaultValue: null, includeIfNull: true)
  String? startAt;

  @JsonKey(defaultValue: null, includeIfNull: true)
  String? endAt;

  @JsonKey(defaultValue: null, includeIfNull: true)
  String? shiftName;

  @JsonKey(defaultValue: 0, includeIfNull: true)
  int deleted = 0;

  @JsonKey(defaultValue: 0, includeIfNull: true)
  double duration = 0;

  factory DefaultShift.fromJson(Map<String, dynamic> json) => _$DefaultShiftFromJson(json);

  TimeOfDay get startAtTime => TimeOfDay(hour: int.tryParse(startAt!.split(":")[0]) ?? 0, minute: int.tryParse(startAt!.split(":")[1]) ?? 0);

  TimeOfDay get endAtTime => TimeOfDay(hour: int.tryParse(endAt!.split(":")[0]) ?? 0, minute: int.tryParse(endAt!.split(":")[1]) ?? 0);

  get isActive => deleted == 0;

  Map<String, dynamic> toJson() => _$DefaultShiftToJson(this);

  static List<DefaultShift> fromJsonArray(_shift) {
    return List<DefaultShift>.from(_shift.map((model) => DefaultShift.fromJson(model)));
  }
}
