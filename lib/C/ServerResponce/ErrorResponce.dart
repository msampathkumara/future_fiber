import 'package:json_annotation/json_annotation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:json_annotation/json_annotation.dart';


@JsonSerializable(explicitToJson: true)
part 'ErrorResponce.g.dart';
@JsonSerializable(explicitToJson: true)
class ErrorResponce {
  int? min;
  int? max;
  int? doAt;

  ErrorResponce();



factory ErrorResponce.fromJson(Map<String, dynamic> json) => _$ErrorResponceFromJson(json);

Map<String, dynamic> toJson() => _$ErrorResponceToJson(this);
}
