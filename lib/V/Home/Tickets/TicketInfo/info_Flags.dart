import 'package:flutter/material.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/M/TicketFlag.dart';
import 'package:smartwind/M/hive.dart';
import 'package:smartwind/V/Widgets/UserButton.dart';
import 'package:smartwind/ns_icons_icons.dart';

class info_Flags extends StatefulWidget {
  List<TicketFlag> ticketFlag;
  List<TicketFlag> flagsHistory;

  info_Flags(this.ticketFlag, this.flagsHistory);

  @override
  _info_FlagsState createState() => _info_FlagsState();
}

class _info_FlagsState extends State<info_Flags> {
  List<TicketFlag> ticketFlags = [];
  List<TicketFlag> flagsHistory = [];

  @override
  void initState() {}

  Map<String, dynamic> titles = {
    "red": {"title": "Red Flag", "icon": const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.tour_rounded, color: Colors.red)), "expanded": false},
    "rush": {"title": "Rush", "icon": const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.flash_on_rounded, color: Colors.orangeAccent)), "expanded": false},
    "hold": {"title": "Stop Production", "icon": const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.pan_tool_rounded, color: Colors.black)), "expanded": false},
    "gr": {"title": "Graphics", "icon": const CircleAvatar(backgroundColor: Colors.white, child: Icon(NsIcons.gr, color: Colors.red)), "expanded": false},
    "sk": {"title": "SK", "icon": const CircleAvatar(backgroundColor: Colors.white, child: Icon(NsIcons.sk, color: Colors.red)), "expanded": false},
    "cross": {"title": "Cross Production", "icon": const CircleAvatar(backgroundColor: Colors.white, child: Icon(NsIcons.crossProduction, color: Colors.green)), "expanded": false},
  };

  TextStyle defaultStyle = const TextStyle(color: Colors.black);
  TextStyle linkStyle = const TextStyle(color: Colors.blue);
  TextStyle timeStyle = const TextStyle(color: Colors.grey);

  @override
  Widget build(BuildContext context) {
    ticketFlags = widget.ticketFlag;
    flagsHistory = widget.flagsHistory;

    return ticketFlags.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: ticketFlags.length,
              itemBuilder: (BuildContext context, int index) {
                TicketFlag ticketFlag = ticketFlags[index];
                // var list = flagsHistory.where((i) => i.type == ticketFlag.type).toList();
                var x = titles[ticketFlag.type];

                NsUser? user = HiveBox.usersBox.get(ticketFlag.user);

                // print(x.toString());

                return ListTile(
                  title: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(children: [x["icon"] ?? Container(), Text(x["title"] ?? "", style: const TextStyle(fontSize: 23))]),
                  ),
                  subtitle: Material(
                    elevation: 1,
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[200],
                    child: ListTile(
                      title: Column(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: UserButton(nsUserId: ticketFlag.user, imageRadius: 16),
                              ),
                              const Spacer(),
                              Text(ticketFlag.getDateTime(), style: const TextStyle(color: Colors.blue)),
                            ],
                          ),
                          Padding(
                              padding: const EdgeInsets.only(bottom: 8.0, left: 36),
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Text('"${ticketFlag.comment}"'),
                              ))
                        ],
                      ),
                      // leading: UserImage(nsUserId: ticketFlag.user, radius: 24),
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Divider(
                    height: 1,
                    endIndent: 0.5,
                    color: Colors.white38,
                  ),
                );
              },
            ),
          )
        : const Center(child: Text("No Flags"));
  }

  getHistory(List<TicketFlag> ticketFlags) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.all(8),
        itemCount: ticketFlags.length,
        itemBuilder: (BuildContext context, int index) {
          TicketFlag ticketFlag = ticketFlags[index];

          return Material(
              elevation: 0,
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[100],
              child: ListTile(
                title: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0, top: 8),
                          child: Text(ticketFlag.flaged == 1 ? "Flag Added" : "Flag Removed", style: const TextStyle(fontWeight: FontWeight.bold)))),
                  Text(ticketFlag.comment),
                  const Divider(),
                ]),
                subtitle: SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: UserButton(nsUserId: ticketFlag.user, imageRadius: 16),
                      ),
                      const Spacer(),
                      Text(ticketFlag.getDateTime(), style: const TextStyle(color: Colors.blue)),
                    ],
                  ),
                ),
                // leading: UserImage(nsUserId: ticketFlag.user, radius: 24),
              ));
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider(
            height: 8,
            endIndent: 0.5,
            color: Colors.transparent,
          );
        },
      ),
    );
  }

  Widget getXXX(List<TicketFlag> ticketFlags, x) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ExpansionPanelList(
        animationDuration: const Duration(milliseconds: 1000),
        dividerColor: Colors.red,
        elevation: 0,
        children: [
          ExpansionPanel(
            backgroundColor: Colors.grey[200],
            canTapOnHeader: true,
            body: getHistory(ticketFlags),
            headerBuilder: (BuildContext context, bool isExpanded) {
              return const Padding(
                padding: EdgeInsets.only(top: 16.0, left: 16.0),
                child: Text("History"),
              );
            },
            isExpanded: x["expanded"],
          )
        ],
        expansionCallback: (int item, bool status) {
          setState(() {
            x["expanded"] = !x["expanded"];
          });
        },
      ),
    );
  }
}
