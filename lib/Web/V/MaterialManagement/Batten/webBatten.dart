import 'package:flutter/material.dart';

import '../../underConstruction.dart';

class WebBatten extends StatefulWidget {
  const WebBatten({Key? key}) : super(key: key);

  @override
  State<WebBatten> createState() => _WebBattenState();
}

class _WebBattenState extends State<WebBatten> {
  @override
  Widget build(BuildContext context) {
    return const UnderConstructions(title: "Batten");
  }
}
