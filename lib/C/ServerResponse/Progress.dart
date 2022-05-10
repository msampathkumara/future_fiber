import 'package:json_annotation/json_annotation.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/M/Section.dart';

part 'Progress.g.dart';

@JsonSerializable(explicitToJson: true)
class Progress {
  @JsonKey(defaultValue: null, includeIfNull: true)
  int? doAt;
  @JsonKey(defaultValue: null, includeIfNull: true)
  Object? finishedAt;
  @JsonKey(defaultValue: null, includeIfNull: true)
  int? finishedBy;
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? finishedOn;
  @JsonKey(defaultValue: null, includeIfNull: true)
  int? id;
  @JsonKey(defaultValue: null, includeIfNull: true)
  int? nextOperationNo;
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? operation;
  @JsonKey(defaultValue: null, includeIfNull: true)
  int? operationNo;
  @JsonKey(defaultValue: null, includeIfNull: true)
  int? status;
  @JsonKey(defaultValue: null, includeIfNull: true)
  int? ticketId;
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? upon;
  @JsonKey(defaultValue: null, includeIfNull: true)
  Section? section;

  @JsonKey(defaultValue: null, includeIfNull: true)
  NsUser? user;
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? timeToFinish = "";

  Progress();

  factory Progress.fromJson(Map<String, dynamic> json) => _$ProgressFromJson(json);

  Map<String, dynamic> toJson() => _$ProgressToJson(this);
}
