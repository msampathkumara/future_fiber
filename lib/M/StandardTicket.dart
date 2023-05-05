import 'dart:io';

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smartwind_future_fibers/M/Ticket.dart';

import 'Ticket/CprReport.dart';

part 'StandardTicket.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 9)
class StandardTicket extends Ticket {
  @override
  @HiveField(50, defaultValue: null)
  @JsonKey(defaultValue: null, includeIfNull: true)
  String? production;

  @HiveField(51, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int usedCount = 0;

  @override
  @HiveField(52, defaultValue: 0)
  @JsonKey(defaultValue: 0, includeIfNull: true)
  int uptime = 0;

  StandardTicket();

  @override
  Future<File> getLocalFile() async {
    var ed = await getExternalStorageDirectory();
    var filePath = '${ed!.path}/st$id.pdf';
    File file = File(filePath);
    ticketFile = file;
    return file;
  }

  factory StandardTicket.fromJson(Map<String, dynamic> json) => _$StandardTicketFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$StandardTicketToJson(this);

  static List<StandardTicket> fromJsonArray(standardTickets) {
    return List<StandardTicket>.from(standardTickets.map((model) => StandardTicket.fromJson(model)));
  }
}
