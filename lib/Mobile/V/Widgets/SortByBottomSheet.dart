// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:smartwind_future_fibers/M/Enums.dart';
//
//  class SortByBottomSheet   {
//
//
//  static     _sortByBottomSheetMenu(context) {
//      getListItem(String title, icon, key) {
//        return ListTile(
//          title: Text(title),
//          selectedTileColor: Colors.black12,
//          selected: listSortBy == key,
//          leading: icon is IconData ? FaIcon(icon) : icon,
//          onTap: () {
//            Navigator.pop(context);
//            loadData(0).then((value) {
//              setState(() {});
//            });
//          },
//        );
//      }
//
//      showModalBottomSheet(
//          shape: RoundedRectangleBorder(
//            borderRadius: BorderRadius.circular(10.0),
//          ),
//          backgroundColor: Colors.white,
//          context: context,
//          builder: (builder) {
//            return Container(
//              color: Colors.transparent,
//              child: Column(
//                children: [
//                  Padding(
//                    padding: const EdgeInsets.all(16.0),
//                    child: Text(
//                      "Sort By",
//                      textScaleFactor: 1.2,
//                    ),
//                  ),
//                  Expanded(
//                    child: Padding(
//                        padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
//                        child: ListView(
//                          children: [
//                            getListItem("Date", FontAwesomeIcons.calendarDay, "uptime"),
//                            getListItem("Name", FontAwesomeIcons.amazon, "mo"),
//                            getListItem("Red Flag", FontAwesomeIcons.flag, "isred"),
//                            getListItem("Hold", FontAwesomeIcons.handRock, "ishold"),
//                            getListItem("Rush", FontAwesomeIcons.bolt, "isrush"),
//                            getListItem(
//                                "SK",
//                                CircleAvatar(
//                                  backgroundColor: Colors.grey,
//                                  child: Center(
//                                    child: Text(
//                                      "SK",
//                                      style: TextStyle(color: Colors.white),
//                                    ),
//                                  ),
//                                ),
//                                "issk"),
//                            getListItem(
//                                "GR",
//                                CircleAvatar(
//                                  backgroundColor: Colors.grey,
//                                  child: Center(
//                                    child: Text(
//                                      "GR",
//                                      style: TextStyle(color: Colors.white),
//                                    ),
//                                  ),
//                                ),
//                                "isgr"),
//                            getListItem("Short", FontAwesomeIcons.shoppingBasket, "sort"),
//                            getListItem("Error Route", FontAwesomeIcons.exclamationTriangle, "errOut"),
//                            getListItem("Print", FontAwesomeIcons.print, "inprint"),
//                          ],
//                        )),
//                  ),
//                ],
//              ),
//            );
//          });
//    }
//
//  }
//
