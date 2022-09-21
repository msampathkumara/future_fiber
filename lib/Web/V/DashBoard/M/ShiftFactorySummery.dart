import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ShiftFactorySummery.g.dart';

@JsonSerializable(explicitToJson: true)
class ShiftFactorySummery {
  ShiftFactorySummery();

  @JsonKey(defaultValue: null, includeIfNull: true, fromJson: intFromString)
  num? volume;
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? factory;
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? sectionTitle;
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

  @JsonKey(defaultValue: null, includeIfNull: true, fromJson: numFromString)
  num? backLog;

  @JsonKey(defaultValue: false, includeIfNull: true, fromJson: boolFromInt)
  bool isCurrentShift = false;

  String? _startAtTime;
  String? _endAtTime;

  get startAtTime => _startAtTime ??= DateFormat("HH:mm").format(DateTime.parse(startAt!));

  get endAtTime => _endAtTime ??= DateFormat("HH:mm").format(DateTime.parse(endAt!));

  static bool boolFromInt(int done) => done == 1;

  static int? intFromString(d) => int.tryParse("$d");

  static num? numFromString(d) => num.tryParse("$d");

  factory ShiftFactorySummery.fromJson(Map<String, dynamic> json) => _$ShiftFactorySummeryFromJson(json);

  Map<String, dynamic> toJson() => _$ShiftFactorySummeryToJson(this);

  static List<ShiftFactorySummery> fromJsonArray(_ShiftFactorySummery) {
    return List<ShiftFactorySummery>.from(_ShiftFactorySummery.map((model) => ShiftFactorySummery.fromJson(model)));
  }

  static String durationToString(int minutes) {
    var d = Duration(minutes: minutes);
    List<String> parts = d.toString().split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }
}
