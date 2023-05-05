import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:smartwind_future_fibers/C/Server.dart';
import 'package:smartwind_future_fibers/C/DB/hive.dart';
import 'package:smartwind_future_fibers/res.dart';

import '../C/Api.dart';
import '../Mobile/V/Widgets/UserImage.dart';
import 'AppUser.dart';
import 'EndPoints.dart';
import '../C/DB/HiveClass.dart';
import 'Section.dart';
import 'User/Email.dart';

part 'NsUser.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 6)
class NsUser extends HiveClass {
  @override
  @HiveField(0, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int id = 0;

  @HiveField(1, defaultValue: "")
  @JsonKey(defaultValue: "", includeIfNull: true)
  String uname = "";

  @HiveField(2, defaultValue: "")
  @JsonKey(defaultValue: "", includeIfNull: true)
  String pword = "";

  @HiveField(3, defaultValue: "")
  String name = "";

  @HiveField(4, defaultValue: "")
  @JsonKey(defaultValue: "", includeIfNull: true)
  String utype = "";

  @HiveField(5, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true, fromJson: intFromString)
  int? epf;

  @HiveField(6, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int etype = 0;

  @HiveField(7, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int sectionId = 0;

  @HiveField(8, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int loft = 0;

  @HiveField(9, defaultValue: "")
  @JsonKey(defaultValue: "", includeIfNull: true)
  String phone = "";

  @HiveField(10, defaultValue: "")
  @JsonKey(defaultValue: "", includeIfNull: true)
  String img = "";

  @HiveField(11, defaultValue: "")
  @JsonKey(defaultValue: "-", includeIfNull: true)
  String sectionName = "";

  @HiveField(12, defaultValue: "")
  @JsonKey(defaultValue: "-", includeIfNull: true)
  String emailAddress = "";

  @HiveField(13, defaultValue: [])
  @JsonKey(defaultValue: [], includeIfNull: true)
  List<Section> sections = [];

  @HiveField(14, defaultValue: "")
  @JsonKey(defaultValue: "", includeIfNull: true)
  String address = '';

  Section? get section {
    return AppUser.getSelectedSection();
  }

  @HiveField(15, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int hasNfc = 0;

  @HiveField(16, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int deactivate = 0;

  @HiveField(17, defaultValue: [])
  @JsonKey(defaultValue: [], includeIfNull: true)
  List<String> permissions = [];

  @HiveField(18, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int upon = 0;

  @HiveField(19, defaultValue: [])
  @JsonKey(defaultValue: [], includeIfNull: true)
  List<Email> emails = [];

  @HiveField(20, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? nic;

  @HiveField(21, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int locked = 0;

  String? password = "";

  NsUser() {
    loadSections();
  }

  get isLocked => locked == 1;

  get isNotLocked => locked == 0;

  static int? intFromString(d) => int.tryParse("$d");

  getEpf({defaultValue = ''}) {
    return epf ?? defaultValue;
  }

  factory NsUser.fromJson(Map<String, dynamic> json) => _$NsUserFromJson(json);

  bool get isDeactivated => deactivate == 1;

  bool get isNotDeactivated => deactivate == 0;

  get haveImage => img.trim().isNotEmpty;

  List<String> get emailAddressList => emailAddress.split(',');

  List<String> get phoneList => phone.split(',');

  Map<String, dynamic> toJson() => _$NsUserToJson(this);

  List getPhonesList() {
    print('ssssssssssssssss');
    if (phone.trim().isEmpty) {
      print('ssssssssssssssss11');
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
    for (var element in sections) {
      if (selectedSection.sectionTitle == element.sectionTitle && selectedSection.factory == element.factory) {
        have = true;
      }
    }
    if (!have) {
      sections.add(selectedSection);
      print('addddd');
    }
  }

  getSections() {
    return sections;
  }

  static getDefaultImage() {
    return const AssetImage(Res.user64);
  }

  getUserImage() async {
    var token = await AppUser.getIdToken();
    var img = NetworkImage(await Server.getServerApiPath("users/getImage?img=${this.img}&size=500"), headers: {"authorization": '$token'});

    return (this.img).isEmpty ? getDefaultImage() : img;
  }

  static getUserImageById(int? nsUserId) {
    return UserImage(nsUser: fromId(nsUserId), radius: 16);
  }

  static NsUser? fromId(int? id) {
    if (id == null) {
      return null;
    }

    return HiveBox.usersBox.get(id, defaultValue: null);
  }

  Future<List> loadSections() async {
    return sections;
  }

  Future<String> getImage({double size = 300}) {
    return Server.getServerPath("images/profilePictures/${size.toInt()}/$img");
  }

  static List<NsUser> fromJsonArray(nsUsers) {
    return List<NsUser>.from(nsUsers.map((model) => NsUser.fromJson(model)));
  }

  Future removeNfcCard(context, {required onDone}) async {
    return await Api.post(EndPoints.users_removeNfcCard, {'userId': id})
        .then((res) {
          hasNfc = 0;
          save();
          onDone();
        })
        .whenComplete(() {})
        .catchError((err) async {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(err.toString()),
              action: SnackBarAction(
                  label: 'Retry',
                  onPressed: () async {
                    return await removeNfcCard(context, onDone: onDone);
                  })));
        });
  }
}
