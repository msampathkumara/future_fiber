import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'Email.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 24)
class Email {
  Email();

  @HiveField(1, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  int? id;

  @HiveField(2, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  int? userId;

  @HiveField(3, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? email;

  @HiveField(4, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int verified = 0;

  factory Email.fromJson(Map<String, dynamic> json) => _$EmailFromJson(json);

  get isVerified => verified == 1;

  get isNotVerified => verified == 0;

  Map<String, dynamic> toJson() => _$EmailToJson(this);
}
