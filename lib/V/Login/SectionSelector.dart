import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/M/Section.dart';
import 'package:smartwind/V/Home/Home.dart';

class SectionSelector extends StatefulWidget {
  NsUser nsUser;

  SectionSelector(this.nsUser, {Key? key}) : super(key: key);

  @override
  _SectionSelectorState createState() {
    return _SectionSelectorState();
  }
}

class _SectionSelectorState extends State<SectionSelector> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Center(
          child: Wrap(
              direction: Axis.vertical,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: List.generate(widget.nsUser.sections.length, (index) {
                Section section = widget.nsUser.sections[index];
                return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        widget.nsUser.section = section;
                        await  prefs.setString("user", json.encode(widget.nsUser));
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Home()), (Route<dynamic> route) => false);
                      },
                      child: Text(
                        section.sectionTitle + " @ " + section.factory,
                        textScaleFactor: 1.5,
                      ),
                    ));
              }))),
    );
  }
}
