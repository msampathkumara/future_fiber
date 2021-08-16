import 'package:flutter/material.dart';
import 'package:smartwind/M/CPR.dart';

import 'CprDerails.dart';

class CPRList extends StatefulWidget {
  CPRList({Key? key}) : super(key: key);

  @override
  _CPRListState createState() {
    return _CPRListState();
  }
}

class _CPRListState extends State<CPRList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  var _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  List<CPR> _cprList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: () {
                return reloadData();
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: _cprList.length,
                  itemBuilder: (BuildContext context, int index) {
                    CPR cpr = _cprList[index];

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onLongPress: () async {
                        await showCPROptions(cpr, context);
                        setState(() {});
                      },
                      onTap: () {
                        CprDetails.show(context, cpr);
                      },
                      onDoubleTap: () async {
                        // print(await ticket.getLocalFileVersion());
                        // ticket.open(context);
                      },
                      child: ListTile(
                        leading: Text(""),
                        title: Text(cpr.ticket!.mo ?? ""),
                        subtitle: Text(cpr.ticket!.oe ?? ""),
                        trailing: Wrap(children: []),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      height: 1,
                      endIndent: 0.5,
                      color: Colors.black12,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  reloadData() {}

  showCPROptions(CPR cpr, BuildContext context) {}
}
