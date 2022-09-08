import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'CprReport.g.dart';

enum CprReportTypes { kit, cpr }

enum CprReportStatus { pending, sent, ready, reading, no }

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 5)
class CprReport {
  @HiveField(0, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? status;

  @HiveField(1, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? type;

  @HiveField(2, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true, fromJson: intFromString)
  int count = 0;

  CprReport();

  static int intFromString(String c) => int.parse(c);

  static CprReportTypes cprReportTypeFromString(String type) => type == 'kit' ? CprReportTypes.kit : CprReportTypes.cpr;

  static CprReportStatus? cprReportStatusFromString(String status) {
    var x = CprReportStatus.values.firstWhere((e) => e.toString() == 'CprReportStatus.${status.toLowerCase()}', orElse: () => CprReportStatus.no);
    return x == CprReportStatus.no ? null : x;
  }

  factory CprReport.fromJson(Map<String, dynamic> json) => _$CprReportFromJson(json);

  static List<CprReport> fromJsonArray(_cprReport) {
    return List<CprReport>.from(_cprReport.map((model) => CprReport.fromJson(model)));
  }

  Map<String, dynamic> toJson() => _$CprReportToJson(this);
}
