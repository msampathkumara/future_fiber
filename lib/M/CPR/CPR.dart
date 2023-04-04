import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:smartwind/C/DB/hive.dart';

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

  @JsonKey(defaultValue: null, includeIfNull: true)
  String? imageUrl;

  @JsonKey(defaultValue: [], includeIfNull: true)
  List<CprItem> items = <CprItem>[];

  @JsonKey(defaultValue: [], includeIfNull: true, fromJson: arrayFromObject)
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
  List<CprActivity> cprActivities = [];

  @JsonKey(defaultValue: '', includeIfNull: true)
  String shipDate = '';

  @JsonKey(defaultValue: '', includeIfNull: true)
  String formType = '';

  @JsonKey(defaultValue: null, includeIfNull: true)
  String? orderType;
  @JsonKey(defaultValue: null, includeIfNull: true)
  int? orderBy;
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? orderOn;

  get isTicketStarted => ticket?.isStarted;

  NsUser? get user {
    return HiveBox.usersBox.get(addedUserId);
  }

  NsUser? get sentUser {
    return HiveBox.usersBox.get(sentUserId);
  }

  NsUser? get receivedUser {
    return HiveBox.usersBox.get(receivedUserId);
  }

  bool get isSent => status.toLowerCase() == 'sent';

  CPR();

  factory CPR.fromJson(Map<String, dynamic> json) => _$CPRFromJson(json);

  get date => addedOn.toString().split(" ")[0];

  get time => addedOn.toString().split(" ")[1];

  String get supplier => suppliers.first;

  get materialDueDate {
    DateTime? x;
    try {
      x = DateTime.parse(shipDate);
    } catch (e) {
      x = null;
    }
    return x != null ? DateFormat("yyyy-MM-dd").format(x.add(const Duration(days: 3))) : '';
  }

  static List<String> arrayFromObject(object) {
    if (object == null) return [];
    List<String> x = (object.runtimeType == String
        ? object.toString().split(',')
        : object.runtimeType == List
            ? (object as List).map((e) => "$e").toList()
            : []);

    return x;
  }

  Map<String, dynamic> toJson() => _$CPRToJson(this);

  static List<CPR> fromJsonArray(cprs) {
    return List<CPR>.from(cprs.map((model) => CPR.fromJson(model)));
  }
}
