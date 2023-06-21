import 'package:deebugee_plugin/IfWeb.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smartwind_future_fibers/M/EndPoints.dart';
import 'package:smartwind_future_fibers/M/StandardTicket.dart';
import 'package:smartwind_future_fibers/M/Ticket.dart';
import 'package:smartwind_future_fibers/M/TicketHistory.dart';
import 'package:smartwind_future_fibers/Mobile/V/Home/Tickets/TicketInfo/info_History.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../../../../C/Api.dart';
import '../../../../../C/DB/hive.dart';
import 'package:deebugee_plugin/DialogView.dart';
import '../../../../../M/NsUser.dart';
import '../../../../../Web/Widgets/DialogView.dart';
import '../../../Widgets/UserImage.dart';

class StandardTicketInfo extends StatefulWidget {
  final StandardTicket standardTicket;

  const StandardTicketInfo(this.standardTicket, {super.key});

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }

  @override
  _StandardTicketInfoState createState() => _StandardTicketInfoState();
}

class _StandardTicketInfoState extends State<StandardTicketInfo> {
  late StandardTicket standardTicket;

  late StandardTicket _ticket;

  int standardTicketUsageCount = 0;

  List<TicketHistory> historyList = [];

  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    standardTicket = widget.standardTicket;
    _ticket = standardTicket;
    // standardTicketUsageCount = HiveBox.standardTicketsBox.values.fold(0, (previousValue, element) => previousValue + element.usedCount);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _refreshIndicatorKey.currentState?.show();
    });
    // _dbChangeCallBack = DB.setOnDBChangeListener(() {
    //   print('on update tickets');
    //   if (mounted) {
    //     var standardTicket_ = HiveBox.standardTicketsBox.get(standardTicket.id);
    //     if (standardTicket_ != null && standardTicket_.uptime != standardTicket.uptime) {
    //       standardTicket = standardTicket_;
    //       loadData();
    //     }
    //   }
    // }, context, collection: DataTables.standardTickets);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  var ts = const TextStyle(color: Colors.white, fontSize: 24);

  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getUi(), child: DialogView(child: getUi()));
  }

  getUi() {
    TextStyle defaultStyle = const TextStyle(color: Colors.black);
    TextStyle linkStyle = const TextStyle(color: Colors.blue);
    TextStyle timeStyle = const TextStyle(color: Colors.grey);

    return Scaffold(
      appBar: _appBar(),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () {
          return loadData();
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: ListView.builder(
              itemCount: historyList.length,
              itemBuilder: (context, index) {
                TicketHistory ticketHistory = historyList[index];
                NsUser? user = HiveBox.usersBox.get(ticketHistory.doneBy);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TimelineTile(
                      beforeLineStyle: LineStyle(color: Colors.lightBlue.shade100),
                      lineXY: 0.2,
                      isLast: historyList.length == index + 1,
                      alignment: TimelineAlign.start,
                      endChild: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // const Text("1 MIN AGO", textAlign: TextAlign.start, style: TextStyle(color: Colors.grey)),
                            RichText(
                                text: TextSpan(style: defaultStyle, children: [
                                  TextSpan(text: user?.name ?? "", style: linkStyle),
                                  TextSpan(text: " ${(ticketHistory.action ?? "").toLowerCase().replaceUnderscore.capitalizeFirstofEach}")
                                ])),
                            Align(alignment: Alignment.bottomRight, child: Text("${ticketHistory.uptime}", textAlign: TextAlign.end, style: timeStyle)),
                            const Divider(thickness: 1.5)
                          ],
                        ),
                      ),
                      indicatorStyle:
                      IndicatorStyle(indicatorXY: 0.1, width: 40, height: 40, drawGap: true, padding: const EdgeInsets.all(8), indicator: UserImage(nsUser: user, radius: 24))),
                );
              }),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.import_contacts),
        onPressed: () {
          Ticket.open(context, widget.standardTicket);
        },
      ),
    );
  }

  _appBar() {
    var ts = const TextStyle(color: Colors.white, fontSize: 24);
    var smallText = const TextStyle(fontSize: 16);

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.orange,
      elevation: 10,
      title: Row(children: [
        const Spacer(),
        IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close, color: Colors.black))
      ]),
      // toolbarHeight: (bottomNavigationBarSelectedIndex == 0) ? (height - kBottomNavigationBarHeight) : 230,
      toolbarHeight: 200,
      bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: Colors.orange,
            height: 150.0,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(_ticket.oe ?? "_", style: ts),
                      Text(_ticket.production ?? "_", style: ts.merge(smallText)),
                      Text("update on : ${_ticket.getUpdateDateTime()}", style: ts.merge(smallText)),
                      Text("usage : ${_ticket.usedCount} ", style: ts.merge(smallText)),
                    ],
                  ),
                ),
                const Spacer(),
                // Padding(
                //   padding: const EdgeInsets.all(16.0),
                //   child: CircularPercentIndicator(
                //       radius: 50.0,
                //       lineWidth: 4.0,
                //       percent: (_progress / 100).toDouble(),
                //       center: Text("${_progress.toStringAsFixed(2)}%", style: ts),
                //       progressColor: Colors.white,
                //       animateFromLastPercent: true,
                //       animation: true,
                //       backgroundColor: Colors.white12,
                //       animationDuration: 500),
                // )
              ],
            ),
          )),
    );
  }

  Future<void> loadData() {
    print('xxxxxxxxxxxxxxxxxxxxxxx');
    return Api.get(EndPoints.tickets_standard_getInfo, {'id': standardTicket.id}).then((data) {
      print(data.data["history"]);

      historyList = TicketHistory.fromJsonArray(data.data["history"]);
      standardTicket = StandardTicket.fromJson(data.data["ticket"]);
      setState(() {});
    });
  }

  getWebUi() {}
}
