import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'TicketComment.g.dart';

@JsonSerializable(explicitToJson: true)
class TicketComment {
  @JsonKey(defaultValue: null, includeIfNull: true)
  int? id;

  @JsonKey(defaultValue: "", includeIfNull: true)
  String comment = "";
  @JsonKey(defaultValue: "", includeIfNull: true)
  String dnt = "";
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int userId = 0;
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int ticketId = 0;

  TicketComment();

  factory TicketComment.fromJson(Map<String, dynamic> json) => _$TicketCommentFromJson(json);

  Map<String, dynamic> toJson() => _$TicketCommentToJson(this);

  static List<TicketComment> fromJsonArray(_ticketComment) {
    return List<TicketComment>.from(_ticketComment.map((model) => TicketComment.fromJson(model)));
  }

  get dateTime {
    try {
      return DateFormat("yyyy-MM-dd hh:mm").format(DateFormat("yyyy-MM-dd'T'HH:mm").parse(dnt));
    } catch (e) {
      return dnt;
    }
  }
}
