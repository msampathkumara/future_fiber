import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/M/TicketComment.dart';

class TicketChat {
  late Ticket ticket;

  List<TicketComment>? commentList;
}

enum ChatEntryTypes { comment, date, activity, none }
