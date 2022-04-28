import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/Section.dart';
import 'package:smartwind/M/hive.dart';
import 'package:smartwind/Web/Widgets/DialogView.dart';

class SectionList extends StatefulWidget {
  final List<Section> SelectedSections;

  final Function(List<Section>) onSelect;

  const SectionList(this.SelectedSections, this.onSelect, {Key? key}) : super(key: key);

  @override
  State<SectionList> createState() => _SectionListState();

  show(context) {
    kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _SectionListState extends State<SectionList> {
  List<Section> sectionList = [];

  late List<Section> SelectedSections;

  @override
  void initState() {
    sectionList = HiveBox.sectionsBox.values.toList();
    SelectedSections = widget.SelectedSections;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return kIsWeb ? DialogView(child: getWebUi(), width: 500) : getUi();
  }

  getUi() {}

  getWebUi() {
    return Scaffold(
        appBar: AppBar(title: const Text("Select Section")),
        body: ListView.builder(
            itemCount: sectionList.length,
            itemBuilder: (context, i) {
              Section section = sectionList[i];
              bool selected = SelectedSections.where((element) => section.id == element.id).isNotEmpty;

              return CheckboxListTile(
                title: Text(section.sectionTitle, textScaleFactor: 1),
                subtitle: Text(section.factory, style: const TextStyle(color: Colors.red)),
                onChanged: (bool? value) {
                  if (value == true) {
                    SelectedSections.add(section);
                  } else {
                    SelectedSections.removeWhere((e) => e.id == section.id);
                  }
                  widget.onSelect(SelectedSections);
                  setState(() {});
                },
                value: selected,
              );
            }));
  }
}
