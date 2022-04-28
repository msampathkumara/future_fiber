import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'Device.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 22)
class Device {
  Device();

  @HiveField(1, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  int? id = null;

  @HiveField(2, defaultValue: '')
  @JsonKey(defaultValue: '', includeIfNull: true)
  String name = '';

  @HiveField(3, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? imei;

  @HiveField(4, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? model = null;

  @HiveField(5, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? modelNumber = null;

  @HiveField(6, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? serialNumber = null;

  @HiveField(7, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int? tab;

  @HiveField(8, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int stylus = 0;

  @HiveField(9, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  int? logOn = null;

  @HiveField(10, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  int? outOn = null;

  @HiveField(11, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  int? userId = null;

  @HiveField(12, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  int? longitude = null;

  @HiveField(13, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  int? latitude = null;

  @HiveField(14, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int? upon = 0;

  @HiveField(15, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  int? battery = null;

  @HiveField(16, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? ip = null;

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);

  get logOnDateTime => getDateTime(logOn);

  get outOnDateTime => getDateTime(outOn);

  Map<String, dynamic> toJson() => _$DeviceToJson(this);

  static List<Device> fromJsonArray(tabList) {
    return List<Device>.from(tabList.map((model) => Device.fromJson(model)));
  }

  static getDateTime(int? _dnt) {
    if (_dnt == null) {
      return "";
    }
    var date = DateTime.fromMicrosecondsSinceEpoch((_dnt) * 1000);
    var formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(date);
    return formattedDate;
  }
}
