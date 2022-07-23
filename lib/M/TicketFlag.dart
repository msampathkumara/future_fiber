import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'TicketFlag.g.dart';

@HiveType(typeId: 2)
@JsonSerializable(explicitToJson: true)
class TicketFlag {
  @JsonKey(ignore: true)
  static String flagTypeRED = "red";
  @JsonKey(ignore: true)
  static String flagTypeRUSH = "rush";
  @JsonKey(ignore: true)
  static String flagTypeSK = "sk";
  @JsonKey(ignore: true)
  static String flagTypeGR = "gr";
  @JsonKey(ignore: true)
  static String flagTypeHOLD = "hold";

  @HiveField(1, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int ticket = 0;

  @HiveField(2, defaultValue: '')
  @JsonKey(defaultValue: "", includeIfNull: true)
  String type = "";

  @HiveField(3, defaultValue: '')
  @JsonKey(defaultValue: "-", includeIfNull: true)
  String comment = "";

  @HiveField(4, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int user = 0;

  @HiveField(5, defaultValue: '')
  @JsonKey(fromJson: _stringFromInt)
  String dnt = "";

  @HiveField(6, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int flaged = 0;

  static String _stringFromInt(number) => (number ?? "").toString();

  TicketFlag();

  get isFlaged => flaged == 1;

  factory TicketFlag.fromJson(Map<String, dynamic> json) => _$TicketFlagFromJson(json);

  Map<String, dynamic> toJson() => _$TicketFlagToJson(this);

  getDateTime() {
    print(toJson());
    if ((dnt).isEmpty) {
      return "";
    }
    var date = DateTime.fromMicrosecondsSinceEpoch(int.parse(dnt) * 1000);
    var formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
    return formattedDate;
  }

  static List<TicketFlag>? fromJsonArray(list) {
    return List<TicketFlag>.from(list.map((model) => TicketFlag.fromJson(model)));
  }
}
