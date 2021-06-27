import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smartwind/M/Ticket.dart';

class FinishCheckList extends StatefulWidget {
  Ticket ticket;

  FinishCheckList(this.ticket, {Key? key}) : super(key: key);

  @override
  _FinishCheckListState createState() {
    return _FinishCheckListState();
  }
}

class _FinishCheckListState extends State<FinishCheckList> {
  Map? checkListMap;

  @override
  void initState() {
    super.initState();

    DefaultAssetBundle.of(context).loadString("assets/data.json").then((data) {
      checkListMap = json.decode(data);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<String>(
      future: _loadData(), // async work
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting: return Text('Loading....');
          default:
            if (snapshot.hasError)
              return Text('Error: ${snapshot.error}');
            else
              return Text('Result: ${snapshot.data}');
        }
      },
    );

    // if(  ){
    //   return   Scaffold();
    // }
    //
    // return checkListMap == null
    //     ? Scaffold()
    //     : Scaffold(
    //         appBar: AppBar(
    //           title: Text("Check List"),
    //         ),
    //       );
  }

  _loadData() {

   



  }
}
