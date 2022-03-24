import 'dart:io';

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smartwind/M/Ticket.dart';

part 'StandardTicket.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 9)
class StandardTicket extends Ticket {
  @HiveField(50, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? production;

  @HiveField(51, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int usedCount = 0;

  @HiveField(52, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int uptime = 0;

  StandardTicket();

  Future<File> getLocalFile() async {
    var ed = await getExternalStorageDirectory();
    var filePath = ed!.path + '/st$id.pdf';
    File file = new File(filePath);
    ticketFile = file;
    return file;
  }

  factory StandardTicket.fromJson(Map<String, dynamic> json) => _$StandardTicketFromJson(json);

  Map<String, dynamic> toJson() => _$StandardTicketToJson(this);

  static List<StandardTicket> fromJsonArray(StandardTickets) {
    return List<StandardTicket>.from(StandardTickets.map((model) => StandardTicket.fromJson(model)));
  }
}
