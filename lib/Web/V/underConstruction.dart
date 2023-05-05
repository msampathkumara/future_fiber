import 'package:flutter/material.dart';
import 'package:smartwind_future_fibers/res.dart';

class UnderConstructions extends StatelessWidget {
  final String title;

  const UnderConstructions({Key? key, this.title = ""}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(Res.uc),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text("$title   Under Constructions", textScaleFactor: 2, style: const TextStyle(color: Colors.grey)),
        )
      ],
    ));
  }
}
