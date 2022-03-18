part of 'TicketList.dart';

Future<void> showTicketOptions(Ticket ticket, BuildContext context1, BuildContext context) async {
  print(ticket.toJson());
  await showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) {
      return Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)), color: Colors.white),
        height: 650,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            ListTile(
              title: Text(ticket.mo ?? ticket.oe!),
              subtitle: Text(ticket.oe!),
            ),
            Divider(),
            Expanded(
                child: Container(
              child: SingleChildScrollView(
                  child: Column(children: [
                if (AppUser.havePermissionFor(Permissions.SET_RED_FLAG))
                  ListTile(
                    title: Text(ticket.isRed == 1 ? "Remove Red Flag" : "Set Red Flag"),
                    leading: Icon(Icons.flag),
                    onTap: () async {
                      Navigator.of(context).pop();
                      bool resul = await FlagDialog.showRedFlagDialog(context1, ticket);
                      ticket.isRed = resul ? 1 : 0;
                    },
                  ),
                if (AppUser.havePermissionFor(Permissions.STOP_PRODUCTION))
                  ListTile(
                    title: Text(ticket.isHold == 1 ? "Restart Production" : "Stop Production"),
                    leading: Icon(Icons.pan_tool_rounded, color: Colors.red),
                    onTap: () async {
                      Navigator.of(context).pop();
                      bool resul = await FlagDialog.showStopProductionFlagDialog(context1, ticket);
                      ticket.isHold = resul ? 1 : 0;
                    },
                  ),
                if (AppUser.havePermissionFor(Permissions.SET_GR))
                  ListTile(
                    onTap: () async {
                      Navigator.of(context).pop();
                      await FlagDialog.showGRDialog(context1, ticket);
                    },
                    title: Text(ticket.isGr == 1 ? "Remove GR" : "Set GR"),
                    // leading: SizedBox(
                    //     width: 24, height: 24, child: CircleAvatar(backgroundColor: Colors.blue, child: Center(child: Text("GR", style: TextStyle(color: Colors.white)))))
                    leading: Icon(NsIcons.gr, color: Colors.blue),
                  ),
                // ListTile(
                //     onTap: () async {
                //       Navigator.of(context).pop();
                //       await FlagDialog.showSKDialog(context1, ticket);
                //     },
                //     title: Text(ticket.isSk == 1 ? "Remove SK" : "Set SK"),
                //     leading: SizedBox(
                //         width: 24, height: 24, child: CircleAvatar(backgroundColor: Colors.pink, child: Center(child: Text("SK", style: TextStyle(color: Colors.white)))))),
                if (AppUser.havePermissionFor(Permissions.SET_RUSH))
                  ListTile(
                      title: Text(ticket.isRush == 1 ? "Remove Rush" : "Set Rush"),
                      leading: Icon(Icons.offline_bolt_outlined, color: Colors.orangeAccent),
                      onTap: () async {
                        Navigator.of(context).pop();
                        // await FlagDialog.showRushDialog(context1, ticket);
                        var u = ticket.isRush == 1 ? "removeFlag" : "setFlag";
                        OnlineDB.apiPost("tickets/flags/" + u, {"ticket": ticket.id.toString(), "comment": "", "type": "rush"}).then((response) async {});
                      }),
                if (AppUser.havePermissionFor(Permissions.SEND_TO_PRINTING))
                  ListTile(
                      title: Text(ticket.inPrint == 1 ? "Cancel Printing" : "Send To Print"),
                      leading: Icon(ticket.inPrint == 1 ? Icons.print_disabled_outlined : Icons.print_outlined, color: Colors.deepOrangeAccent),
                      onTap: () async {
                        Navigator.of(context).pop();
                        await sendToPrint(ticket);
                      }),
                if (AppUser.havePermissionFor(Permissions.FINISH_TICKET))
                  ListTile(
                      title: Text("Finish"),
                      leading: Icon(Icons.check_circle_outline_outlined, color: Colors.green),
                      onTap: () async {
                        Navigator.of(context).pop();
                        await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return FinishCheckList(ticket);
                            });
                        // await Navigator.push(context1, MaterialPageRoute(builder: (context) => FinishCheckList(ticket)));
                      }),
                if (ticket.crossPro == 0 && AppUser.havePermissionFor(Permissions.SET_CROSS_PRODUCTION))
                  ListTile(
                      title: Text("Set Cross Production"),
                      leading: Icon(NsIcons.crossProduction, color: Colors.green),
                      onTap: () async {
                        await Navigator.push(context1, MaterialPageRoute(builder: (context) => CrossProduction(ticket)));
                        Navigator.of(context).pop();
                      }),
                if (ticket.crossPro == 1 && AppUser.havePermissionFor(Permissions.SET_CROSS_PRODUCTION))
                  ListTile(
                      title: Text("Remove Cross Production"),
                      leading: Icon(NsIcons.crossProduction, color: Colors.green),
                      onTap: () async {
                        Navigator.of(context).pop();
                        showAlertDialog(context, ticket);
                      }),
                if (AppUser.havePermissionFor(Permissions.SHARE_TICKETS))
                  ListTile(
                      title: Text("Share Work Ticket"),
                      leading: Icon(NsIcons.share, color: Colors.lightBlue),
                      onTap: () async {
                        await ticket.sharePdf(context);
                        Navigator.of(context).pop();
                      }),
                if (AppUser.havePermissionFor(Permissions.ADD_CPR))
                  ListTile(
                      title: Text("Add CPR"),
                      leading: Icon(NsIcons.cpr, color: Colors.amber),
                      onTap: () async {
                        await ticket.addCPR(context);
                        Navigator.of(context).pop();
                      }),
                if (AppUser.havePermissionFor(Permissions.SHIPPING_SYSTEM))
                  ListTile(
                      title: Text("Shipping"),
                      leading: Icon(NsIcons.shipping, color: Colors.brown),
                      onTap: () async {
                        await ticket.openInShippingSystem(context);
                        Navigator.of(context).pop();
                      }),
                if (AppUser.havePermissionFor(Permissions.CS))
                  ListTile(
                      title: Text("CS"),
                      leading: Icon(Icons.pivot_table_chart_rounded, color: Colors.green),
                      onTap: () async {
                        await ticket.openInCS(context);
                        Navigator.of(context).pop();
                      }),
                if (AppUser.havePermissionFor(Permissions.DELETE_TICKETS))
                  ListTile(
                      title: Text("Delete"),
                      leading: Icon(NsIcons.delete, color: Colors.red),
                      onTap: () async {
                        //TODO set delete url
                        OnlineDB.apiPost("tickets/delete", {"id": ticket.id.toString()}).then((response) async {
                          print('TICKET DELETED');
                          print(response.data);
                          print(response.statusCode);
                        });
                        Navigator.of(context).pop();
                      }),
              ])),
            ))
          ],
        ),
      );
    },
  );
}

showAlertDialog(BuildContext context, ticket) {
  showDialog(
    context: context,
    builder: (BuildContext context1) {
      return AlertDialog(
        title: Text("Remove Cross Production"),
        content: Text("Do you really want to remove cross production from this ticket ? "),
        actions: [
          TextButton(
            child: Text("No"),
            onPressed: () {
              Navigator.of(context1).pop();
            },
          ),
          TextButton(
            child: Text("Yes"),
            onPressed: () {
              Navigator.of(context1).pop();
              OnlineDB.apiPost("tickets/crossProduction/removeCrossProduction", {'ticketId': ticket.id.toString()}).then((response) async {
                print(response.data);
              });
            },
          ),
        ],
      );
    },
  );
}

Future sendToPrint(Ticket ticket) async {
  if (ticket.inPrint == 0) {
    await OnlineDB.apiPost("tickets/print", {"ticket": ticket.id.toString(), "action": "sent"}).then((value) {
      print('Send to print  ${value.data}');
      ticket.inPrint = 1;
    }).onError((error, stackTrace) {
      print(error);
    });

    return 1;
  } else {
    await OnlineDB.apiPost("tickets/print", {"ticket": ticket.id.toString(), "action": "cancel"});
    ticket.inPrint = 0;
    return 0;
  }
}

String listSortBy = "shipDate";
bool listSortDirectionIsDESC = false;
String sortedBy = "Date";

void _sortByBottomSheetMenu(context, loadData) {
  getListItem(String title, icon, key) {
    return ListTile(
      trailing: (listSortBy == key ? (listSortDirectionIsDESC ? Icon(Icons.arrow_upward_rounded) : Icon(Icons.arrow_downward_rounded)) : null),
      title: Text(title),
      selectedTileColor: Colors.black12,
      selected: listSortBy == key,
      leading: icon is IconData ? Icon(icon) : icon,
      onTap: () {
        if (listSortBy == key) {
          listSortDirectionIsDESC = !listSortDirectionIsDESC;
        } else {
          listSortDirectionIsDESC = true;
        }
        listSortBy = key;
        sortedBy = title;
        Navigator.pop(context);
        loadData();
      },
    );
  }

  showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      backgroundColor: Colors.white,
      context: context,
      builder: (builder) {
        return Container(
          color: Colors.transparent,
          child: Column(
            children: [
              Padding(padding: const EdgeInsets.all(16.0), child: Text("Sort By", textScaleFactor: 1.2)),
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                    child: ListView(
                      children: [
                        getListItem("Shipping Date", Icons.date_range_rounded, "shipDate"),
                        getListItem("Modification Date", Icons.date_range_rounded, "uptime"),
                        getListItem("Delivery Date", Icons.date_range_rounded, "deliveryDate"),
                        getListItem("Name", Icons.sort_by_alpha_rounded, "mo")
                      ],
                    )),
              ),
            ],
          ),
        );
      });
}
