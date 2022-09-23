import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartwind/C/form_input_decoration.dart';
import 'package:smartwind/Web/Widgets/DialogView.dart';

import '../../../../C/Api.dart';
import '../../../../M/EndPoints.dart';
import '../../../../M/Enums.dart';
import '../../../../globals.dart';

class AddDefaultEmployeeCounts extends StatefulWidget {
  const AddDefaultEmployeeCounts({Key? key}) : super(key: key);

  @override
  State<AddDefaultEmployeeCounts> createState() => _AddDefaultEmployeeCountsState();

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _AddDefaultEmployeeCountsState extends State<AddDefaultEmployeeCounts> {
  var selectedDate = DateTime.now();
  String? selectedFactory;

  bool error = false;

  bool loading = false;

  Map sectionDefaultsMap = {};

  bool get isFactorySelected => selectedFactory != null;

  @override
  Widget build(BuildContext context) {
    return DialogView(
      child: getWebUi(),
      width: 500,
      height: 600,
    );
  }

  final List<String> _sections = ['3D Drawing', 'Hand Work', 'layout', 'Qc', 'Sewing', 'Stickup'];
  final List<String> _factories = ["Upwind", 'Nylon Standard', 'Nylon Custom', "OD", "OEM", "38 Upwind", '38 Nylon Standard', '38 Nylon Custom', "38 OD", "38 OEM", "None"];

  getWebUi() {
    return Scaffold(
        appBar: AppBar(title: const Text("Add Default Employee Count")),
        body: error
            ? Center(
                child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, direction: Axis.vertical, children: [
                  const Text("Something went wrong"),
                  TextButton(
                      onPressed: () {
                        getData(selectedFactory);
                      },
                      child: const Text("Retry", style: TextStyle(color: Colors.red)))
                ]),
              )
            : loading
                ? const Center(child: CircularProgressIndicator())
                : isFactorySelected
                    ? Column(
                        children: [
                          ListTile(title: Row(children: [getFactorySector(), const Spacer()])),
                          const Padding(padding: EdgeInsets.only(left: 8.0, right: 8), child: Divider(color: Colors.red)),
                          Expanded(
                            child: ListView.separated(
                              itemBuilder: (BuildContext context, int index) {
                                var section = _sections[index];
                                Map? sectionAvg = sectionDefaultsMap[section];
                                print(sectionAvg?["count"]);
                                var myController = TextEditingController();
                                myController.text = "${sectionAvg?["count"] ?? 0}";
                                var focusNode = FocusNode();
                                focusNode.addListener(() {
                                  if (focusNode.hasFocus) {
                                    myController.selectAll();
                                  }
                                });
                                return ListTile(
                                    title: Text(section),
                                    trailing: SizedBox(
                                        width: 100,
                                        height: 36,
                                        child: TextFormField(
                                          focusNode: focusNode,
                                          controller: myController,
                                          onTap: myController.selectAll,
                                          autofocus: true,
                                          onChanged: (text) => sectionDefaultsMap[section]["count"] = text,
                                          decoration: FormInputDecoration.getDeco(),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), FilteringTextInputFormatter.digitsOnly],
                                        )));
                              },
                              separatorBuilder: (BuildContext context, int index) {
                                return Divider(color: Colors.grey.shade200);
                              },
                              itemCount: _sections.length,
                            ),
                          ),
                        ],
                      )
                    : Center(child: getFactorySector()),
        bottomNavigationBar: (isFactorySelected && !loading && !error)
            ? BottomAppBar(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        onPressed: () {
                          save();
                        },
                        child: const Text("Save as Defaults"))))
            : null);
  }

  Widget getFactorySector() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: PopupMenuButton<int>(
          offset: const Offset(0, 30),
          padding: const EdgeInsets.all(16.0),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
          child: isFactorySelected
              ? Chip(label: Text(selectedFactory ?? 'Select Factory', style: const TextStyle(color: Colors.black)))
              : Chip(label: Text(selectedFactory ?? 'Select Factory', style: const TextStyle(color: Colors.white)), backgroundColor: getPrimaryColor(context)),
          onSelected: (result) {},
          itemBuilder: (BuildContext context) {
            return Production.values
                .without([Production.None, Production.All])
                .map((e) => PopupMenuItem(
                    onTap: () {
                      selectedFactory = e.getValue();
                      getData(selectedFactory);
                    },
                    value: 0,
                    enabled: true,
                    child: Text(e.getValue())))
                .toList();
          }),
    );
  }

  getData(factory) {
    error = false;
    setState(() {
      loading = true;
    });

    Api.get(EndPoints.dashboard_settings_getDefaultEmployeeCount, {"factory": factory}).then((res) {
      Map data = res.data;

      List sectionDefaults = data["sectionDefaults"];
      sectionDefaultsMap = {for (var e in sectionDefaults) e["sectionTitle"]: e};

      print(sectionDefaultsMap);
    }).whenComplete(() {
      setState(() {
        loading = false;
      });
    }).catchError((err) {
      print(err);
      error = true;
    });
  }

  void save() {
    setState(() {
      loading = true;
    });

    Api.post(EndPoints.dashboard_settings_saveDefaultEmployeeCount, {'sectionDefaults': sectionDefaultsMap.values.toList()}).then((res) {
      Map data = res.data;
      selectedFactory = null;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saved"), width: 200, behavior: SnackBarBehavior.floating));
      Navigator.pop(context);
    }).whenComplete(() {
      setState(() {
        loading = false;
      });
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Something went wrong"), action: SnackBarAction(label: 'Retry', onPressed: save)));
      setState(() {
        // _dataLoadingError = true;
      });
    });
  }
}
