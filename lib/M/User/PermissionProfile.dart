import 'package:json_annotation/json_annotation.dart';

part 'PermissionProfile.g.dart';

@JsonSerializable(explicitToJson: true)
class PermissionProfile {
  PermissionProfile();

  @JsonKey(defaultValue: 0, includeIfNull: true)
  int id = 0;

  @JsonKey(defaultValue: "", includeIfNull: true)
  String name = '';

  @JsonKey(defaultValue: [], includeIfNull: true)
  List<int> permissions = [];

  static List<PermissionProfile> fromJsonArray(_permissionProfile) {
    return List<PermissionProfile>.from(_permissionProfile.map((model) => PermissionProfile.fromJson(model)));
  }

  factory PermissionProfile.fromJson(Map<String, dynamic> json) => _$PermissionProfileFromJson(json);

  Map<String, dynamic> toJson(instance) => _$PermissionProfileToJson(this);
}
