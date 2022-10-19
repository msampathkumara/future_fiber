import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'Shift.g.dart';

@JsonSerializable(explicitToJson: true)
class Shift {
  Shift();

  @JsonKey(defaultValue: 0, includeIfNull: true)
  int id = 0;

  @JsonKey(defaultValue: null, includeIfNull: true, fromJson: stringToDateTime, toJson: dateTimeToString)
  DateTime? startAt;

  @JsonKey(defaultValue: null, includeIfNull: true, fromJson: stringToDateTime, toJson: dateTimeToString)
  DateTime? endAt;

  @JsonKey(defaultValue: null, includeIfNull: true)
  String? shiftName;

  @JsonKey(defaultValue: 0, includeIfNull: true)
  int deleted = 0;

  @JsonKey(defaultValue: 0, includeIfNull: true)
  double duration = 0;

  @JsonKey(defaultValue: 0, includeIfNull: true)
  int factoryId = 0;

  @JsonKey(defaultValue: '', includeIfNull: true)
  String? factoryName;

  factory Shift.fromJson(Map<String, dynamic> json) => _$ShiftFromJson(json);

  TimeOfDay get startAtTime => TimeOfDay(hour: startAt?.hour ?? 0, minute: startAt?.minute ?? 0);

  TimeOfDay get endAtTime => TimeOfDay(hour: endAt?.hour ?? 0, minute: endAt?.minute ?? 0);

  get isActive => deleted == 0;

  static stringToDateTime(d) => DateFormat('yyyy-MM-dd HH:mm').parse(d);

  static dateTimeToString(date) => DateFormat("yyyy-MM-dd  HH:mm").format(date);

  Map<String, dynamic> toJson() => _$ShiftToJson(this);

  static List<Shift> fromJsonArray(_shift) {
    return List<Shift>.from(_shift.map((model) => Shift.fromJson(model)));
  }

  setEndTime(TimeOfDay t) {
    endAt = DateFormat('yyyy-MM-dd HH:mm').parse("${DateFormat("yyyy-MM-dd").format(endAt!)} ${t.hour}:${t.minute}");
    print(endAt);
  }

  setStartTime(TimeOfDay t) {
    startAt = DateFormat('yyyy-MM-dd HH:mm').parse("${DateFormat("yyyy-MM-dd").format(startAt!)} ${t.hour}:${t.minute}");
    print(startAt);
  }
}
