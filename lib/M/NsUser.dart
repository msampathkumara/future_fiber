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
  String utype = "";
  String epf = "";
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int etype = 0;
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int sectionId = 0;
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int loft = 0;
  String contact = "";
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

  List getContactsList() {
    if (contact.isEmpty) {
      return [];
    }
    return contact.split(",");
  }

  List getEmailList() {
    if (emailAddress.isEmpty) {
      return [];
    }
    return emailAddress.split(",");
  }

  void removeContact(String number) {
    var l = getContactsList();
    l.remove(number);
    contact = l.join(',');
  }

  void removeEmail(String number) {
    var l = getEmailList();
    l.remove(number);
    emailAddress = l.join(',');
  }

  void addContact(String number) {
    var l = getContactsList();
    l.add(number);
    l = [
      ...{...l}
    ];
    contact = l.join(',');
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
