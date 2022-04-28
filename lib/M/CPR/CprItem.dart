import 'package:json_annotation/json_annotation.dart';

import '../NsUser.dart';

part 'CprItem.g.dart';

@JsonSerializable(explicitToJson: true)
class CprItem {
  @JsonKey(defaultValue: "", includeIfNull: true)
  String item = "";
  @JsonKey(defaultValue: "", includeIfNull: true)
  String qty = "";
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int checked = 0;
  @JsonKey(defaultValue: "", includeIfNull: true)
  String dnt = "";
  @JsonKey(defaultValue: -1, includeIfNull: true)
  int userId = -1;
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int id = 0;

  @JsonKey(defaultValue: null, includeIfNull: true)
  String? supplier;

  @JsonKey(defaultValue: false, includeIfNull: true)
  bool selected = false;

  NsUser? get user {
    return NsUser.fromId(userId);
  }

  CprItem();

  bool isChecked() {
    return checked == 1;
  }

  factory CprItem.fromJson(Map<String, dynamic> json) => _$CprItemFromJson(json);

  Map<String, dynamic> toJson() => _$CprItemToJson(this);

  void setChecked(bool checked) {
    this.checked = checked ? 1 : 0;
  }
}
