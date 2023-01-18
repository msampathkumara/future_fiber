import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:smartwind/M/AppUser.dart';
import 'package:smartwind/M/EndPoints.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/M/TicketComment.dart';
import 'package:smartwind/M/TicketFlag.dart';
import 'package:smartwind/M/TicketHistory.dart';
import 'package:smartwind/Mobile/V/Home/Tickets/TicketInfo/info_short_items.dart';
import 'package:smartwind/Mobile/V/Widgets/ErrorMessageView.dart';
import 'package:smartwind/Web/Widgets/DialogView.dart';
import 'package:smartwind/ns_icons_icons.dart';

import '../../../../../C/Api.dart';
import '../../../../../C/DB/DB.dart';
import '../../../../../C/ServerResponse/Progress.dart';
import '../../../../../C/ServerResponse/ServerResponceMap.dart';
import '../../../../../M/CPR/CPR.dart';
import '../../../../../M/PermissionsEnum.dart';
import '../../../../../M/hive.dart';
import '../../../../../Web/V/ProductionPool/copy.dart';
import '../ProductionPool/TicketListOptions.dart';
import 'info_Flags.dart';
import 'info_History.dart';
import 'info_Progress.dart';

class TicketInfo extends StatefulWidget {
  final Ticket ticket;

  final bool fromBarcode;

  const TicketInfo(this.ticket, {Key? key, this.fromBarcode = false}) : super(key: key);

  @override
  _TicketInfoState createState() {
    return _TicketInfoState();
  }

  Future? show(context) async {
    return kIsWeb ? await showDialog(context: context, builder: (_) => this) : await Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _TicketInfoState extends State<TicketInfo> {
  late Ticket _ticket;
  late int _progress = 0;

  bool _loading = true;
  late DbChangeCallBack _dbChangeCallBack;

  @override
  void initState() {
    super.initState();
    _ticket = widget.ticket;
    Timer(const Duration(milliseconds: 1000), () {
      setState(() {
        _progress = _ticket.progress;
      });
    });

    getData(_ticket);
    _dbChangeCallBack = DB.setOnDBChangeListener(() {
      if (mounted) {
        var ticket_ = HiveBox.ticketBox.get(_ticket.id);
        if (ticket_ != null && ticket_.uptime != _ticket.uptime) {
          _ticket = ticket_;
          getData(_ticket);
        }
      }
    }, context, collection: DataTables.standardTickets);
  }

  @override
  void dispose() {
    _dbChangeCallBack.dispose();
    super.dispose();
  }

  var bottomNavigationBarItems = <BottomNavigationBarItem>[
    const BottomNavigationBarItem(
      icon: Icon(Icons.data_usage),
      label: "Progress",
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.flag),
      label: "Flags",
    ),
    // const BottomNavigationBarItem(
    //   icon: Icon(Icons.print),
    //   label: "Printing",
    // ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.history),
      label: "History",
    ),
  ];
  int bottomNavigationBarSelectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return kIsWeb
        ? DialogView(child: getWebUi(), width: 1000)
        : Scaffold(
            body: _loading ? const Center(child: CircularProgressIndicator()) : _body(bottomNavigationBarSelectedIndex),
            appBar: _appBar(),
            // backgroundColor: Colors.white,
            bottomNavigationBar: BottomAppBar(
                color: Theme.of(context).primaryColor,
                shape: const CircularNotchedRectangle(),
                notchMargin: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _getBottomNavigationBarItem(Icons.tour_rounded, ("Flags"), 0),
                      _getBottomNavigationBarItem(Icons.data_usage_rounded, ("Progress"), 1),
                      _getBottomNavigationBarItem(Icons.category_outlined, ("Short Items"), 2),
                      _getBottomNavigationBarItem(Icons.history_rounded, ("History"), 3)
                    ],
                  ),
                )),
            floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
            floatingActionButton: getViewFileButton());
  }

  var ts = const TextStyle(color: Colors.white, fontSize: 24);
  var smallText = const TextStyle(fontSize: 16);
  var xSmallText = const TextStyle(fontSize: 12);

  _appBar() {
    return AppBar(
      // backgroundColor: Theme.of(context).primaryColor,

      elevation: 10,
      // toolbarHeight: (bottomNavigationBarSelectedIndex == 0) ? (height - kBottomNavigationBarHeight) : 230,
      toolbarHeight: 250,
      bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            // color: Colors.orange,
            color: Theme.of(context).primaryColor,
            height: (kDebugMode) ? 250.0 : 230,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextMenu(child: Text(_ticket.mo ?? "_", style: ts)),
                      TextMenu(child: Text(_ticket.oe ?? "_", style: ts)),
                      Text(_ticket.production ?? "_", style: ts.merge(smallText)),
                      Text(_ticket.pool ?? "_", style: ts.merge(smallText)),
                      Text("update on : ${_ticket.getUpdateDateTime()}", style: ts.merge(smallText)),
                      Text("Ship Date : ${_ticket.shipDate}", style: ts.merge(smallText)),
                      Text("Delivery Date : ${_ticket.deliveryDate}", style: ts.merge(smallText)),
                      if (kDebugMode) Text("id : ${_ticket.id}", style: ts.merge(smallText)),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Wrap(
                          children: [
                            // if (_ticket.inPrint == 1)
                            //   IconButton(
                            //       icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.print_rounded, color: Colors.deepOrangeAccent)), onPressed: () {}),
                            if (_ticket.isHold == 1)
                              IconButton(icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.pan_tool_rounded, color: Colors.black)), onPressed: () {}),
                            if (_ticket.isGr == 1)
                              IconButton(icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(NsIcons.gr, color: Colors.blue)), onPressed: () {}),
                            if (_ticket.isSk == 1)
                              IconButton(icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(NsIcons.sk, color: Colors.pink)), onPressed: () {}),
                            if (_ticket.isError == 1)
                              IconButton(icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.report_problem_rounded, color: Colors.red)), onPressed: () {}),
                            if (_ticket.isSort == 1)
                              IconButton(icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.local_mall_rounded, color: Colors.green)), onPressed: () {}),
                            if (_ticket.isRush == 1)
                              IconButton(
                                  icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.flash_on_rounded, color: Colors.orangeAccent)), onPressed: () {}),
                            if (_ticket.isRed == 1)
                              IconButton(icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.tour_rounded, color: Colors.red)), onPressed: () {}),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    direction: Axis.vertical,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(_ticket.production ?? '', textScaleFactor: 1, style: const TextStyle(color: Colors.white)),
                      Text(_ticket.atSection ?? '', textScaleFactor: 1, style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 16),
                      if (_ticket.isStarted)
                        CircularPercentIndicator(
                            radius: 50.0,
                            lineWidth: 4.0,
                            percent: (_progress / 100).toDouble(),
                            center: Text("${_ticket.progress}%", style: ts),
                            progressColor: Colors.blue,
                            animateFromLastPercent: true,
                            animation: true,
                            animationDuration: 500),
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }

  _body(int index) {
    switch (index) {
      case 0:
        return info_Flags(flags, ticketComments);
      case 1:
        return info_Progress(progressList, _ticket);
      case 2:
        return info_short_items(cprs);
      case 3:
        return InfoHistory(ticketHistory);
    }
  }

  List<Progress> progressList = [];
  List<TicketFlag> flags = [];
  List<TicketHistory> ticketHistory = [];
  List<TicketComment> ticketComments = [];
  List<CPR> cprs = [];

  _getBottomNavigationBarItem(IconData icon, String text, int i) {
    return InkResponse(
        splashColor: Colors.white,
        radius: 110,
        child: SizedBox(
          width: 100,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: bottomNavigationBarSelectedIndex == i ? Colors.white : Colors.black),
            Text(text, style: TextStyle(color: bottomNavigationBarSelectedIndex == i ? Colors.white : Colors.black))
          ]),
        ),
        onTap: () {
          setState(() {
            bottomNavigationBarSelectedIndex = i;
          });
        });
  }

  var visualDensity = const VisualDensity(horizontal: 0, vertical: -4);

  getWebUi() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(children: [
        SizedBox(
            width: 300,
            child: Container(
              color: Theme.of(context).primaryColor,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ListTile(
                            visualDensity: visualDensity,
                            title: TextMenu(child: Text(_ticket.mo ?? "_", style: ts)),
                            subtitle: TextMenu(child: Text(_ticket.oe ?? "_", style: ts))),
                        ListTile(
                            visualDensity: visualDensity,
                            title: Text(_ticket.production ?? "_", style: ts.merge(smallText)),
                            subtitle: Text(_ticket.atSection ?? '', style: ts.merge(smallText))),
                        ListTile(visualDensity: visualDensity, title: Text("Pool : ", style: ts.merge(xSmallText)), subtitle: Text(_ticket.pool ?? '', style: ts.merge(smallText))),
                        ListTile(
                            visualDensity: visualDensity,
                            title: Text("Update on : ", style: ts.merge(xSmallText)),
                            subtitle: Text(_ticket.getUpdateDateTime(), style: ts.merge(smallText))),
                        if (_ticket.shipDate.isNotEmpty)
                          ListTile(
                              visualDensity: visualDensity, title: Text("Ship Date : ", style: ts.merge(xSmallText)), subtitle: Text(_ticket.shipDate, style: ts.merge(smallText))),
                        if (_ticket.deliveryDate.isNotEmpty)
                          ListTile(
                              visualDensity: visualDensity,
                              title: Text("Delivery Date : ", style: ts.merge(xSmallText)),
                              subtitle: Text(_ticket.deliveryDate, style: ts.merge(smallText))),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Wrap(children: [
                            // if (_ticket.inPrint == 1)
                            //   IconButton(
                            //       icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.print_rounded, color: Colors.deepOrangeAccent)), onPressed: () {}),
                            if (_ticket.isHold == 1)
                              IconButton(icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.pan_tool_rounded, color: Colors.black)), onPressed: () {}),
                            if (_ticket.isGr == 1)
                              IconButton(icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(NsIcons.gr, color: Colors.blue)), onPressed: () {}),
                            if (_ticket.isSk == 1)
                              IconButton(icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(NsIcons.sk, color: Colors.pink)), onPressed: () {}),
                            if (_ticket.isError == 1)
                              IconButton(icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.report_problem_rounded, color: Colors.red)), onPressed: () {}),
                            if (_ticket.isSort == 1)
                              IconButton(icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.local_mall_rounded, color: Colors.green)), onPressed: () {}),
                            if (_ticket.isRush == 1)
                              IconButton(
                                  icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.flash_on_rounded, color: Colors.orangeAccent)), onPressed: () {}),
                            if (_ticket.isRed == 1)
                              IconButton(icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.tour_rounded, color: Colors.red)), onPressed: () {}),
                          ]),
                        ),
                      ],
                    ),
                  ),
                  if (_ticket.isStarted)
                    Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CircularPercentIndicator(
                            radius: 50.0,
                            lineWidth: 4.0,
                            percent: (_progress / 100).toDouble(),
                            center: Text("${_ticket.progress}%", style: ts),
                            progressColor: Colors.blue,
                            animateFromLastPercent: true,
                            animation: true,
                            animationDuration: 500))
                ],
              ),
            )),
        Expanded(
            child: Scaffold(
                appBar: AppBar(
                    automaticallyImplyLeading: false,
                    title: Row(children: [
                      const Spacer(),
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close, color: Colors.black))
                    ]),
                    backgroundColor: Colors.white),
                body: _loading ? const Center(child: CircularProgressIndicator()) : _body(bottomNavigationBarSelectedIndex),
                backgroundColor: Colors.white,
                bottomNavigationBar: BottomAppBar(
                    elevation: 16,
                    // color: Colors.orange,
                    color: Theme.of(context).primaryColor,
                    shape: const CircularNotchedRectangle(),
                    notchMargin: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          _getBottomNavigationBarItem(Icons.tour_rounded, ("Flags"), 0),
                          _getBottomNavigationBarItem(Icons.data_usage_rounded, ("Progress"), 1),
                          _getBottomNavigationBarItem(Icons.category_outlined, ("Short Items"), 2),
                          _getBottomNavigationBarItem(Icons.history_rounded, ("History"), 3)
                        ],
                      ),
                    )),
                floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
                floatingActionButton: getViewFileButton()))
      ]),
    );
  }

  void getData(Ticket __ticket) {
    setState(() {
      _loading = true;
    });
    print('requesting data---------------');
    Api.get((EndPoints.tickets_info_getTicketInfo1), {'ticket': __ticket.id.toString()}).then((value) {
      if (kDebugMode) {
        print(' data recived---------------');
      }
      print((value.data));

      setState(() {
        ServerResponseMap res = ServerResponseMap.fromJson((value.data));
        var nowAt = _ticket.nowAt;
        _ticket = Ticket.fromJson((value.data));
        _ticket.nowAt = nowAt;
        // print(t.toJson());
        progressList = res.ticketProgressDetails;
        progressList.sort((a, b) => (a.operationNo ?? 0).compareTo(b.operationNo ?? 0));

        flags = res.flags;

        ticketHistory = TicketHistory.fromJsonArray(value.data['ticketHistories']);
        ticketComments = res.ticketComments;
        cprs = res.cprs;
      });

      // ErrorMessageView(errorMessage: value.body).show(context);
    }).onError((error, stackTrace) {
      print(stackTrace.toString());
      // ErrorMessageView(errorMessage: error.toString()).show(context);
      ErrorMessageView(errorMessage: stackTrace.toString()).show(context);
    }).whenComplete(() {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    });
  }

  Future<void> openFile() async {
    // List<int> ids = AppUser.getUser()?.sections.map((e) => e.id).toList() ?? [];
    int userSectionId = AppUser.getSelectedSection()?.id ?? 0;
    var pendingList = progressList.where((p) {
      return (p.status == 0) ? true : false;
    }).toList();

    print('------------------------------ ${(AppUser.havePermissionFor(NsPermissions.TICKET_EDIT_ANY_PDF))}');
    print('userSectionId = ${userSectionId}');
    print('_ticket.nowAt = ${_ticket.nowAt}');
    print('isPreCompleted(progressList) = ${isPreCompleted(progressList)}');

    if (_ticket.isCompleted) {
      return Ticket.open(context, _ticket, isPreCompleted: false);
    }

    if (userSectionId == _ticket.nowAt || isPreCompleted(progressList) || (AppUser.havePermissionFor(NsPermissions.TICKET_EDIT_ANY_PDF))) {
      if (_ticket.isStarted) {
        return Ticket.open(context, _ticket, isPreCompleted: true);
      } else {
        return showOpenActions(_ticket, context, () {}, isPreCompleted: isPreCompleted(progressList));
      }
    }

    if (((_ticket.completed == 0) &&
        (!_ticket.openAny) &&
        progressList.where((p) {
          return (p.status == 1 || p.section?.id == _ticket.nowAt) && (userSectionId == (p.section?.id)) ? true : false;
        }).isEmpty)) {
      final ids = pendingList.map((e) => e.section?.id).toSet();
      pendingList.retainWhere((x) => ids.remove(x.section?.id));

      return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                content: Builder(builder: (context) {
                  return SizedBox(
                      // height: 550,
                      // width: 50,
                      child: Center(
                          child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.report_problem_rounded, size: 54, color: Colors.amber),
                      ),
                      const Text(
                          'Until previous sections marked the job as finished in the system, the respective Work Ticket will not be opened for you.\n\nපෙර අංශයන් පද්ධතිය තුළ කාර්යය අවසන් කළ ලෙස සලකුණු කරන තෙක්, අදාළ වැඩ ටිකට්පත ඔබ වෙනුවෙන් විවෘත නොවේ.',
                          textAlign: TextAlign.center,
                          textScaleFactor: 1),
                      const SizedBox(height: 24),
                      Expanded(
                          child: SingleChildScrollView(
                              child: Column(
                                  children: pendingList
                                      .map((e) => ListTile(
                                          title: Text(e.section?.sectionTitle ?? ''),
                                          subtitle: Text("${e.section!.sectionTitle} @ ${e.section!.factory}", style: const TextStyle(color: Colors.redAccent))))
                                      .toList()))),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("OK"))
                    ],
                  )));
                }));
          });
    }

    if (_ticket.isStarted) {
      return Ticket.open(context, _ticket, isPreCompleted: isPreCompleted(progressList));
    } else {
      return showOpenActions(_ticket, context, () {}, isPreCompleted: isPreCompleted(progressList));
    }
  }

  // getFloatingButton() {
  //   print('_ticket.isStandard == ${_ticket.isStandard}');
  //
  //   var _button = FloatingActionButton(
  //       child: const Icon(Icons.import_contacts),
  //       onPressed: () async {
  //         openFile();
  //       });
  //
  //   // if (_ticket.isStandard) {
  //   //   if (widget.fromBarcode) {
  //   //     return _button;
  //   //   }
  //   //   return null;
  //   // }
  //
  //   print('isPreCompleted === ${isPreCompleted(progressList)}');
  //
  //   return (!_ticket.hasFile || _loading)
  //       ? null
  //       : (_ticket.isHold == 1)
  //           ? null
  //           : _button;
  // }

  bool isPreCompleted(List<Progress> progressList) {
    if (kIsWeb) {
      return true;
    }

    int? userSectionId = (AppUser.getSelectedSection()?.id);
    print("-------------------------------------------------zz1");
    progressList.forEach((element) {
      print("${element.doAt} ------------${element.status}----------  ${AppUser.getSelectedSection()!.id}");
      // print(element.toJson());
    });

    return progressList.where((element) => ((element.doAt == userSectionId && element.status == 1))).isNotEmpty;
  }

  FloatingActionButton? getViewFileButton() {
    var _button = FloatingActionButton(
        child: const Icon(Icons.import_contacts), onPressed: () => kIsWeb ? Ticket.open(context, _ticket, isPreCompleted: isPreCompleted(progressList)) : openFile());

    if ((!_ticket.hasFile)) {
      return null;
    }

    if (AppUser.havePermissionFor(NsPermissions.TICKET_EDIT_ANY_PDF)) {
      return _button;
    }

    if ((_ticket.isHold == 1)) {
      return null;
    }

    if (_ticket.isStandard) {
      if (kIsWeb || widget.fromBarcode) {
        return _button;
      }
      return null;
    }

    return _button;
  }
}
