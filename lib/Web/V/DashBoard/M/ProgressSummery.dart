import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ProgressSummery.g.dart';

@JsonSerializable(explicitToJson: true)
class ProgressSummery {
  ProgressSummery();

  @JsonKey(defaultValue: null, includeIfNull: true, fromJson: intFromString)
  num? volume;
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? factory;
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? sectionTitle;

  @JsonKey(defaultValue: null, includeIfNull: true)
  int? sectionId;

  @JsonKey(defaultValue: null, includeIfNull: true)
  num? doAt;
  @JsonKey(defaultValue: null, includeIfNull: true)
  num? status;
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? startAt;
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? endAt;
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? p;
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? shiftName;

  @JsonKey(defaultValue: null, includeIfNull: true, fromJson: intFromString)
  num? defects;

  @JsonKey(defaultValue: null, includeIfNull: true, fromJson: intFromString)
  num? wip;
  @JsonKey(defaultValue: null, includeIfNull: true, fromJson: intFromString)
  num? employeeCount;

  @JsonKey(defaultValue: null, includeIfNull: true, fromJson: numFromString)
  num? capacity;

  @JsonKey(defaultValue: null, includeIfNull: true, fromJson: numFromString)
  num? taktTime;

  @JsonKey(defaultValue: null, includeIfNull: true, fromJson: numFromString)
  num? cycleTime;

  @JsonKey(defaultValue: null, includeIfNull: true, fromJson: numFromString)
  num? efficiency;

  @JsonKey(defaultValue: null, includeIfNull: true, fromJson: numFromString)
  num? defectsRate;

  @JsonKey(defaultValue: null, includeIfNull: true, fromJson: stringToDateTime, toJson: dateTimeToString)
  DateTime? date;

  static stringToDateTime(d) => d == null ? null : DateFormat('yyyy-MM-dd').parse(d);

  static dateTimeToString(d) => d == null ? null : DateFormat("yyyy-MM-dd").format(d);

  static int? intFromString(d) => int.tryParse("$d");

  static num? numFromString(d) => num.tryParse("$d");

  factory ProgressSummery.fromJson(Map<String, dynamic> json) => _$ProgressSummeryFromJson(json);

  Map<String, dynamic> toJson() => _$ProgressSummeryToJson(this);

  static List<ProgressSummery> fromJsonArray(_progressSummery) {
    return List<ProgressSummery>.from(_progressSummery.map((model) => ProgressSummery.fromJson(model)));
  }

  static String durationToString(int minutes) {
    var d = Duration(minutes: minutes);
    List<String> parts = d.toString().split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }
}
