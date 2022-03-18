import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/StandardTicket.dart';

class StandardTicketInfo extends StatefulWidget {
  StandardTicket standardTicket;

  StandardTicketInfo(this.standardTicket);

  void show(context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => this),
    );
  }

  @override
  _StandardTicketInfoState createState() => _StandardTicketInfoState();
}

class _StandardTicketInfoState extends State<StandardTicketInfo> {
  late StandardTicket standardTicket;

  @override
  void initState() {
    standardTicket = widget.standardTicket;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
          length: 3,
          child: NestedScrollView(
            headerSliverBuilder: (context, value) {
              return [
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  snap: false,
                  title: Text(standardTicket.oe ?? ""),
                  expandedHeight: 250,
                  bottom: TabBar(
                    tabs: [Tab(text: "Call"), Tab(text: "History"), Tab(text: "Sails")],
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                Container(
                    child: ListView.builder(
                        itemCount: 100,
                        itemBuilder: (context, index) {
                          return Text("Item $index");
                        })),
                Container(
                    child: ListView.builder(
                        itemCount: 100,
                        itemBuilder: (context, index) {
                          return Text("Item $index");
                        })),
                Container(
                    child: ListView.builder(
                        itemCount: 100,
                        itemBuilder: (context, index) {
                          return Text("Item $index");
                        })),
              ],
            ),
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
}

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: DefaultTabController(
//         length: 3,
//         child: NestedScrollView(
//             headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
//               print(innerBoxIsScrolled);
//               return <Widget>[
//                 SliverAppBar(backgroundColor: Colors.red,
//                   expandedHeight: 400.0,
//                   collapsedHeight: 400,
//                   floating: false,
//                   pinned: true,
//                   snap: false,
//                   flexibleSpace: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
//                     var top = constraints.biggest.height;
//                     return SizedBox(child: CircularProgressIndicator(),height: double.infinity,);
//                     // return FlexibleSpaceBar(
//                     //     stretchModes: [StretchMode.blurBackground],
//                     //     centerTitle: true,
//                     //     title: Text("Collapsing Toolbar ${top}", style: TextStyle(color: Colors.white, fontSize: 16.0)),
//                     //     background: Image.network("https://images.pexels.com/photos/396547/pexels-photo-396547.jpeg?auto=compress&cs=tinysrgb&h=350", fit: BoxFit.cover));
//                   }),
//                 ),
//                 SliverPersistentHeader(
//                   delegate: _SliverAppBarDelegate(TabBar(labelColor: Colors.black87, unselectedLabelColor: Colors.grey, tabs: [
//                     Tab(icon: Icon(Icons.info), text: "Tab 1"),
//                     Tab(icon: Icon(Icons.history_rounded), text: "History"),
//                     Tab(icon: Icon(Icons.local_activity_rounded), text: "History")
//                   ])),
//                   pinned: true,
//                 ),
//               ];
//             },
//             body: const TabBarView(
//               children: [
//                 Icon(Icons.directions_car),
//                 Icon(Icons.directions_transit),
//                 Icon(Icons.local_activity_rounded),
//               ],
//             )),
//       ),
//     );
//   }
// }
//
// class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
//   _SliverAppBarDelegate(this._tabBar);
//
//   final TabBar _tabBar;
//
//   @override
//   double get minExtent => _tabBar.preferredSize.height;
//
//   @override
//   double get maxExtent => _tabBar.preferredSize.height;
//
//   @override
//   Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return new Container(
//       child: _tabBar,
//     );
//   }
//
//   @override
//   bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
//     return false;
//   }
// }
