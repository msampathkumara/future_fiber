import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/C/OnlineDB.dart';
import 'package:smartwind/M/CPR/CPR.dart';
import 'package:smartwind/M/CPR/CprItem.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/V/Widgets/ErrorMessageView.dart';

class AddCPR extends StatefulWidget {
  final Ticket ticket;

  AddCPR(this.ticket);

  @override
  _AddCPRState createState() => _AddCPRState();
}

class _AddCPRState extends State<AddCPR> with TickerProviderStateMixin {
  var _sailTypes = ["Standard", "Custom"];
  var _shortageTypes = ["Short", "Damage", "Unreceived"];
  var _cprTypes = ["Pocket", "Rope Luff", "Purchase Cover", "Overhead Tape", "Tape Cover", "Take Down", "Soft Hanks", "Windows", "Stow pouch", "VPC**", "Other"];
  var _sailType;
  var _shortageType;

  CPR _cpr = new CPR();
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _cpr.ticket = widget.ticket;

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _tabBarController = TabController(length: 2, vsync: this);
      _tabBarController!.addListener(() {
        print("Selected Index: " + _tabBarController!.index.toString());
      });
      setState(() {});
    });

    OnlineDB.apiGet("cpr/getAllMaterials", {}).then((res) {
      List mats = res.data["materials"];
      print(mats);
      mats.forEach((element) {
        _matList.add(CprItem.fromJson(element).item);
      });
    });
  }

  TabController? _tabBarController;

  @override
  Widget build(BuildContext context) {
    print(_cpr.toJson());

    bool keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom != 0;
    if (_tabBarController == null) {
      return saving
          ? Container(
              child: Center(
                  child: Column(
              children: [CircularProgressIndicator(), Text("Saving")],
            )))
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
                  OnlineDB.apiPost("cpr/saveCpr", _cpr.toJson()).then((value) {
                    saving = false;
                    Navigator.of(context).pop();
                  }).catchError((onError) {
                    ErrorMessageView(errorMessage: onError.toString()).show(context);
                  });
                },
                child: const Icon(Icons.save),
                backgroundColor: Colors.lightBlue,
              ),
            ),
            appBar: AppBar(
                title: Text("Add CPR"),
                bottom: TabBar(
                  controller: _tabBarController,
                  indicatorWeight: 4.0,
                  indicatorColor: Colors.white,
                  isScrollable: true,
                  tabs: [
                    Tab(
                      child: Wrap(alignment: WrapAlignment.center, children: [
                        Icon(
                          Icons.info_rounded,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 4, left: 4),
                          child: Text("Info"),
                        )
                      ]),
                    ),
                    Tab(
                      child: Wrap(alignment: WrapAlignment.center, children: [
                        Icon(
                          Icons.settings_suggest_rounded,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 4, left: 4),
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
                    child: Container(
                        child: Column(children: [
                      ListTile(
                          title: Text("Sail"),
                          subtitle: Card(
                            child: ListTile(
                              title: Text(
                                widget.ticket.mo ?? widget.ticket.oe ?? "",
                                style: TextStyle(fontSize: 20),
                              ),
                              subtitle: Text(widget.ticket.mo != null ? widget.ticket.oe ?? "" : ""),
                            ),
                          )),
                      ListTile(
                        title: Text("Sail Type"),
                        isThreeLine: true,
                        subtitle: Card(
                          margin: EdgeInsets.all(8.0),
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
                        title: Text("Shortage Type"),
                        isThreeLine: true,
                        subtitle: Card(
                          margin: EdgeInsets.all(8.0),
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
                        title: Text("CPR Type"),
                        subtitle: SizedBox(
                          width: 200,
                          child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: DropdownSearch<String>(
                                  selectedItem: _cpr.cprType,
                                  showSearchBox: true,
                                  mode: Mode.DIALOG,
                                  // showSelectedItem: true,
                                  showClearButton: true,
                                  isFilteredOnline: true,
                                  items: _cprTypes,
                                  hint: "Select CPR Type",
                                  onChanged: (c) {
                                    _cpr.cprType = c;
                                  })),
                        ),
                      ),
                      if (_cpr.ticket!.production == null)
                        ListTile(
                          title: Text("Client"),
                          subtitle: SizedBox(
                            width: 200,
                            child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: DropdownSearch<String>(
                                    selectedItem: _cpr.client,
                                    mode: Mode.BOTTOM_SHEET,
                                    // showSelectedItem: true,
                                    items: ["Upwind", "OD", "Nylon", "OEM"],
                                    hint: "Select Client",
                                    onChanged: (c) {
                                      _cpr.client = c;
                                    })),
                          ),
                        ),
                      ListTile(title: Text("Suppliers"), subtitle: Card(child: getSuppliers())),
                      ListTile(
                          title: Text("Comment"),
                          subtitle: Card(
                              child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: TextFormField(
                                      initialValue: _cpr.comment,
                                      onChanged: (value) {
                                        _cpr.comment = value;
                                      },
                                      maxLines: 8,
                                      decoration: InputDecoration.collapsed(hintText: "Enter your comment here"))))),
                      ListTile(
                        title: Text("Image URL"),
                        subtitle: Card(
                            child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: TextFormField(
                                    initialValue: _cpr.image,
                                    onChanged: (value) {
                                      _cpr.image = value;
                                    },
                                    maxLines: 3,
                                    decoration: InputDecoration.collapsed(hintText: "Enter your url here")))),
                      )
                    ])),
                  ),
                ),
                Container(
                    child: ListTile(
                  title: Text("Materials"),
                  subtitle: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(children: [
                        SizedBox(
                            height: 50,
                            child: Row(children: [
                              Flexible(
                                  child: DropdownSearch<String>(
                                      key: _dropdownSearchKey,
                                      selectedItem: "",
                                      items: [],
                                      // searchBoxController: _nameController,
                                      showSearchBox: true,
                                      // autoFocusSearchBox: true,
                                      mode: Mode.BOTTOM_SHEET,
                                      // showSelectedItem: _showSelectedItem,
                                      showClearButton: true,
                                      isFilteredOnline: true,
                                      // onFind: (String filter) => getData(filter),
                                      label: "Menu mode",
                                      hint: "country in menu mode",
                                      onChanged: (mat) {
                                        currentMaterial.item = mat!;
                                      })),
                              SizedBox(width: 8),
                              SizedBox(
                                  width: 100,
                                  child: TextField(
                                      controller: _qtyController,
                                      decoration: new InputDecoration(border: new OutlineInputBorder(borderSide: new BorderSide(color: Colors.teal)), labelText: 'QTY'),
                                      onChanged: (text) {
                                        currentMaterial.qty = (text);
                                      })),
                              SizedBox(width: 8),
                              Card(
                                child: IconButton(
                                    color: Colors.blue,
                                    onPressed: () {
                                      _addMaterialToList(currentMaterial);
                                      currentMaterial = new CprItem();
                                      _qtyController.clear();
                                      _dropdownSearchKey.currentState!.changeSelectedItem("");
                                      setState(() {});
                                    },
                                    icon: Icon(Icons.add_rounded)),
                              )
                            ])),
                        SizedBox(
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
                                        title: Text(material.item), trailing: Wrap(alignment: WrapAlignment.center, direction: Axis.vertical, children: [Text("${material.qty}")])),
                                  );
                                },
                                itemCount: _cpr.items.length,
                                separatorBuilder: (BuildContext context, int index) {
                                  return Divider(height: 1, endIndent: 0.5, color: Colors.black12);
                                }),
                          ),
                        )
                      ])),
                ))
              ],
            )),
      );
    }
  }

  List<String> _matList = [];
  var _qtyController = TextEditingController();
  CprItem currentMaterial = new CprItem();
  final _dropdownSearchKey = GlobalKey<DropdownSearchState<String>>();

  getData(String filter) {
    List<String> data = _matList.where((element) => element.toLowerCase().contains(filter.toLowerCase())).toList();
    data.add(filter);
    return Future.value(data);
  }

  void _addMaterialToList(CprItem currentMaterial) {
    List<CprItem> x = _cpr.items.where((element) => element.item == currentMaterial.item).toList();
    if (x.length == 0) {
      _cpr.items.add(CprItem.fromJson(currentMaterial.toJson()));
    } else {
      x[0].qty += currentMaterial.qty;
    }
  }

  var _suppliers = ["Cutting", "SA", "Printing"];
  var _supplier1;
  var _supplier2;
  var _supplier3;

  getSuppliers() {
    _supplier2 = _supplier1 == _supplier2 ? null : _supplier2;
    _supplier3 = _supplier2 == _supplier3 ? null : _supplier3;
    _cpr.suppliers = [_supplier1, _supplier2, _supplier3];
    _cpr.suppliers.removeWhere((value) => value == null);
    print(_cpr.suppliers);
    return Container(
      child: Column(
        children: [
          ListTile(
            title: Text("First Supplier"),
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
              title: Text("Second Supplier"),
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
              title: Text("Third Supplier"),
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
      ),
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
                    title: Text("Delete"),
                    leading: Icon(Icons.delete_forever_rounded, color: Colors.red),
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
