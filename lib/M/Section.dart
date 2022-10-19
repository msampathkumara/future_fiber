import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import 'HiveClass.dart';

part 'Section.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 7)
class Section extends HiveClass {
  @override
  @HiveField(0, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int id = 0;

  @HiveField(1, defaultValue: '')
  @JsonKey(defaultValue: "-", includeIfNull: true)
  String sectionTitle = "";

  @HiveField(2, defaultValue: '')
  @JsonKey(defaultValue: "-", includeIfNull: true)
  String factory = "";

  @HiveField(3, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int loft = 0;

  Section();

  factory Section.fromJson(Map<String, dynamic> json) => _$SectionFromJson(json);

  Map<String, dynamic> toJson() => _$SectionToJson(this);

  static List<Section> fromJsonArray(sections) {
    return List<Section>.from(sections.map((model) => Section.fromJson(model)));
  }
}
