import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UnderConstructions extends StatelessWidget {
  final title;

  const UnderConstructions({Key? key, this.title = ""}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset("assets/uc.png"),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text("${title}   Under Constructions", textScaleFactor: 2, style: TextStyle(color: Colors.grey)),
        )
      ],
    )));
  }
}
