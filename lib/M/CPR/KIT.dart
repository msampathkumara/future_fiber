import 'package:json_annotation/json_annotation.dart';
import 'package:smartwind/M/CPR/cprActivity.dart';

import '../Ticket.dart';
import 'CPR.dart';
import 'CprItem.dart';

part 'KIT.g.dart';

@JsonSerializable(explicitToJson: true)
class KIT extends CPR {
  KIT();

  static List<KIT> fromJsonArray(kits) {
    return List<KIT>.from(kits.map((model) => KIT.fromJson(model)));
  }

  factory KIT.fromJson(Map<String, dynamic> json) => _$KITFromJson(json);

  Map<String, dynamic> toJson() => _$KITToJson(this);
}
