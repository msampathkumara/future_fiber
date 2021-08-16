import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/CPR.dart';

class CprDetails extends StatefulWidget {
  CPR cpr;

  CprDetails(this.cpr);

  static show(context, CPR cpr) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CprDetails(cpr)),
    );
  }

  @override
  _CprDetailsState createState() => _CprDetailsState();
}

class _CprDetailsState extends State<CprDetails> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
