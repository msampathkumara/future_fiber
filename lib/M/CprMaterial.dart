import 'package:json_annotation/json_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'CprMaterial.g.dart';
@JsonSerializable(explicitToJson: true)
class CprMaterial {
  String name = "";
  int qty = 0;

  CprMaterial();



factory CprMaterial.fromJson(Map<String, dynamic> json) => _$CprMaterialFromJson(json);

Map<String, dynamic> toJson() => _$CprMaterialToJson(this);

}
