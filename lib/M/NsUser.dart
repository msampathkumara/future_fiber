import 'package:json_annotation/json_annotation.dart';

part 'NsUser.g.dart';

@JsonSerializable(explicitToJson: true)
class NsUser {
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int id = 0;
  String uname = "";
  @JsonKey(defaultValue: "", includeIfNull: true)
  String pword = "";
  String name = "";
  String utype = "";
  String epf = "";
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int etype = 0;
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int section = 0;
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int loft = 0;
  String contact = "";
  @JsonKey(defaultValue: "0", includeIfNull: true)
  String img = "";
  @JsonKey(defaultValue: "-", includeIfNull: true)
  String sectionName = "";
  @JsonKey(defaultValue: "-", includeIfNull: true)
  String emailAddress = "";

  NsUser();

  factory NsUser.fromJson(Map<String, dynamic> json) => _$NsUserFromJson(json);

  Map<String, dynamic> toJson() => _$NsUserToJson(this);
}
