import 'package:json_annotation/json_annotation.dart';

import 'NsUser.dart';

part 'CprItem.g.dart';

@JsonSerializable(explicitToJson: true)
class CprItem {
  String item = "";
  String qty = "";
  int checked = 0;
  String dnt = "";
  NsUser? user;

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
