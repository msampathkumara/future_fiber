import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind_future_fibers/M/Section.dart';
import 'package:smartwind_future_fibers/Web/Widgets/DialogView.dart';
import 'package:deebugee_plugin/DialogView.dart';

import '../../../../C/DB/hive.dart';

class SectionList extends StatefulWidget {
  final List<Section> selectedSections;

  final Function(List<Section>) onSelect;

  const SectionList(this.selectedSections, this.onSelect, {Key? key}) : super(key: key);

  @override
  State<SectionList> createState() => _SectionListState();

  show(context) {
    kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _SectionListState extends State<SectionList> {
  List<Section> sectionList = [];

  late List<Section> selectedSections;

  @override
  void initState() {
    sectionList = HiveBox.sectionsBox.values.toList();
    selectedSections = widget.selectedSections;

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
              bool selected = selectedSections.where((element) => section.id == element.id).isNotEmpty;

              return CheckboxListTile(
                title: Text(section.sectionTitle, textScaleFactor: 1),
                subtitle: Text(section.factory, style: const TextStyle(color: Colors.red)),
                onChanged: (bool? value) {
                  if (value == true) {
                    selectedSections.add(section);
                  } else {
                    selectedSections.removeWhere((e) => e.id == section.id);
                  }
                  widget.onSelect(selectedSections);
                  setState(() {});
                },
                value: selected,
              );
            }));
  }
}
