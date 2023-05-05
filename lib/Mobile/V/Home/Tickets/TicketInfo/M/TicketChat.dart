import 'package:smartwind_future_fibers/M/Ticket.dart';
import 'package:smartwind_future_fibers/M/TicketComment.dart';

class TicketChat {
  late Ticket ticket;

  List<TicketComment>? commentList;
}

enum ChatEntryTypes { comment, date, activity, none }
