import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:smartwind/C/OnlineDB.dart';
import 'package:smartwind/M/AppUser.dart';
import 'package:smartwind/M/StandardTicket.dart';
import 'package:smartwind/M/TicketHistory.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../../../C/DB/DB.dart';
import '../../../../M/hive.dart';
import '../../../../Web/Widgets/DialogView.dart';
import '../../../../Web/Widgets/IfWeb.dart';
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

  var _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  late DbChangeCallBack _dbChangeCallBack;

  @override
  void initState() {
    standardTicket = widget.standardTicket;
    _ticket = standardTicket;
    standardTicketUsageCount = HiveBox.standardTicketsBox.values.fold(0, (previousValue, element) => previousValue + element.usedCount);
    _progress = standardTicketUsageCount == 0 ? 0 : (standardTicket.usedCount / standardTicketUsageCount) * 100;

    SchedulerBinding.instance!.addPostFrameCallback((_) {
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

  var ts = TextStyle(color: Colors.white, fontSize: 24);

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
      body: Container(
          child: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () {
          return loadData();
        },
        child: ListView.builder(
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              TicketHistory ticketHistory = historyList[index];

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
                        Text("1 MIN AGO", textAlign: TextAlign.start, style: TextStyle(color: Colors.grey)),
                        RichText(
                            text: TextSpan(style: defaultStyle, children: [TextSpan(text: AppUser.getUser()?.name ?? "", style: linkStyle), TextSpan(text: " edited ticket")])),
                        Align(child: Text("2022/02/10 10:00 pm", textAlign: TextAlign.end, style: timeStyle), alignment: Alignment.bottomRight),
                        Divider(
                          thickness: 1.5,
                        )
                      ],
                    ),
                  ),
                  indicatorStyle: IndicatorStyle(
                      indicatorXY: 0.1, width: 40, height: 40, drawGap: true, padding: const EdgeInsets.all(8), indicator: UserImage(nsUser: AppUser.getUser(), radius: 24)));
            }),
      )),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.import_contacts),
        onPressed: () {
          widget.standardTicket.open(context);
        },
      ),
    );
  }

  _appBar() {
    double height = MediaQuery.of(context).size.height;
    var ts = TextStyle(color: Colors.white, fontSize: 24);
    var smallText = TextStyle(fontSize: 16);

    return AppBar(
      backgroundColor: Colors.orange,
      elevation: 10,
      // toolbarHeight: (bottomNavigationBarSelectedIndex == 0) ? (height - kBottomNavigationBarHeight) : 230,
      toolbarHeight: 230,
      bottom: PreferredSize(
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
                      Text("update on : " + (_ticket.getUpdateDateTime()), style: ts.merge(smallText)),
                      Text("usage : ${_ticket.usedCount} ", style: ts.merge(smallText)),
                    ],
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CircularPercentIndicator(
                      radius: 50.0,
                      lineWidth: 4.0,
                      percent: (_progress / 100).toDouble(),
                      center: Text(_progress.toStringAsFixed(2) + "%", style: ts),
                      progressColor: Colors.white,
                      animateFromLastPercent: true,
                      animation: true,
                      backgroundColor: Colors.white12,
                      animationDuration: 500),
                )
              ],
            ),
          ),
          preferredSize: Size.fromHeight(4.0)),
    );
  }

  Future<Null> loadData() {
    print('xxxxxxxxxxxxxxxxxxxxxxx');
    return OnlineDB.apiGet("/tickets/standard/getInfo", {'id': standardTicket.id}).then((data) {
      print(data);

      historyList = TicketHistory.fromJsonArray(data.data["history"]);
      standardTicket = StandardTicket.fromJson(data.data["ticket"]);
      setState(() {});
    });
  }

  getWebUi() {}
}
