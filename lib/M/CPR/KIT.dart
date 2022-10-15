import 'package:json_annotation/json_annotation.dart';

import '../NsUser.dart';
import '../Ticket.dart';
import '../hive.dart';
import 'KitItem.dart';

part 'KIT.g.dart';

@JsonSerializable(explicitToJson: true)
class KIT {
  KIT();

  Ticket? ticket;
  @JsonKey(defaultValue: "", includeIfNull: true)
  String? sailType;
  @JsonKey(defaultValue: "", includeIfNull: true)
  String? shortageType;
  @JsonKey(defaultValue: "", includeIfNull: true)
  String? kitType;
  @JsonKey(defaultValue: "", includeIfNull: true)
  String? client;
  @JsonKey(defaultValue: "", includeIfNull: true)
  String comment = "";
  @JsonKey(defaultValue: "", includeIfNull: true)
  String image = "";
  @JsonKey(defaultValue: [], includeIfNull: true)
  List<KitItem> items = <KitItem>[];
  @JsonKey(defaultValue: [], includeIfNull: true, fromJson: arryFromObject)
  List<String> suppliers = <String>[];

  @JsonKey(defaultValue: "", includeIfNull: true)
  String status = "";
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int id = 0;
  @JsonKey(defaultValue: '', includeIfNull: true)
  String shipDate = '';
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? orderType;

  int? sentUserId;
  int? receivedUserId;

  String? sentOn;

  @JsonKey(defaultValue: 0, includeIfNull: true)
  int? addedUserId;
  @JsonKey(defaultValue: '', includeIfNull: true)
  String addedOn = "";

  @JsonKey(defaultValue: false, includeIfNull: true)
  var isExpanded = false;

  get isTicketStarted => ticket?.isStarted;

  static arryFromObject(object) => (object.runtimeType == String
      ? object.toString().split(',')
      : object.runtimeType == List
          ? object
          : []);

  NsUser? get user {
    return HiveBox.usersBox.get(addedUserId);
  }

  NsUser? get sentUser {
    return HiveBox.usersBox.get(sentUserId);
  }

  NsUser? get receivedUser {
    return HiveBox.usersBox.get(receivedUserId);
  }

  get date => addedOn.toString().split(" ")[0];

  get time => addedOn.toString().split(" ")[1];

  String get supplier => suppliers.first;

  Map<String, dynamic> toJson() => _$KITToJson(this);

  static List<KIT> fromJsonArray(kits) {
    return List<KIT>.from(kits.map((model) => KIT.fromJson(model)));
  }

  factory KIT.fromJson(Map<String, dynamic> json) => _$KITFromJson(json);
}
