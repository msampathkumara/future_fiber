import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:smartwind/C/DB/DB.dart';
import 'package:smartwind/C/Server.dart';
import 'package:smartwind/V/Widgets/UserImage.dart';

import 'AppUser.dart';
import 'HiveClass.dart';
import 'Section.dart';

part 'NsUser.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 6)
class NsUser extends HiveClass {
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

  // List<Section> _sections = [];

  @JsonKey(defaultValue: null, includeIfNull: true)
  Section? section;

  @JsonKey(defaultValue: 0, includeIfNull: true)
  int hasNfc = 0;

  @JsonKey(defaultValue: 0, includeIfNull: true)
  int disabled = 0;

  String? password = "";

  var emailVerified;

  var email;

  @JsonKey(defaultValue: [], includeIfNull: true)
  List<String> permissions = [];

  NsUser() {
    loadSections();
  }

  factory NsUser.fromJson(Map<String, dynamic> json) => _$NsUserFromJson(json);

  bool get isDisabled => disabled == 1;

  Map<String, dynamic> toJson() => _$NsUserToJson(this);

  List getPhonesList() {
    if (phone.isEmpty) {
      return [];
    }
    return phone.split(",");
  }

  bool userHasNfc() {
    return hasNfc == 1;
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

  getSections() {
    return sections;
  }

  static getDefaultImage() {
    return AssetImage('assets/images/user.png');
  }

  getUserImage() {
    var img = NetworkImage(Server.getServerApiPath("users/getImage?img=" + this.img + "&size=500"), headers: {"authorization": '${AppUser.getIdToken()}'});

    return (this.img).isEmpty ? getDefaultImage() : img;
  }

  static getUserImageById(int? nsUserId) {
    return UserImage(nsUserId: nsUserId, radius: 16);
  }

  static Future<NsUser?> fromId(int? id) {
    if (id == null) {
      return Future.value(null);
    }

    return DB.getDB().then((value) => value!.rawQuery(" select * from users  where id=$id  ").then((s) {
          if (s.length > 0) {
            return NsUser.fromJson(s[0]);
          } else {
            return null;
          }
        }));
  }

  Future<List> loadSections() async {
    var db = await DB.getDB();
    var s = await db!.rawQuery(" select * from userSections us left join factorySections fs on fs.id=us.sectionId where userid='$id'  ");
    sections = List<Section>.from(s.map((model) => Section.fromJson(model)));
    return sections;
  }

  String getImage({size = 300}) {
    return Server.getServerPath("images2/userImages/$size/$img");
  }

  static List<NsUser> fromJsonArray(nsUsers) {
    return List<NsUser>.from(nsUsers.map((model) => NsUser.fromJson(model)));
  }
}
