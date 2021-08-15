import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SetClientToCPR extends StatefulWidget {
  const SetClientToCPR({Key? key}) : super(key: key);

  @override
  _SetClientToCPRState createState() => _SetClientToCPRState();
}

class _SetClientToCPRState extends State<SetClientToCPR> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Card(child: Column(children: [ListTile(title: Text("Cutting")), ListTile(title: Text("SA")), ListTile(title: Text("Printing"))])),
        Card(),
        Card(),
      ],
    ));
  }
}
