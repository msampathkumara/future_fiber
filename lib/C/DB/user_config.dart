import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:smartwind/C/DB/up_on.dart';

import 'TriggerEventTimes.dart';
import 'HiveClass.dart';
import '../../M/NsUser.dart';
import '../../M/Section.dart';

part 'user_config.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 3)
class UserConfig extends HiveClass {
  UserConfig();

  @HiveField(0)
  NsUser? user;

  @HiveField(1, defaultValue: false)
  @JsonKey(defaultValue: false, includeIfNull: true)
  bool welcomeScreenShown = false;

  @HiveField(2, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  Section? selectedSection;

  @HiveField(3, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  Upons upon = Upons();

  @HiveField(4, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  TriggerEventTimes triggerEventTimes = TriggerEventTimes();

  @HiveField(5, defaultValue: false)
  @JsonKey(defaultValue: false, includeIfNull: true)
  bool isTest = false;

  factory UserConfig.fromJson(Map<String, dynamic> json) => _$UserConfigFromJson(json);

  Map<String, dynamic> toJson() => _$UserConfigToJson(this);
}
