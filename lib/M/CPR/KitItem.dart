import 'package:json_annotation/json_annotation.dart';
import 'package:smartwind/M/CPR/CprItem.dart';

part 'KitItem.g.dart';

@JsonSerializable(explicitToJson: true)
class KitItem extends CprItem {
  KitItem();

  @JsonKey(defaultValue: false, includeIfNull: true)
  bool saved = false;

  static List<KitItem> fromJsonArray(kits) {
    return List<KitItem>.from(kits.map((model) => KitItem.fromJson(model)));
  }

  factory KitItem.fromJson(Map<String, dynamic> json) => _$KitItemFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$KitItemToJson(this);
}
