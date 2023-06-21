import 'package:json_annotation/json_annotation.dart';

import '../NsUser.dart';
import 'CprItem.dart';

part 'cprActivity.g.dart';

@JsonSerializable(explicitToJson: true)
class CprActivity {
  @JsonKey(defaultValue: "", includeIfNull: true)
  String supplier = "";

  @JsonKey(defaultValue: "", includeIfNull: true)
  String status = "";

  @JsonKey(defaultValue: [], includeIfNull: true)
  List<CprItem> items = [];

  NsUser? addedBy;
  NsUser? sentBy;

  @JsonKey(defaultValue: "", includeIfNull: true)
  String addedOn = "";

  @JsonKey(defaultValue: "", includeIfNull: true)
  String sentOn = "";

  @JsonKey(defaultValue: 0, includeIfNull: true)
  int id = 0;

  CprActivity();

  @JsonKey(defaultValue: false, includeIfNull: true)
  bool isExpanded = false;

  factory CprActivity.fromJson(Map<String, dynamic> json) => _$CprActivityFromJson(json);

  Map<String, dynamic> toJson() => _$CprActivityToJson(this);
}
