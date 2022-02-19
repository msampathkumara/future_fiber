import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import 'HiveClass.dart';
import 'NsUser.dart';

part 'user_config.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 10)
class UserConfig extends HiveClass {
  UserConfig();

  @HiveField(0)
  NsUser? user;

  @HiveField(1, defaultValue: false)
  @JsonKey(defaultValue: false, includeIfNull: true)
  bool welcomeScreenShown = false;

  factory UserConfig.fromJson(Map<String, dynamic> json) => _$UserConfigFromJson(json);

  Map<String, dynamic> toJson() => _$UserConfigToJson(this);
}
