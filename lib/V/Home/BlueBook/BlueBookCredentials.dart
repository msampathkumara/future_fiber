import 'package:json_annotation/json_annotation.dart';

part 'BlueBookCredentials.g.dart';

@JsonSerializable(explicitToJson: true)
class BlueBookCredentials {
  String userName = "jayantha.podimanike";
  String password = "U7pc794t";

  BlueBookCredentials();

  factory BlueBookCredentials.fromJson(Map<String, dynamic> json) => _$BlueBookCredentialsFromJson(json);

  Map<String, dynamic> toJson() => _$BlueBookCredentialsToJson(this);
}
