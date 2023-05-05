import 'package:json_annotation/json_annotation.dart';
import 'package:smartwind_future_fibers/M/NsUser.dart';

part 'message.g.dart';

@JsonSerializable(explicitToJson: true)
class Message {
  int self = 0;
  int userId = 0;

  bool get isSelf {
    return self == 1;
  }

  Message();

  String text =
      'You have probably done the same mistake as i did and did not study all properties of ListTile. ListTile has several useful properties like shape or selectedTileColor that can solve your problems.';
  String dnt = 'Nov 7, 2020 at 14:13';
  NsUser? user;

  static List<Message> fromJsonArray(messages) {
    return List<Message>.from(messages.map((model) => Message.fromJson(model)));
  }

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
