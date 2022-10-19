import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'DeviceLog.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 23)
class DeviceLog {
  DeviceLog();

  @HiveField(1, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  int? id;

  @HiveField(2, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int tab = 0;

  @HiveField(3, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int stylus = 0;

  @HiveField(4, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  int? dnt;

  @HiveField(5, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  int? userId;

  @HiveField(6, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  int? tabId;

  factory DeviceLog.fromJson(Map<String, dynamic> json) => _$DeviceLogFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceLogToJson(this);

  static List<DeviceLog> fromJsonArray(tabLogList) {
    return List<DeviceLog>.from(tabLogList.map((model) => DeviceLog.fromJson(model)));
  }

  getDateTime() {
    if (dnt == null) {
      return "";
    }
    var date = DateTime.fromMicrosecondsSinceEpoch((dnt)! * 1000);
    var formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(date);
    return formattedDate;
  }
}
