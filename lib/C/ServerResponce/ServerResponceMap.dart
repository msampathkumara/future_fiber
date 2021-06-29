import 'package:json_annotation/json_annotation.dart';

import 'OperationMinMax.dart';
import 'UserRFCredentials.dart';

part 'ServerResponceMap.g.dart';

@JsonSerializable(explicitToJson: true)
class ServerResponceMap {
  UserRFCredentials? userRFCredentials;
  OperationMinMax? operationMinMax;
  @JsonKey(defaultValue: null, includeIfNull: true)
  bool? done;

  ServerResponceMap();

  factory ServerResponceMap.fromJson(Map<String, dynamic> json) => _$ServerResponceMapFromJson(json);

  Map<String, dynamic> toJson() => _$ServerResponceMapToJson(this);
}
