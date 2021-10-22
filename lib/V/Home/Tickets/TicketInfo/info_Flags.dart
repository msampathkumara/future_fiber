import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/TicketFlag.dart';
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
    "red": {"title": "Red Flag", "icon": CircleAvatar(child: Icon(Icons.tour_rounded, color: Colors.red), backgroundColor: Colors.white), "expanded": false},
    "rush": {"title": "Rush", "icon": CircleAvatar(child: Icon(Icons.flash_on_rounded, color: Colors.orangeAccent), backgroundColor: Colors.white), "expanded": false},
    "hold": {"title": "Stop Production", "icon": CircleAvatar(child: Icon(Icons.pan_tool_rounded, color: Colors.black), backgroundColor: Colors.white), "expanded": false},
    "gr": {"title": "Graphics", "icon": CircleAvatar(child: Icon(NsIcons.gr , color: Colors.red), backgroundColor: Colors.white), "expanded": false},
    "sk": {"title": "SK", "icon": CircleAvatar(child: Icon(NsIcons.sk, color: Colors.red), backgroundColor: Colors.white), "expanded": false},
  };

  @override
  Widget build(BuildContext context) {
    ticketFlags = widget.ticketFlag;
    flagsHistory = widget.flagsHistory;

    return ticketFlags.length > 0
        ? Container(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: ticketFlags.length,
                itemBuilder: (BuildContext context, int index) {
                  TicketFlag ticketFlag = ticketFlags[index];
                  var list = flagsHistory.where((i) => i.type == ticketFlag.type).toList();
                  var x = titles[ticketFlag.type];

                  print(x.toString());

                  return Column(
                    children: [
                      ListTile(
                        title: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(child: Row(children: [x["icon"] ?? Container(), Text(x["title"] ?? "", style: TextStyle(fontSize: 23))])),
                        ),
                        subtitle: Material(
                          elevation: 3,
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[200],
                          child: ListTile(
                            title: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0, top: 8),
                                      child: Text(ticketFlag.flaged == 1 ? "Flag Added" : "Flag Removed", style: TextStyle(fontWeight: FontWeight.bold)))),
                              Text(ticketFlag.comment),
                              Divider()
                            ]),
                            subtitle: Column(
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4.0),
                                      child: UserButton(nsUserId: ticketFlag.user, imageRadius: 16),
                                    ),
                                    Spacer(),
                                    Text(ticketFlag.getDateTime(), style: TextStyle(color: Colors.blue)),
                                  ],
                                ),

                                if (list.length > 0) getXXX(list, x)
                              ],
                            ),
                            // leading: UserImage(nsUserId: ticketFlag.user, radius: 24),
                          ),
                        ),
                      ),
                      // Container(child: getHistory(list))
                    ],
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Divider(
                      height: 1,
                      endIndent: 0.5,
                      color: Colors.white38,
                    ),
                  );
                },
              ),
            ),
          )
        : Center(child: Text("No Flags"));
  }

  getHistory(List<TicketFlag> ticketFlags) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0,right: 8,bottom: 8),
      child: Container(
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
                            child: Text(ticketFlag.flaged == 1 ? "Flag Added" : "Flag Removed", style: TextStyle(fontWeight: FontWeight.bold)))),
                    Text(ticketFlag.comment),
                    Divider(),
                  ]),
                  subtitle: SizedBox(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: UserButton(nsUserId: ticketFlag.user, imageRadius: 16),
                        ),
                        Spacer(),
                        Text(ticketFlag.getDateTime(), style: TextStyle(color: Colors.blue)),
                      ],
                    ),
                  ),
                  // leading: UserImage(nsUserId: ticketFlag.user, radius: 24),
                ));
          },
          separatorBuilder: (BuildContext context, int index) {
            return Divider(
              height: 8,
              endIndent: 0.5,
              color: Colors.transparent,
            );
          },
        ),
      ),
    );
  }

  Widget getXXX(List<TicketFlag> ticketFlags, x) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ExpansionPanelList(
        animationDuration: Duration(milliseconds: 1000),
        dividerColor: Colors.red,
        elevation: 0,
        children: [
          ExpansionPanel(backgroundColor:   Colors.grey[200],canTapOnHeader: true,
            body: getHistory(ticketFlags),
            headerBuilder: (BuildContext context, bool isExpanded) {
              return Padding(
                padding: const EdgeInsets.only(top:16.0,left: 16.0),
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
