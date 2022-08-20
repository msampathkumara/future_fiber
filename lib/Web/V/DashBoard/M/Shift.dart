import 'package:json_annotation/json_annotation.dart';

part 'Shift.g.dart';

@JsonSerializable(explicitToJson: true)
class Shift {
  Shift();

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

  factory Shift.fromJson(Map<String, dynamic> json) => _$ShiftFromJson(json);

  Map<String, dynamic> toJson() => _$ShiftToJson(this);

  static List<Shift> fromJsonArray(_shift) {
    return List<Shift>.from(_shift.map((model) => Shift.fromJson(model)));
  }
}
