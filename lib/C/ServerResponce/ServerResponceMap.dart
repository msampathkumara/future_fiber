import 'package:json_annotation/json_annotation.dart';

import 'ErrorResponce.dart';
import 'OperationMinMax.dart';
import 'Progress.dart';
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

  ServerResponceMap();

  factory ServerResponceMap.fromJson(Map<String, dynamic> json) => _$ServerResponceMapFromJson(json);

  Map<String, dynamic> toJson() => _$ServerResponceMapToJson(this);
}
