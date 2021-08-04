import 'package:json_annotation/json_annotation.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/M/Section.dart';

part 'Progress.g.dart';

@JsonSerializable()
class Progress {
  int? doAt;
  Object? finishedAt;
  int? finishedBy;
  String? finishedOn;
  int? id;
  int? nextOperationNo;
  String? operation;
  int? operationNo;
  int? status;
  int? ticketId;
  String? upon;
  Section? section;

  NsUser? user;

  Progress();

  factory Progress.fromJson(Map<String, dynamic> json) => _$ProgressFromJson(json);

  Map<String, dynamic> toJson() => _$ProgressToJson(this);
}
