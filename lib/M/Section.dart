import 'package:json_annotation/json_annotation.dart';

part 'Section.g.dart';

@JsonSerializable()
class Section {
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int id = 0;

  @JsonKey(defaultValue: "-", includeIfNull: true)
  String  sectionTitle = "";

  @JsonKey(defaultValue: "-", includeIfNull: true)
  String  factory = "";

  @JsonKey(defaultValue: "-", includeIfNull: true)
  String loft = "";

  Section();

  factory Section.fromJson(Map<String, dynamic> json) => _$SectionFromJson(json);

  Map<String, dynamic> toJson() => _$SectionToJson(this);
}
