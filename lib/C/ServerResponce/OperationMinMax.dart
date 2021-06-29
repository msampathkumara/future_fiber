import 'package:json_annotation/json_annotation.dart';

part 'OperationMinMax.g.dart';

@JsonSerializable(explicitToJson: true)
class OperationMinMax {
  int? min;
  int? max;

  OperationMinMax();

  factory OperationMinMax.fromJson(Map<String, dynamic> json) => _$OperationMinMaxFromJson(json);

  Map<String, dynamic> toJson() => _$OperationMinMaxToJson(this);
}
