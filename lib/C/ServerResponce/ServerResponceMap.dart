import 'package:json_annotation/json_annotation.dart';
import 'UserRFCredentials.dart';



part 'ServerResponceMap.g.dart';
@JsonSerializable(explicitToJson: true)
class ServerResponceMap {
    UserRFCredentials? userRFCredentials;

    ServerResponceMap( );

factory ServerResponceMap.fromJson(Map<String, dynamic> json) => _$ServerResponceMapFromJson(json);

Map<String, dynamic> toJson() => _$ServerResponceMapToJson(this);


}