import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'Phones.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 3)
class Phones {
  Phones();

  @HiveField(1, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  int? id = null;

  @HiveField(2, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? number = null;

  @HiveField(3, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  int? userId = null;

  @HiveField(4, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int verified = 0;

  factory Phones.fromJson(Map<String, dynamic> json) => _$PhonesFromJson(json);

  Map<String, dynamic> toJson() => _$PhonesToJson(this);

  static List<Phones> fromJsonArray(_phones) {
    return List<Phones>.from(_phones.map((model) => Phones.fromJson(model)));
  }
}
