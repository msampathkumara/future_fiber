import 'package:json_annotation/json_annotation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'CprMaterial.dart';
import 'Ticket.dart';
 
part 'CPR.g.dart';
@JsonSerializable(explicitToJson: true)
class CPR {
  Ticket? ticket;
  String? sailType;
  String? shortageType;
  String? cprType;
  String? client;
  String? supplier1;
  String? supplier2;
  String? supplier3;
  String comment = "";
  String image = "";
  List<CprMaterial> materials =<CprMaterial>[];
  CPR();

 

factory CPR.fromJson(Map<String, dynamic> json) => _$CPRFromJson(json);

Map<String, dynamic> toJson() => _$CPRToJson(this);
}
