import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/AppUser.dart';
import 'package:smartwind/M/Enums.dart';
import 'package:smartwind/M/NsUser.dart';
import 'package:smartwind/M/Section.dart';

import '../Widgets/SearchBar.dart';

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

  final _controller = TextEditingController();
  List<Section> _filterdSections = [];
  List<String> factories = [];

  @override
  void initState() {
    super.initState();
    print('-------------------------------------SectionSelector');
    print(widget.nsUser.toJson());
    widget.nsUser.sections.sort((a, b) => a.factory.compareTo(b.factory));
    // _filterdSections = widget.nsUser.sections;

    factories = widget.nsUser.sections.map((e) => e.factory).toSet().toList();

    loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
            title: const Text("Select Section"),
            toolbarHeight: 100,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: Column(
                children: [
                  SearchBar(
                      onSearchTextChanged: (String text) {
                        searchText = text.toLowerCase();
                        loadData();
                      },
                      delay: 300,
                      searchController: _controller),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ChoiceChip(label: const Text("All"), selected: selectedFactory == null, onSelected: (v) => {selectedFactory = null, loadData()}),
                        ...factories.map((e) => Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: ChoiceChip(label: Text(e), selected: selectedFactory == e, onSelected: (v) => {selectedFactory = e, loadData()}),
                            ))
                      ],
                    ),
                  )
                ],
              ),
            )),
        body: Stack(
          children: [
            ListView.builder(
                itemCount: _filterdSections.length,
                itemBuilder: (context, i) {
                  Section section = _filterdSections[i];
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

  String? selectedFactory;
  var searchText = '';

  void loadData() {
    print(selectedFactory);
    _filterdSections = widget.nsUser.sections
        .where((element) => element.sectionTitle.toLowerCase().contains(searchText) && element.factory.toLowerCase().equalIgnoreCase((selectedFactory ?? '')))
        .toList();
    if (mounted) setState(() {});
  }
}
