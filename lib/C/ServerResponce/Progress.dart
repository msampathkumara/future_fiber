import 'package:json_annotation/json_annotation.dart';


part 'Progress.g.dart';
@JsonSerializable()
class Progress {
    int? doAt;
    Object? finishedAt;
    Object? finishedBy;
    String? finishedOn;
    int? id;
    int? nextOperationNo;
    String? operation;
    int? operationNo;
    int? status;
    int? ticketId;
    String? upon;

    Progress();

factory Progress.fromJson(Map<String, dynamic> json) => _$ProgressFromJson(json);

Map<String, dynamic> toJson() => _$ProgressToJson(this);
}