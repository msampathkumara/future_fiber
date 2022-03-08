import 'package:json_annotation/json_annotation.dart';

part 'UserRFCredentials.g.dart';

@JsonSerializable(explicitToJson: true)
class UserRFCredentials {
  int? uid;
  String? uname;
  String? pword;

  UserRFCredentials();

  factory UserRFCredentials.fromJson(Map<String, dynamic> json) => _$UserRFCredentialsFromJson(json);

  Map<String, dynamic> toJson() => _$UserRFCredentialsToJson(this);
}
