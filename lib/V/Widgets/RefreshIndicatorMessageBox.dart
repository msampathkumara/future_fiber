import 'package:flutter/cupertino.dart';

Widget RefreshIndicatorMessageBox(msg) => Stack(children: [
      ListView(shrinkWrap: true, children: [Container(height: 500)]),
      Center(child: Text(msg, textScaleFactor: 1.5))
    ]);
