import 'package:json_annotation/json_annotation.dart';

part 'Settings.g.dart';

@JsonSerializable(explicitToJson: true)
class Settings {
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int erpNotWorking = 1;

  @JsonKey(defaultValue: [], includeIfNull: true)
  List<String> otpAdminEmails = [];

  factory Settings.fromJson(Map<String, dynamic> json) => _$SettingsFromJson(json);

  get isErpNotWorking => erpNotWorking == 1;

  Map<String, dynamic> toJson() => _$SettingsToJson(this);

  Settings();
}
