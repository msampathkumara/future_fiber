import 'package:flutter/material.dart';
import 'package:smartwind/M/AppUser.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/M/Section.dart';
import 'package:smartwind/V/Home/Home.dart';

class SectionSelector extends StatefulWidget {
  final NsUser nsUser;

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
    print('-------------------------------------SectionSelector');
    print(widget.nsUser.toJson());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(title: Text("Select Section")),
        body: ListView.builder(
            itemCount: widget.nsUser.sections.length,
            itemBuilder: (context, i) {
              Section section = widget.nsUser.sections[i];
              return ListTile(
                onTap: () async {
                  widget.nsUser.section = section;
                  AppUser.setUser(widget.nsUser);

                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Home()), (Route<dynamic> route) => false);
                },
                title: Text(section.sectionTitle, textScaleFactor: 1),
                subtitle: Text(section.factory, style: TextStyle(color: Colors.red)),
              );
            }));
  }
}
