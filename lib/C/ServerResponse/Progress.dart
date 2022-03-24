import 'package:json_annotation/json_annotation.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/M/Section.dart';

part 'Progress.g.dart';

@JsonSerializable(explicitToJson: true)
class Progress {
  @JsonKey()
  int? doAt;
  @JsonKey()
  Object? finishedAt;
  @JsonKey()
  int? finishedBy;
  @JsonKey()
  String? finishedOn;
  @JsonKey()
  int? id;
  @JsonKey()
  int? nextOperationNo;
  @JsonKey()
  String? operation;
  @JsonKey()
  int? operationNo;
  @JsonKey()
  int? status;
  @JsonKey()
  int? ticketId;
  @JsonKey()
  String? upon;
  @JsonKey()
  Section? section;

  NsUser? user;
  String? timeToFinish = "";

  Progress();

  factory Progress.fromJson(Map<String, dynamic> json) => _$ProgressFromJson(json);

  Map<String, dynamic> toJson() => _$ProgressToJson(this);
}
