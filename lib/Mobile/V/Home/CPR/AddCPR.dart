import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/CPR/CPR.dart';
import 'package:smartwind/M/CPR/CprItem.dart';
import 'package:smartwind/M/EndPoints.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/Mobile/V/Widgets/ErrorMessageView.dart';

import '../../../../C/Api.dart';

class AddCPR extends StatefulWidget {
  final Ticket ticket;

  const AddCPR(this.ticket, {super.key});

  @override
  _AddCPRState createState() => _AddCPRState();
}

class _AddCPRState extends State<AddCPR> with TickerProviderStateMixin {
  final _sailTypes = ["Standard", "Custom"];
  final _shortageTypes = ["Short", "Damage", "Unreceived"];
  final _cprTypes = ["Pocket", "Rope Luff", "Purchase Cover", "Overhead Tape", "Tape Cover", "Take Down", "Soft Hanks", "Windows", "Stow pouch", "VPC**", "Other"];
  var _sailType;
  var _shortageType;

  final CPR _cpr = CPR();
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _cpr.ticket = widget.ticket;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tabBarController = TabController(length: 2, vsync: this);
      _tabBarController!.addListener(() {
        print("Selected Index: ${_tabBarController!.index}");
      });
      setState(() {});
    });

    Api.get("cpr/getAllMaterials", {}).then((res) {
      List mats = res.data["materials"];
      print(mats);
      for (var element in mats) {
        _matList.add(CprItem.fromJson(element).item);
      }
    });
  }

  TabController? _tabBarController;

  @override
  Widget build(BuildContext context) {
    print(_cpr.toJson());

    bool keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom != 0;
    if (_tabBarController == null) {
      return saving
          ? Center(
              child: Column(
              children: const [CircularProgressIndicator(), Text("Saving")],
            ))
          : Container();
    } else {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
            floatingActionButton: Visibility(
              visible: !keyboardIsOpen,
              child: FloatingActionButton(
                onPressed: () {
                  saving = true;
                  setState(() {});
                  Api.post(EndPoints.materialManagement_cpr_saveCpr, _cpr.toJson()).then((value) {
                    saving = false;
                    Navigator.of(context).pop();
                  }).catchError((onError) {
                    ErrorMessageView(errorMessage: onError.toString()).show(context);
                  });
                },
                backgroundColor: Colors.lightBlue,
                child: const Icon(Icons.save),
              ),
            ),
            appBar: AppBar(
                title: const Text("Add CPR"),
                bottom: TabBar(
                  controller: _tabBarController,
                  indicatorWeight: 4.0,
                  indicatorColor: Colors.white,
                  isScrollable: true,
                  tabs: [
                    Tab(
                      child: Wrap(alignment: WrapAlignment.center, children: const [
                        Icon(
                          Icons.info_rounded,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 4, bottom: 4, left: 4),
                          child: Text("Info"),
                        )
                      ]),
                    ),
                    Tab(
                      child: Wrap(alignment: WrapAlignment.center, children: const [
                        Icon(
                          Icons.settings_suggest_rounded,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 4, bottom: 4, left: 4),
                          child: Text("Materials"),
                        )
                      ]),
                    ),
                  ],
                )),
            body: TabBarView(
              controller: _tabBarController,
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(children: [
                      ListTile(
                          title: const Text("Sail"),
                          subtitle: Card(
                            child: ListTile(
                              title: Text(
                                widget.ticket.mo ?? widget.ticket.oe ?? "",
                                style: const TextStyle(fontSize: 20),
                              ),
                              subtitle: Text(widget.ticket.mo != null ? widget.ticket.oe ?? "" : ""),
                            ),
                          )),
                      ListTile(
                        title: const Text("Sail Type"),
                        isThreeLine: true,
                        subtitle: Card(
                          margin: const EdgeInsets.all(8.0),
                          clipBehavior: Clip.antiAlias,
                          child: Row(
                            children: [
                              for (final _sailT in _sailTypes)
                                SizedBox(
                                  width: 200,
                                  child: RadioListTile(
                                      selected: false,
                                      toggleable: true,
                                      title: Text(_sailT),
                                      value: _sailT,
                                      groupValue: _sailType,
                                      onChanged: (value) {
                                        setState(() {
                                          _sailType = value;
                                          _cpr.sailType = value as String?;
                                        });
                                      }),
                                ),
                            ],
                          ),
                        ),
                      ),
                      ListTile(
                        title: const Text("Shortage Type"),
                        isThreeLine: true,
                        subtitle: Card(
                          margin: const EdgeInsets.all(8.0),
                          clipBehavior: Clip.antiAlias,
                          child: Row(
                            children: [
                              for (final _shortageT in _shortageTypes)
                                SizedBox(
                                  width: 200,
                                  child: RadioListTile(
                                      selected: false,
                                      toggleable: true,
                                      title: Text(_shortageT),
                                      value: _shortageT,
                                      groupValue: _shortageType,
                                      onChanged: (value) {
                                        setState(() {
                                          _shortageType = value;
                                          _cpr.shortageType = value as String?;
                                        });
                                      }),
                                ),
                            ],
                          ),
                        ),
                      ),
                      ListTile(
                        title: const Text("CPR Type"),
                        subtitle: SizedBox(
                          width: 200,
                          child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: DropdownSearch<String>(
                                  selectedItem: _cpr.cprType,
                                  // showSearchBox: true,
                                  // mode: Mode.DIALOG,
                                  // showSelectedItem: true,
                                  clearButtonProps: const ClearButtonProps(),
                                  // isFilteredOnline: true,
                                  items: _cprTypes,
                                  dropdownDecoratorProps: const DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                    hintText: "Select CPR Type",
                                  )),
                                  onChanged: (c) {
                                    _cpr.cprType = c;
                                  })),
                        ),
                      ),
                      if (_cpr.ticket!.production == null)
                        ListTile(
                          title: const Text("Client"),
                          subtitle: SizedBox(
                            width: 200,
                            child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: DropdownSearch<String>(
                                    selectedItem: _cpr.client,
                                    // mode: Mode.BOTTOM_SHEET,
                                    // showSelectedItem: true,
                                    items: const ["Upwind", "OD", 'Nylon Standard', 'Nylon Custom', "OEM"],
                                    dropdownDecoratorProps: const DropDownDecoratorProps(
                                        dropdownSearchDecoration: InputDecoration(
                                      hintText: "Select Client",
                                    )),
                                    onChanged: (c) {
                                      _cpr.client = c;
                                    })),
                          ),
                        ),
                      ListTile(title: const Text("Suppliers"), subtitle: Card(child: getSuppliers())),
                      ListTile(
                          title: const Text("Comment"),
                          subtitle: Card(
                              child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: TextFormField(
                                      initialValue: _cpr.comment,
                                      onChanged: (value) {
                                        _cpr.comment = value;
                                      },
                                      maxLines: 8,
                                      decoration: const InputDecoration.collapsed(hintText: "Enter your comment here"))))),
                      ListTile(
                        title: const Text("Image URL"),
                        subtitle: Card(
                            child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: TextFormField(
                                    initialValue: _cpr.image,
                                    onChanged: (value) {
                                      _cpr.image = value;
                                    },
                                    maxLines: 3,
                                    decoration: const InputDecoration.collapsed(hintText: "Enter your url here")))),
                      )
                    ]),
                  ),
                ),
                ListTile(
                  title: const Text("Materials"),
                  subtitle: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(children: [
                        SizedBox(
                            height: 50,
                            child: Row(children: [
                              Flexible(
                                  child: DropdownSearch<String>(
                                      key: _dropdownSearchKey,
                                      selectedItem: "",
                                      items: const [],
                                      // searchBoxController: _nameController,
                                      // showSearchBox: true,
                                      // autoFocusSearchBox: true,
                                      // mode: Mode.BOTTOM_SHEET,
                                      // showSelectedItem: _showSelectedItem,
                                      clearButtonProps: const ClearButtonProps(),
                                      // isFilteredOnline: true,
                                      // onFind: (String filter) => getData(filter),
                                      dropdownDecoratorProps: const DropDownDecoratorProps(
                                          dropdownSearchDecoration: InputDecoration(
                                        labelText: "Materials",
                                        hintText: "select Materials",
                                      )),
                                      onChanged: (mat) {
                                        currentMaterial.item = mat!;
                                      })),
                              const SizedBox(width: 8),
                              SizedBox(
                                  width: 100,
                                  child: TextField(
                                      controller: _qtyController,
                                      decoration: const InputDecoration(border: OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)), labelText: 'QTY'),
                                      onChanged: (text) {
                                        currentMaterial.qty = (text);
                                      })),
                              const SizedBox(width: 8),
                              Card(
                                child: IconButton(
                                    color: Colors.blue,
                                    onPressed: () {
                                      _addMaterialToList(currentMaterial);
                                      currentMaterial = CprItem();
                                      _qtyController.clear();
                                      _dropdownSearchKey.currentState!.changeSelectedItem("");
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.add_rounded)),
                              )
                            ])),
                        const SizedBox(
                          height: 20,
                        ),
                        Expanded(
                          child: Card(
                            child: ListView.separated(
                                itemBuilder: (context, index) {
                                  CprItem material = _cpr.items[index];
                                  return GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onLongPress: () async {
                                      await showMaterialOptions(material, context);
                                      setState(() {});
                                    },
                                    child: ListTile(
                                        title: Text(material.item), trailing: Wrap(alignment: WrapAlignment.center, direction: Axis.vertical, children: [Text(material.qty)])),
                                  );
                                },
                                itemCount: _cpr.items.length,
                                separatorBuilder: (BuildContext context, int index) {
                                  return const Divider(height: 1, endIndent: 0.5, color: Colors.black12);
                                }),
                          ),
                        )
                      ])),
                )
              ],
            )),
      );
    }
  }

  final List<String> _matList = [];
  final _qtyController = TextEditingController();
  CprItem currentMaterial = CprItem();
  final _dropdownSearchKey = GlobalKey<DropdownSearchState<String>>();

  getData(String filter) {
    List<String> data = _matList.where((element) => element.toLowerCase().contains(filter.toLowerCase())).toList();
    data.add(filter);
    return Future.value(data);
  }

  void _addMaterialToList(CprItem currentMaterial) {
    List<CprItem> x = _cpr.items.where((element) => element.item == currentMaterial.item).toList();
    if (x.isEmpty) {
      _cpr.items.add(CprItem.fromJson(currentMaterial.toJson()));
    } else {
      x[0].qty += currentMaterial.qty;
    }
  }

  final _suppliers = ["Cutting", "SA", "Printing"];
  String? _supplier1;
  String? _supplier2;
  String? _supplier3;

  getSuppliers() {
    _supplier2 = _supplier1 == _supplier2 ? null : _supplier2;
    _supplier3 = _supplier2 == _supplier3 ? null : _supplier3;

    var l = [_supplier1, _supplier2, _supplier3];

    _cpr.suppliers = l.whereType<String>().toList();

    print(_cpr.suppliers);
    return Column(
      children: [
        ListTile(
          title: const Text("First Supplier"),
          isThreeLine: true,
          subtitle: Row(
            children: [
              for (final _supplier in _suppliers)
                SizedBox(
                  width: 200,
                  child: RadioListTile<String>(
                      selected: false,
                      toggleable: true,
                      title: Text(_supplier),
                      value: _supplier,
                      groupValue: _supplier1,
                      onChanged: (value) {
                        if (value == null) {
                          _supplier2 = null;
                          _supplier3 = null;
                        }
                        print(value);
                        setState(() {
                          _supplier1 = value;
                        });
                      }),
                ),
            ],
          ),
        ),
        if (_supplier1 != null)
          ListTile(
            title: const Text("Second Supplier"),
            isThreeLine: true,
            subtitle: Row(
              children: [
                for (final _supplier in _suppliers)
                  if (_supplier != _supplier1)
                    SizedBox(
                      width: 200,
                      child: RadioListTile<String>(
                          selected: false,
                          toggleable: true,
                          title: Text(_supplier),
                          value: _supplier,
                          groupValue: _supplier2,
                          onChanged: (value) {
                            if (value == null) {
                              _supplier3 = null;
                            }
                            setState(() {
                              _supplier2 = value;
                            });
                          }),
                    ),
              ],
            ),
          ),
        if (_supplier1 != null && _supplier2 != null)
          ListTile(
            title: const Text("Third Supplier"),
            isThreeLine: true,
            subtitle: Row(
              children: [
                for (final _supplier in _suppliers)
                  if (_supplier != _supplier2)
                    SizedBox(
                      width: 200,
                      child: RadioListTile<String>(
                          toggleable: true,
                          selected: false,
                          title: Text(_supplier),
                          value: _supplier,
                          groupValue: _supplier3,
                          onChanged: (value) {
                            setState(() {
                              _supplier3 = value;
                            });
                          }),
                    ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> showMaterialOptions(CprItem material, BuildContext context1) async {
    print(material.toJson());
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 100,
          decoration: const BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)), color: Colors.white),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Column(children: [
                const SizedBox(
                  height: 20,
                ),
                ListTile(
                    title: const Text("Delete"),
                    leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                    onTap: () async {
                      _cpr.items.removeWhere((item) => item == material);
                      Navigator.of(context).pop();
                    }),
              ])
            ],
          ),
        );
      },
    );
  }
}
