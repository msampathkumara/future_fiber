import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartwind/M/EndPoints.dart';
import 'package:smartwind/Web/Widgets/DialogView.dart';
import 'package:smartwind/Web/Widgets/IfWeb.dart';
import 'package:smartwind/globals.dart';

import '../../../../C/Api.dart';
import '../../../../C/form_input_decoration.dart';
import '../../../../M/Enums.dart';

class AddAverageSailTimes extends StatefulWidget {
  const AddAverageSailTimes({Key? key}) : super(key: key);

  @override
  State<AddAverageSailTimes> createState() => _AddAverageSailTimesState();

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _AddAverageSailTimesState extends State<AddAverageSailTimes> {
  String? selectedFactory;

  final List<String> _sections = ['3D Drawing', 'Hand Work', 'layout', 'Qc', 'Sewing', 'Stickup'];

  bool get isFactorySelected => selectedFactory != null;

  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getUi(), child: DialogView(child: getWebUi(), width: 400, height: 600));
  }

  getWebUi() {
    return Scaffold(
        appBar: AppBar(title: const Text('Average Sail Times')),
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
                          ListTile(
                              title: Row(
                                children: [getFactorySector(), const Spacer()],
                              ),
                              trailing: SizedBox(
                                  width: 100,
                                  height: 36,
                                  child: TextFormField(
                                    initialValue: "${factoryAverages["hours"] ?? ''}",
                                    onChanged: (text) {
                                      factoryAverages["hours"] = text;
                                    },
                                    decoration: FormInputDecoration.getDeco(),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), FilteringTextInputFormatter.digitsOnly],
                                  ))),
                          const Padding(
                              padding: EdgeInsets.only(left: 8.0, right: 8),
                              child: Divider(
                                color: Colors.red,
                              )),
                          Expanded(
                            child: ListView.separated(
                              itemBuilder: (BuildContext context, int index) {
                                var section = _sections[index];
                                Map? sectionAv = sectionAveragesMap[section];

                                return ListTile(
                                  title: Text(section),
                                  trailing: SizedBox(
                                      width: 100,
                                      height: 36,
                                      child: TextFormField(
                                        initialValue: "${sectionAv?['hours'] ?? 0}",
                                        onChanged: (text) {
                                          sectionAveragesMap[section]['hours'] = text;
                                        },
                                        decoration: FormInputDecoration.getDeco(),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), FilteringTextInputFormatter.digitsOnly],
                                      )),
                                );
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
                  child: ElevatedButton(onPressed: save, child: const Text('Save')),
                ),
              )
            : null);
  }

  getUi() {
    return getWebUi();
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

  bool loading = false;
  bool error = false;
  Map factoryAverages = {};
  List sectionAverages = [];
  Map sectionAveragesMap = {};

  getData(factory) {
    error = false;
    setState(() {
      loading = true;
    });

    Api.get(EndPoints.dashboard_settings_getSailAverageTime, {"factory": factory}).then((res) {
      Map data = res.data;

      factoryAverages = data["factoryAverages"];
      sectionAverages = data["sectionAverages"];
      sectionAveragesMap = {for (var e in sectionAverages) e["sectionTitle"]: e};

      // print(sectionAveragesMap);
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

    Api.post(EndPoints.dashboard_settings_saveSailAverageTime, {'sectionAverages': sectionAveragesMap.values.toList(), 'factoryAverages': factoryAverages}).then((res) {
      Map data = res.data;
      selectedFactory = null;
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saved"), width: 200, behavior: SnackBarBehavior.floating));
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
