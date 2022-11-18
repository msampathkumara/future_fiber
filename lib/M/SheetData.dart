import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 16)
part 'SheetData.g.dart';

@JsonSerializable(explicitToJson: true)
class SheetData {
  @HiveField(1, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? mo;

  @HiveField(2, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? oe;

  @HiveField(3, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  int? operationNo;

  @HiveField(4, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  int next = 0;

  @HiveField(5, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? operation;

  @HiveField(6, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? pool;

  @HiveField(7, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? deliveryDate;

  @HiveField(8, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int? done = 0;

  @HiveField(9, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  int? user;

  @HiveField(10, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? uptime;

  @HiveField(11, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int ticketId = 0;

  @HiveField(12, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? shipDate;

  SheetData();

  static List<SheetData> fromJsonArray(sheetDataList) {
    return List<SheetData>.from(sheetDataList.map((model) => SheetData.fromJson(model)));
  }

  factory SheetData.fromJson(Map<String, dynamic> json) => _$SheetDataFromJson(json);

  Map<String, dynamic> toJson() => _$SheetDataToJson(this);
}
