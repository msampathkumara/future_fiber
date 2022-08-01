import 'package:json_annotation/json_annotation.dart';
import 'package:smartwind/M/CPR/CPR.dart';
import 'package:smartwind/M/TicketFlag.dart';

import '../../M/TicketComment.dart';
import '../../M/TicketHistory.dart';
import '../../M/TicketPrint.dart';
import '../../M/UserRFCredentials.dart';
import 'OperationMinMax.dart';
import 'Progress.dart';

part 'ServerResponceMap.g.dart';

@JsonSerializable(explicitToJson: true)
class ServerResponseMap {
  UserRFCredentials? userRFCredentials;
  OperationMinMax? operationMinMax;

  // ErrorResponce? errorResponce;

  @JsonKey(defaultValue: null, includeIfNull: true)
  bool? done;
  @JsonKey(defaultValue: [], includeIfNull: true)
  List<Progress> progressList = [];
  @JsonKey(defaultValue: [], includeIfNull: true)
  List<TicketFlag> flags = [];
  @JsonKey(defaultValue: [], includeIfNull: true)
  List<TicketFlag> flagsHistory = [];

  @JsonKey(defaultValue: [], includeIfNull: true)
  List<TicketPrint> printList = [];
  @JsonKey(defaultValue: [], includeIfNull: true)
  List<TicketHistory> ticketHistory = [];

  @JsonKey(defaultValue: [], includeIfNull: true)
  List<TicketComment> ticketComments = [];

  @JsonKey(defaultValue: [], includeIfNull: true)
  List<CPR> cprs = [];

  ServerResponseMap();

  factory ServerResponseMap.fromJson(Map<String, dynamic> json) => _$ServerResponseMapFromJson(json);

  Map<String, dynamic> toJson() => _$ServerResponseMapToJson(this);
}
