import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartwind/C/OnlineDB.dart';
import 'package:smartwind/M/CPR.dart';
import 'package:smartwind/M/CprMaterial.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/V/Home/CPR/SetClientsToCPR.dart';
import 'package:smartwind/V/Widgets/ErrorMessageView.dart';

class AddCPR extends StatefulWidget {
  Ticket ticket;

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
        _matList.add(CprMaterial.fromJson(element).name);
      });
    });
  }

  TabController? _tabBarController;

  @override
  Widget build(BuildContext context) {
    print(_cpr.toJson());

    bool keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom != 0;
    return _tabBarController == null
        ? Container()
        : DefaultTabController(
            length: 2,
            child: Scaffold(
                floatingActionButton: Visibility(
                  visible: !keyboardIsOpen,
                  child: FloatingActionButton(
                    onPressed: () {
                      saving = true;
                      OnlineDB.apiPost("cpr/saveCpr", _cpr.toJson()).then((value) {
                        saving = false;
                        ErrorMessageView(errorMessage: value.data.toString()).show(context);
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
                    // bottom: PreferredSize(
                    //     preferredSize: Size.fromHeight(64.0),
                    //     child: Padding(
                    //       padding: const EdgeInsets.all(8.0),
                    //       child: Column(
                    //         children: [
                    //           if (_cpr.ticket!.mo != null)
                    //             Text(
                    //               "${_cpr.ticket!.mo}  ",
                    //               style: TextStyle(color: Colors.white, fontSize: 20),
                    //             ),
                    //           if (_cpr.ticket!.oe != null)
                    //             Text(
                    //               "${_cpr.ticket!.oe}",
                    //               style: TextStyle(color: Colors.white, fontSize: 20),
                    //             ),
                    //         ],
                    //       ),
                    //     )),

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
                                      showSearchBox: true,
                                      mode: Mode.DIALOG,
                                      showSelectedItem: true,
                                      showClearButton: true,
                                      isFilteredOnline: true,
                                      items: _cprTypes,
                                      hint: "Select CPR Type",
                                      onChanged: (c) {
                                        _cpr.cprType = c;
                                      })),
                            ),
                          ),
                          ListTile(title: Text("Suppliers"), subtitle: Card(child: SetClientToCPR(_cpr))),
                          ListTile(
                              title: Text("Comment"),
                              subtitle: Card(
                                  child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: TextField(
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
                                    child: TextField(
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
                      subtitle: Card(
                          child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(children: [
                                SizedBox(
                                    height: 50,
                                    child: Row(children: [
                                      Flexible(
                                          child: new DropdownSearch<String>(
                                              key: _dropdownSearchKey,
                                              selectedItem: "",
                                              items: [],
                                              searchBoxController: _nameController,
                                              showSearchBox: true,
                                              autoFocusSearchBox: true,
                                              mode: Mode.BOTTOM_SHEET,
                                              showSelectedItem: _showSelectedItem,
                                              showClearButton: true,
                                              isFilteredOnline: true,
                                              onFind: (String filter) => getData(filter),
                                              label: "Menu mode",
                                              hint: "country in menu mode",
                                              onChanged: (mat) {
                                                currentMarerial.name = mat!;
                                              })),
                                      SizedBox(width: 8),
                                      SizedBox(
                                          width: 100,
                                          child: TextField(
                                              controller: _qtyController,
                                              keyboardType: TextInputType.number,
                                              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                                              decoration: new InputDecoration(border: new OutlineInputBorder(borderSide: new BorderSide(color: Colors.teal)), labelText: 'QTY'),
                                              onChanged: (text) {
                                                currentMarerial.qty = int.tryParse(text) ?? 0;
                                              })),
                                      SizedBox(width: 8),
                                      IconButton(
                                          onPressed: () {
                                            _addMaterialToList(currentMarerial);
                                            currentMarerial = new CprMaterial();
                                            _qtyController.clear();
                                            _dropdownSearchKey.currentState!.changeSelectedItem("");
                                            setState(() {});
                                          },
                                          icon: Icon(Icons.add_rounded))
                                    ])),
                                Expanded(
                                  child: ListView.separated(
                                      itemBuilder: (context, index) {
                                        CprMaterial material = _cpr.materials[index];
                                        return ListTile(title: Text(material.name), trailing: Text("${material.qty}"));
                                      },
                                      itemCount: _cpr.materials.length,
                                      separatorBuilder: (BuildContext context, int index) {
                                        return Divider(height: 1, endIndent: 0.5, color: Colors.black12);
                                      }),
                                )
                              ]))),
                    ))
                  ],
                )),
          );
  }

  List<String> _matList = [];
  var _qtyController = TextEditingController();
  var _nameController = TextEditingController();
  bool _showSelectedItem = true;
  CprMaterial currentMarerial = new CprMaterial();
  final _dropdownSearchKey = GlobalKey<DropdownSearchState<String>>();

  getData(String filter) {
    List<String> data = _matList.where((element) => element.toLowerCase().contains(filter.toLowerCase())).toList();
    data.add(filter);
    return Future.value(data);
  }

  void _addMaterialToList(CprMaterial currentMarerial) {
    List<CprMaterial> x = _cpr.materials.where((element) => element.name == currentMarerial.name).toList();
    if (x.length == 0) {
      _cpr.materials.add(CprMaterial.fromJson(currentMarerial.toJson()));
    } else {
      x[0].qty += currentMarerial.qty;
    }
  }
}
