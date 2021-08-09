import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/TicketFlag.dart';
import 'package:smartwind/V/Widgets/UserImage.dart';

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
    "red": {"title": "Red Flag", "icon": CircleAvatar(child: Icon(Icons.tour_rounded, color: Colors.red), backgroundColor: Colors.white)},
    "rush": {"title": "Rush", "icon": CircleAvatar(child: Icon(Icons.flash_on_rounded, color: Colors.orangeAccent), backgroundColor: Colors.white)},
    "hold": {"title": "Hold", "icon": CircleAvatar(child: Icon(Icons.pan_tool_rounded, color: Colors.black), backgroundColor: Colors.white)},
    "gr": {"title": "GR", "icon": null},
    "sk": {"title": "SK", "icon":  null},
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
                          child: Container(child: Row(children: [x["icon"]??Container(), Text(x["title"] ?? "", style: TextStyle(fontSize: 23))])),
                        ),
                        subtitle: Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey[400]),
                          child: ListTile(
                            title: Row(
                              children: [
                                Expanded(flex: 3, child: Text(ticketFlag.flaged == 1 ? "Flag Added" : "Flag Removed")),
                                Expanded(flex: 3, child: Text(ticketFlag.getDateTime(), style: TextStyle()))
                              ],
                            ),
                            trailing: UserImage(nsUserId: ticketFlag.user, radius: 24),
                          ),
                        ),
                      ),
                      Container(child: getHistory(list))
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
      padding: const EdgeInsets.all(16.0),
      child: Container(
        child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.all(8),
          itemCount: ticketFlags.length,
          itemBuilder: (BuildContext context, int index) {
            TicketFlag ticketFlag = ticketFlags[index];

            return Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                  title: Row(
                    children: [
                      Expanded(flex: 3, child: Text(ticketFlag.flaged == 1 ? "Flag added" : "Flag Removed")),
                      Expanded(flex: 3, child: Text(ticketFlag.getDateTime(), style: TextStyle())),
                    ],
                  ),
                  // trailing: CircleAvatar(radius: 24.0, backgroundImage: NetworkImage("https://avatars.githubusercontent.com/u/60012991?v=4"), backgroundColor: Colors.transparent),
                  trailing: UserImage(nsUserId: ticketFlag.user, radius: 24)),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return Divider(
              height: 1,
              endIndent: 0.5,
              color: Colors.grey,
            );
          },
        ),
      ),
    );
  }
}
