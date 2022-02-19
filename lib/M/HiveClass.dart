import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'HiveClass.g.dart';

@JsonSerializable(explicitToJson: true)
class HiveClass extends HiveObject {
  @HiveField(100, defaultValue: -1)
  int id = -1;

  @JsonKey(defaultValue: 0, includeIfNull: true)
  @HiveField(101, defaultValue: 0)
  int upon = 0;
}
