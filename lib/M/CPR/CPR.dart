import 'package:json_annotation/json_annotation.dart';
import 'package:smartwind/M/hive.dart';

import '../NsUser.dart';
import '../Ticket.dart';
import 'CprItem.dart';
import 'cprActivity.dart';

part 'CPR.g.dart';

@JsonSerializable(explicitToJson: true)
class CPR {
  Ticket? ticket;
  @JsonKey(defaultValue: "", includeIfNull: true)
  String? sailType;
  @JsonKey(defaultValue: "", includeIfNull: true)
  String? shortageType;
  @JsonKey(defaultValue: "", includeIfNull: true)
  String? cprType;
  @JsonKey(defaultValue: "", includeIfNull: true)
  String? client;
  @JsonKey(defaultValue: "", includeIfNull: true)
  String comment = "";
  @JsonKey(defaultValue: "", includeIfNull: true)
  String image = "";
  @JsonKey(defaultValue: [], includeIfNull: true)
  List<CprItem> items = <CprItem>[];
  @JsonKey(defaultValue: [], includeIfNull: true)
  List<String> suppliers = <String>[];

  @JsonKey(defaultValue: "", includeIfNull: true)
  String status = "";
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int id = 0;

  int? sentUserId;
  int? receivedUserId;

  String? sentOn;

  @JsonKey(defaultValue: 0, includeIfNull: true)
  int? addedUserId;
  @JsonKey(defaultValue: '', includeIfNull: true)
  String addedOn = "";

  @JsonKey(defaultValue: false, includeIfNull: true)
  var isExpanded = false;

  @JsonKey(defaultValue: [], includeIfNull: true)
  List<CprActivity> cprs = [];

  NsUser? get user {
    return HiveBox.usersBox.get(addedUserId);
  }

  NsUser? get sentUser {
    return HiveBox.usersBox.get(sentUserId);
  }

  NsUser? get receivedUser {
    return HiveBox.usersBox.get(receivedUserId);
  }

  CPR();

  factory CPR.fromJson(Map<String, dynamic> json) => _$CPRFromJson(json);

  get date => addedOn.toString().split(" ")[0];

  get time => addedOn.toString().split(" ")[1];

  String get supplier => suppliers.first;

  Map<String, dynamic> toJson() => _$CPRToJson(this);

  static List<CPR> fromJsonArray(cprs) {
    return List<CPR>.from(cprs.map((model) => CPR.fromJson(model)));
  }
}