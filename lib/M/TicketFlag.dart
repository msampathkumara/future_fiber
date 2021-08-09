import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(explicitToJson: true)
part 'TicketFlag.g.dart';

@JsonSerializable(explicitToJson: true)
class TicketFlag {
  @JsonKey(ignore: true)
  static String FlagType_RED = "red";
  @JsonKey(ignore: true)
  static String FlagType_RUSH = "rush";
  @JsonKey(ignore: true)
  static String FlagType_SK = "sk";
  @JsonKey(ignore: true)
  static String FlagType_GR = "gr";
  @JsonKey(ignore: true)
  static String FlagType_HOLD = "hold";

  @JsonKey(defaultValue: 0, includeIfNull: true)
  int id = 0;
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int ticket = 0;
  @JsonKey(defaultValue: "", includeIfNull: true)
  String type = "";
  @JsonKey(defaultValue: "-", includeIfNull: true)
  String comment = "";
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int user = 0;
  @JsonKey(defaultValue: "", includeIfNull: true)
  String dnt = "";
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int flaged = 0;

  TicketFlag() {}

  get isFlaged => flaged == 1;

  factory TicketFlag.fromJson(Map<String, dynamic> json) => _$TicketFlagFromJson(json);

  Map<String, dynamic> toJson() => _$TicketFlagToJson(this);

  getDateTime() {
    if ((dnt).isEmpty) {
      return "";
    }
    var date = DateTime.fromMicrosecondsSinceEpoch(int.parse(dnt) * 1000);
    var formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
    return formattedDate;
  }
}
