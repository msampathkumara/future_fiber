import 'package:json_annotation/json_annotation.dart';

import 'CprItem.dart';
import 'NsUser.dart';
import 'Ticket.dart';

part 'CPR.g.dart';

@JsonSerializable(explicitToJson: true)
class CPR {
  Ticket? ticket;
  String? sailType;
  String? shortageType;
  String? cprType;
  String? client;
  @JsonKey(defaultValue: "", includeIfNull: true)
  String comment = "";
  @JsonKey(defaultValue: "", includeIfNull: true)
  String image = "";
  @JsonKey(defaultValue: [], includeIfNull: true)
  List<CprItem> items = <CprItem>[];
  @JsonKey(defaultValue: [], includeIfNull: true)
  List<String> suppliers = <String>[];

  var mo;
  var oe;
  String status = "";
  int id = 0;
  var dnt;
  String supplier = "";
  NsUser? sentBy;
  NsUser? recivedBy;

  String? sentOn;
  String? recivedOn;

  NsUser? user;

  CPR();

  factory CPR.fromJson(Map<String, dynamic> json) => _$CPRFromJson(json);

  Map<String, dynamic> toJson() => _$CPRToJson(this);
}
