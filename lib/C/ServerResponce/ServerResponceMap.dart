import 'package:json_annotation/json_annotation.dart';
import 'package:smartwind/M/TicketFlag.dart';

import 'ErrorResponce.dart';
import 'OperationMinMax.dart';
import 'Progress.dart';
import 'TicketHistory.dart';
import 'TicketPrint.dart';
import 'UserRFCredentials.dart';

part 'ServerResponceMap.g.dart';

@JsonSerializable(explicitToJson: true)
class ServerResponceMap {
  UserRFCredentials? userRFCredentials;
  OperationMinMax? operationMinMax;
  ErrorResponce? errorResponce;
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

  ServerResponceMap();

  factory ServerResponceMap.fromJson(Map<String, dynamic> json) => _$ServerResponceMapFromJson(json);

  Map<String, dynamic> toJson() => _$ServerResponceMapToJson(this);
}




