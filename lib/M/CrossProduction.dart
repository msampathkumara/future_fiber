import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import 'DataObject.dart';
import 'Section.dart';
import 'hive.dart';

part 'CrossProduction.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 25)
class CrossProduction extends DataObject {
  @override
  @HiveField(1, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int id = 0;

  @HiveField(2, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int ticketId = 0;

  @HiveField(3, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int fromFactoryId = 0;

  @HiveField(4, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int toFactoryId = 0;

  Section? get fromSection => HiveBox.sectionsBox.get(fromFactoryId);

  Section? get toSection => HiveBox.sectionsBox.get(toFactoryId);

  CrossProduction();

  factory CrossProduction.fromJson(Map<String, dynamic> json) => _$CrossProductionFromJson(json);

  Map<String, dynamic> toJson() => _$CrossProductionToJson(this);
}
