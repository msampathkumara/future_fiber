import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'HiveClass.g.dart';

@HiveType(typeId: 100)
@JsonSerializable(explicitToJson: true)
class HiveClass extends HiveObject {
  @HiveField(100, defaultValue: -1)
  var id = -1;

  @JsonKey(defaultValue: 0, includeIfNull: true)
  @HiveField(101, defaultValue: 0)
  int uptime = 0;
}
