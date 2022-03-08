import 'package:json_annotation/json_annotation.dart';

part 'user_permission.g.dart';

@JsonSerializable(explicitToJson: true)
class UserPermission {
  UserPermission();

  @JsonKey(defaultValue: "", includeIfNull: true)
  String description = "";

  @JsonKey(defaultValue: 0, includeIfNull: true)
  int uptime = 0;

  @JsonKey(defaultValue: 0, includeIfNull: true)
  int id = 0;

  @JsonKey(defaultValue: "", includeIfNull: true)
  String name = "";

  @JsonKey(defaultValue: "", includeIfNull: true)
  String category = "";

  @JsonKey(defaultValue: 0, includeIfNull: true)
  int permit = 0;

  get hasPermit => permit == 1;

  factory UserPermission.fromJson(Map<String, dynamic> json) => _$UserPermissionFromJson(json);

  Map<String, dynamic> toJson() => _$UserPermissionToJson(this);

  static List<UserPermission> fromJsonArray(books) {
    return List<UserPermission>.from(books.map((model) => UserPermission.fromJson(model)));
  }
}
