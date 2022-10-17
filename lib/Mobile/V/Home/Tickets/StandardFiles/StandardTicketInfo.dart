import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:smartwind/M/StandardTicket.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/M/TicketHistory.dart';
import 'package:smartwind/Mobile/V/Home/Tickets/TicketInfo/info_History.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../../../../C/Api.dart';
import '../../../../../C/DB/DB.dart';
import '../../../../../M/NsUser.dart';
import '../../../../../M/hive.dart';
import '../../../../../Web/Widgets/DialogView.dart';
import '../../../../../Web/Widgets/IfWeb.dart';
import '../../../Widgets/UserImage.dart';

class StandardTicketInfo extends StatefulWidget {
  StandardTicket standardTicket;

  StandardTicketInfo(this.standardTicket);

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }

  @override
  _StandardTicketInfoState createState() => _StandardTicketInfoState();
}

class _StandardTicketInfoState extends State<StandardTicketInfo> {
  late StandardTicket standardTicket;

  late StandardTicket _ticket;

  double _progress = 10;
  int standardTicketUsageCount = 0;

  List<TicketHistory> historyList = [];

  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  late DbChangeCallBack _dbChangeCallBack;

  @override
  void initState() {
    standardTicket = widget.standardTicket;
    _ticket = standardTicket;
    standardTicketUsageCount = HiveBox.standardTicketsBox.values.fold(0, (previousValue, element) => previousValue + element.usedCount);
    _progress = standardTicketUsageCount == 0 ? 0 : (standardTicket.usedCount / standardTicketUsageCount) * 100;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _refreshIndicatorKey.currentState?.show();
    });
    _dbChangeCallBack = DB.setOnDBChangeListener(() {
      print('on update tickets');
      if (mounted) {
        var standardTicket_ = HiveBox.standardTicketsBox.get(standardTicket.id);
        if (standardTicket_ != null && standardTicket_.uptime != standardTicket.uptime) {
          standardTicket = standardTicket_;
          loadData();
        }
      }
    }, context, collection: DataTables.standardTickets);

    super.initState();
  }

  @override
  void dispose() {
    _dbChangeCallBack.dispose();
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
        child: ListView.builder(
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              TicketHistory ticketHistory = historyList[index];
              NsUser? user = HiveBox.usersBox.get(ticketHistory.doneBy);
              return TimelineTile(
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
                      IndicatorStyle(indicatorXY: 0.1, width: 40, height: 40, drawGap: true, padding: const EdgeInsets.all(8), indicator: UserImage(nsUser: user, radius: 24)));
            }),
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
    double height = MediaQuery.of(context).size.height;
    var ts = const TextStyle(color: Colors.white, fontSize: 24);
    var smallText = const TextStyle(fontSize: 16);

    return AppBar(
      backgroundColor: Colors.orange,
      elevation: 10,
      // toolbarHeight: (bottomNavigationBarSelectedIndex == 0) ? (height - kBottomNavigationBarHeight) : 230,
      toolbarHeight: 230,
      bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: Colors.orange,
            height: 200.0,
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
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CircularPercentIndicator(
                      radius: 50.0,
                      lineWidth: 4.0,
                      percent: (_progress / 100).toDouble(),
                      center: Text("${_progress.toStringAsFixed(2)}%", style: ts),
                      progressColor: Colors.white,
                      animateFromLastPercent: true,
                      animation: true,
                      backgroundColor: Colors.white12,
                      animationDuration: 500),
                )
              ],
            ),
          )),
    );
  }

  Future<Null> loadData() {
    print('xxxxxxxxxxxxxxxxxxxxxxx');
    return Api.get("/tickets/standard/getInfo", {'id': standardTicket.id}).then((data) {
      print(data.data["history"]);

      historyList = TicketHistory.fromJsonArray(data.data["history"]);
      standardTicket = StandardTicket.fromJson(data.data["ticket"]);
      setState(() {});
    });
  }

  getWebUi() {}
}
