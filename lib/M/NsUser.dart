import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:smartwind/C/DB/DB.dart';
import 'package:smartwind/C/Server.dart';
import 'package:smartwind/V/Widgets/UserImage.dart';

import 'AppUser.dart';
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

  @JsonKey(defaultValue: 0, includeIfNull: true)
  int? hasNfc;

  NsUser() {
    DB.getDB().then((value) => value!.rawQuery(" select * from userSections us left join factorySections fs on fs.id=us.sectionId where userid='$id'  ").then((s) {
          sections = List<Section>.from(s.map((model) => Section.fromJson(model)));
        }));
  }

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
    return UserImage(nsUserId: nsUserId);
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
}
