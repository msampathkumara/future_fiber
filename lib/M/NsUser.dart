import 'package:json_annotation/json_annotation.dart';

import 'Section.dart';

part 'NsUser.g.dart';

@JsonSerializable(explicitToJson: true)
class NsUser {
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int id = 0;
  String uname = "";
  @JsonKey(defaultValue: "", includeIfNull: true)
  String pword = "";
  String name = "";
  @JsonKey(defaultValue: "", includeIfNull: true)
  String utype = "";
  @JsonKey(defaultValue: "", includeIfNull: true)
  String epf = "";
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int etype = 0;
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int sectionId = 0;
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int loft = 0;
  @JsonKey(defaultValue: "", includeIfNull: true)
  String phone = "";
  @JsonKey(defaultValue: "0", includeIfNull: true)
  String img = "";
  @JsonKey(defaultValue: "-", includeIfNull: true)
  String sectionName = "";
  @JsonKey(defaultValue: "-", includeIfNull: true)
  String emailAddress = "";
  @JsonKey(defaultValue: [], includeIfNull: true)
  List<Section> sections = [];

  @JsonKey(defaultValue: null, includeIfNull: true)
  Section? section;

  NsUser();

  factory NsUser.fromJson(Map<String, dynamic> json) => _$NsUserFromJson(json);

  Map<String, dynamic> toJson() => _$NsUserToJson(this);

  List getPhonesList() {
    if (phone.isEmpty) {
      return [];
    }
    return phone.split(",");
  }

  List getEmailList() {
    if (emailAddress.isEmpty) {
      return [];
    }
    return emailAddress.split(",");
  }

  void removePhone(String number) {
    var l = getPhonesList();
    l.remove(number);
    phone = l.join(',');
  }

  void removeEmail(String number) {
    var l = getEmailList();
    l.remove(number);
    emailAddress = l.join(',');
  }

  void addPhone(String number) {
    var l = getPhonesList();
    l.add(number);
    l = [
      ...{...l}
    ];
    phone = l.join(',');
  }

  void addEmailAddress(String email) {
    var l = getEmailList();
    l.add(email);
    l = [
      ...{...l}
    ];
    emailAddress = l.join(',');
  }

  void addSection(Section selectedSection) {
    bool have = false;
    sections.forEach((element) {
      if (selectedSection.sectionTitle == element.sectionTitle && selectedSection.factory == element.factory) {
        have = true;
      }
    });
    if (!have) {
      sections.add(selectedSection);
    }
  }
}
