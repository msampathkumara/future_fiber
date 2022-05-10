import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/AppUser.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/M/Section.dart';

class UserSectionSelector extends StatefulWidget {
  final NsUser nsUser;

  final Function(Section section) onSelect;

  const UserSectionSelector(this.nsUser, this.onSelect, {Key? key}) : super(key: key);

  @override
  _UserSectionSelectorState createState() {
    return _UserSectionSelectorState();
  }

  show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _UserSectionSelectorState extends State<UserSectionSelector> {
  bool _loading = false;

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
        appBar: AppBar(title: const Text("Select Section")),
        body: Stack(
          children: [
            ListView.builder(
                itemCount: widget.nsUser.sections.length,
                itemBuilder: (context, i) {
                  Section section = widget.nsUser.sections[i];
                  return ListTile(
                      onTap: () async {
                        setState(() {
                          _loading = true;
                        });
                        AppUser.setSelectedSection(section).then((value) {
                          _loading = false;
                          widget.onSelect.call(section);
                        });
                      },
                      title: Text(section.sectionTitle, textScaleFactor: 1),
                      subtitle: Text(section.factory, style: const TextStyle(color: Colors.red)));
                }),
            if (_loading) Container(color: Colors.white, child: const Center(child: CircularProgressIndicator()))
          ],
        ));
  }
}
