import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'LocalFileVersion.g.dart';

@JsonSerializable()
@HiveType(typeId: 8)
class LocalFileVersion {
  LocalFileVersion();

  @HiveField(0, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int ticketId = 0;

  @HiveField(1, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int version = 0;

  @HiveField(2, defaultValue: '')
  @JsonKey(defaultValue: '', includeIfNull: true)
  String type = TicketTypes.Ticket.getValue();

  factory LocalFileVersion.fromJson(Map<String, dynamic> json) => _$LocalFileVersionFromJson(json);

  Map<String, dynamic> toJson() => _$LocalFileVersionToJson(this);
}

enum TicketTypes { Standard, Completed, Ticket }

extension TicketTypesExtension on TicketTypes {
  String getValue() {
    return (this).toString().split('.').last;
  }
}
