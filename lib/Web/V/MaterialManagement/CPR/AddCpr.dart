import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:searchfield/searchfield.dart';
import 'package:smartwind/M/CPR/CPR.dart';
import 'package:smartwind/M/EndPoints.dart';
import 'package:smartwind/M/Ticket.dart';
import 'package:smartwind/M/hive.dart';
import 'package:smartwind/Web/V/MaterialManagement/CPR/PastMaterialRow.dart';
import 'package:smartwind/Web/V/MaterialManagement/DropMaterialList.dart';
import 'package:smartwind/Web/Widgets/DialogView.dart';
import 'package:smartwind/Web/Widgets/IfWeb.dart';

import '../../../../C/Api.dart';
import '../../../../M/CPR/CprItem.dart';

class AddCpr extends StatefulWidget {
  final Ticket ticket;

  const AddCpr(this.ticket, {Key? key}) : super(key: key);

  @override
  State<AddCpr> createState() {
    return _AddCprState();
  }

  show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _AddCprState extends State<AddCpr> {
  bool isControlPressed = false;

  CPR cpr = CPR();

  // final _sailTypes = ["Standard", "Custom"];
  final _shortageTypes = ["Short", "Damage", "Unreceived"];
  final _cprTypes = ["Pocket", "Rope Luff", "Purchase Cover", "Overhead Tape", "Tape Cover", "Take Down", "Soft Hanks", "Windows", "Stow pouch", "VPC**", "Other"];
  final _suppliers = ["Cutting", "SA", "Printing", 'None'];
  final _clients = ['Upwind', 'OD', 'Nylon Standard', 'Nylon Custom', 'OEM', '38 Upwind', '38 OD', '38 Nylon Standard', '38 Nylon Custom', '38 OEM'];
  var textEditingController = TextEditingController();

  bool saving = false;

  @override
  void initState() {
    cpr.ticket = widget.ticket;
    cpr.sailType = HiveBox.standardTicketsBox.values.where((element) => element.oe == cpr.ticket?.oe).isEmpty ? "Custom" : "Standard";
    getAllMaterials();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getUi(), child: DialogView(child: getWebUi()));
  }

  var titleTheme = const TextStyle(fontSize: 12, color: Colors.grey);
  var valTheme = const TextStyle(fontSize: 15, color: Colors.black);
  var vd = const VisualDensity(horizontal: 0, vertical: -4);
  var st = const TextStyle(fontSize: 12, color: Colors.black);

  List<String> _matList = [];
  final _qtyController = TextEditingController();
  CprItem currentMaterial = CprItem();

  TextEditingController myController = TextEditingController();

  getWebUi() {
    List<CprItem> _selectedItems = List.from(selectedItems);
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        // bottomNavigationBar: BottomAppBar(
        // color: errMsg.isEmpty ? Colors.white : Colors.red,
        // shape: const CircularNotchedRectangle(),
        // child: SizedBox(height: 50, child: Padding(padding: const EdgeInsets.all(8.0), child: Text(errMsg, style: const TextStyle(color: Colors.white))))),
        appBar: AppBar(title: Text(cpr.ticket?.mo ?? ''), actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close))
        ]),
        body: Stack(
          children: [
            Row(children: [
              Card(
                elevation: 4,
                margin: const EdgeInsets.all(8),
                child: SizedBox(
                    width: 400,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        child: SizedBox(
                            width: 400,
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              ListTile(
                                  visualDensity: vd,
                                  title: Text("Sail", style: titleTheme),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(widget.ticket.mo ?? widget.ticket.oe ?? ""),
                                        Text(widget.ticket.mo != null ? widget.ticket.oe ?? "" : "", style: const TextStyle(color: Colors.red))
                                      ],
                                    ),
                                  )),
                              ListTile(
                                  dense: true,
                                  title: Text("Sail Type", style: titleTheme),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text("${cpr.sailType}", style: const TextStyle(color: Colors.red)),
                                  )),
                              ListTile(
                                  dense: true,
                                  title: Text("Client", style: titleTheme),
                                  isThreeLine: true,
                                  // subtitle: Padding(
                                  //     padding: const EdgeInsets.only(left: 8.0),
                                  //     child: DropdownButtonHideUnderline(
                                  //         child: Container(
                                  //             padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                  //             decoration: BoxDecoration(
                                  //                 border: Border.all(color: Colors.grey.shade400, width: 1, style: BorderStyle.solid), borderRadius: BorderRadius.circular(4)),
                                  //             child: DropdownButton<String>(
                                  //                 hint: const Text("Client"),
                                  //                 value: cpr.client,
                                  //                 icon: const Icon(Icons.arrow_downward),
                                  //                 elevation: 16,
                                  //                 style: const TextStyle(color: Colors.deepPurple),
                                  //                 onChanged: (String? newValue) {
                                  //                   setState(() {
                                  //                     cpr.client = newValue!;
                                  //                   });
                                  //                 },
                                  //                 items: _clients.map<DropdownMenuItem<String>>((String value) {
                                  //                   return DropdownMenuItem<String>(
                                  //                     value: value,
                                  //                     child: Padding(
                                  //                       padding: const EdgeInsets.only(left: 8.0),
                                  //                       child: Text(value),
                                  //                     ),
                                  //                   );
                                  //                 }).toList()))))
                                  subtitle: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: PopupMenuButton<String>(
                                          offset: const Offset(0, 30),
                                          padding: const EdgeInsets.all(16.0),
                                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                                          child: Chip(
                                              avatar: const Icon(Icons.person_rounded, color: Colors.black),
                                              label: Row(
                                                  children: [Text(cpr.client ?? 'Select Client'), const Spacer(), const Icon(Icons.arrow_drop_down_rounded, color: Colors.black)])),
                                          onSelected: (result) {},
                                          itemBuilder: (BuildContext context) {
                                            return _clients.map((String value) {
                                              return PopupMenuItem<String>(
                                                  value: value,
                                                  onTap: () {
                                                    setState(() {
                                                      cpr.client = value;
                                                    });
                                                  },
                                                  child: Text(value));
                                            }).toList();
                                          }))),
                              ListTile(
                                dense: true,
                                title: Text("Shortage Type", style: titleTheme),
                                isThreeLine: true,
                                // subtitle: Padding(
                                //     padding: const EdgeInsets.only(left: 8.0),
                                //     child: DropdownButtonHideUnderline(
                                //         child: Container(
                                //             padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                //             decoration: BoxDecoration(
                                //                 border: Border.all(color: Colors.grey.shade400, width: 1, style: BorderStyle.solid), borderRadius: BorderRadius.circular(4)),
                                //             child: DropdownButton<String>(
                                //                 hint: const Text("Select Shortage Type"),
                                //                 value: cpr.shortageType,
                                //                 icon: const Icon(Icons.arrow_downward),
                                //                 elevation: 16,
                                //                 style: const TextStyle(color: Colors.deepPurple),
                                //                 onChanged: (String? newValue) {
                                //                   setState(() {
                                //                     cpr.shortageType = newValue!;
                                //                   });
                                //                 },
                                //                 items: _shortageTypes.map<DropdownMenuItem<String>>((String value) {
                                //                   return DropdownMenuItem<String>(
                                //                     value: value,
                                //                     child: Padding(
                                //                       padding: const EdgeInsets.only(left: 8.0),
                                //                       child: Text(value),
                                //                     ),
                                //                   );
                                //                 }).toList()))))
                                subtitle: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: PopupMenuButton<String>(
                                        offset: const Offset(0, 30),
                                        padding: const EdgeInsets.all(16.0),
                                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                                        child: Chip(
                                            avatar: const Icon(Icons.menu_open, color: Colors.black),
                                            label: Row(children: [
                                              Text(cpr.shortageType ?? 'Select Shortage type'),
                                              const Spacer(),
                                              const Icon(Icons.arrow_drop_down_rounded, color: Colors.black)
                                            ])),
                                        onSelected: (result) {},
                                        itemBuilder: (BuildContext context) {
                                          return _shortageTypes.map((String value) {
                                            return PopupMenuItem<String>(
                                                value: value,
                                                onTap: () {
                                                  setState(() {
                                                    cpr.shortageType = value;
                                                  });
                                                },
                                                child: Text(value));
                                          }).toList();
                                        })),
                              ),
                              ListTile(
                                dense: true,
                                title: Text("CPR Type", style: titleTheme),
                                isThreeLine: true,
                                // subtitle: Padding(
                                //     padding: const EdgeInsets.only(left: 8.0),
                                //     child: DropdownButtonHideUnderline(
                                //         child: Container(
                                //             padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                //             decoration: BoxDecoration(
                                //                 border: Border.all(color: Colors.grey.shade400, width: 1, style: BorderStyle.solid), borderRadius: BorderRadius.circular(4)),
                                //             child: DropdownButton<String>(
                                //                 hint: const Text("Select CPR Type"),
                                //                 value: cpr.cprType,
                                //                 icon: const Icon(Icons.arrow_downward),
                                //                 elevation: 16,
                                //                 style: const TextStyle(color: Colors.deepPurple),
                                //                 onChanged: (String? newValue) {
                                //                   setState(() {
                                //                     cpr.cprType = newValue!;
                                //                   });
                                //                 },
                                //                 items: _cprTypes.map<DropdownMenuItem<String>>((String value) {
                                //                   return DropdownMenuItem<String>(
                                //                     value: value,
                                //                     child: Padding(
                                //                       padding: const EdgeInsets.only(left: 8.0),
                                //                       child: Text(value),
                                //                     ),
                                //                   );
                                //                 }).toList()))))
                                subtitle: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: PopupMenuButton<String>(
                                        offset: const Offset(0, 30),
                                        padding: const EdgeInsets.all(16.0),
                                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                                        child: Chip(
                                            avatar: const Icon(Icons.local_mall_rounded, color: Colors.black),
                                            label: Row(children: [
                                              Text(cpr.cprType ?? 'Select Cpr type'),
                                              const Spacer(),
                                              const Icon(Icons.arrow_drop_down_rounded, color: Colors.black)
                                            ])),
                                        onSelected: (result) {},
                                        itemBuilder: (BuildContext context) {
                                          return _cprTypes.map((String value) {
                                            return PopupMenuItem<String>(
                                                value: value,
                                                onTap: () {
                                                  setState(() {
                                                    cpr.cprType = value;
                                                  });
                                                },
                                                child: Text(value));
                                          }).toList();
                                        })),
                              ),
                              // if (cpr.ticket!.production == null)
                              //   ListTile(
                              //     title: Text("Client", style: titleTheme),
                              //     subtitle: SizedBox(
                              //       width: 200,
                              //       child: Padding(
                              //           padding: const EdgeInsets.all(16.0),
                              //           child: DropdownSearch<String>(
                              //               selectedItem: cpr.client,
                              //               // mode: Mode.BOTTOM_SHEET,
                              //               // showSelectedItem: true,
                              //               items: const ["Upwind", "OD", "Nylon", "OEM"],
                              //               dropdownDecoratorProps: const DropDownDecoratorProps(dropdownSearchDecoration: InputDecoration(hintText: "Select Client")),
                              //               onChanged: (c) {
                              //                 cpr.client = c;
                              //               })),
                              //     ),
                              //   ),
                              // Padding(
                              //   padding: const EdgeInsets.only(left: 12.0),
                              //   child: Text("Suppliers", style: titleTheme),
                              // ),
                              ListTile(dense: false, title: Text("Suppliers", style: titleTheme), subtitle: getSuppliers()),
                              ListTile(
                                  title: Text("Comment", style: titleTheme),
                                  subtitle: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextFormField(
                                          initialValue: cpr.comment,
                                          onChanged: (value) {
                                            cpr.comment = value;
                                          },
                                          maxLines: 4,
                                          decoration: const InputDecoration(contentPadding: EdgeInsets.all(16.0), hintText: "Enter your comment here")))),
                              ListTile(
                                  title: Text("Image URL", style: titleTheme),
                                  subtitle: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextFormField(
                                          initialValue: cpr.image,
                                          onChanged: (value) {
                                            cpr.image = value;
                                          },
                                          maxLines: 3,
                                          decoration: const InputDecoration(contentPadding: EdgeInsets.all(16.0), hintText: "Enter your url here"))))
                            ])),
                      ),
                    )),
              ),
              Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Text("Materials"),
                      const Spacer(),
                      TextButton(
                          onPressed: () async {
                            List? items = await const DropMaterialList().show(context);
                            if (items != null) {
                              for (var element in items) {
                                _addMaterialToList(element);
                              }
                              setState(() {});
                            }
                          },
                          child: const Text("Add from csv")),
                      TextButton(
                          onPressed: () async {
                            List? items = await const PastMaterialRow().show(context);
                            if (items != null) {
                              for (var element in items) {
                                _addMaterialToList(element);
                              }
                              setState(() {});
                            }
                          },
                          child: const Text("Past row from excel"))
                    ],
                  ),
                ),
                SizedBox(
                  height: 80,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(children: [
                        Flexible(
                            child: SearchField(
                          controller: textEditingController,
                          onSubmit: (v) {
                            currentMaterial.item = v;
                          },
                          suggestions: _matList.map((e) => SearchFieldListItem(e)).toList(),
                          suggestionState: Suggestion.expand,
                          textInputAction: TextInputAction.next,
                          hint: 'Material',
                          hasOverlay: true,
                          searchStyle: TextStyle(fontSize: 15, color: Colors.black.withOpacity(0.8)),
                          searchInputDecoration: InputDecoration(
                              isDense: true,
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black.withOpacity(0.8))),
                              border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red))),
                          maxSuggestionsInViewPort: 6,
                          // itemHeight: 36,
                          onSuggestionTap: (v) {
                            currentMaterial.item = v.searchKey;
                            setState(() {});
                          },
                        )),
                        const SizedBox(width: 8),
                        SizedBox(
                            width: 100,
                            child: TextField(
                                controller: _qtyController,
                                decoration: const InputDecoration(isDense: true, border: OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)), labelText: 'QTY'),
                                onChanged: (text) {
                                  currentMaterial.qty = (text);
                                  setState(() {});
                                })),
                        const SizedBox(width: 8),
                        Card(
                            child: IconButton(
                                color: Colors.blue,
                                onPressed: (textEditingController.text.isEmpty || currentMaterial.qty.isEmpty)
                                    ? null
                                    : () {
                                        currentMaterial.item = textEditingController.text;
                                        _addMaterialToList(currentMaterial);
                                        currentMaterial = CprItem();
                                        _qtyController.clear();
                                        textEditingController.clear();
                                        setState(() {});
                                      },
                                icon: const Icon(Icons.add_rounded)))
                      ]),
                    ),
                  ),
                ),
                getOptions(_selectedItems),
                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 64.0),
                  child: SizedBox(
                      width: double.infinity,
                      child: Card(
                        elevation: 4,
                        child: DataTable2(
                          showCheckboxColumn: false,
                          checkboxHorizontalMargin: 12,
                          columns: const [
                            DataColumn2(label: Text('Item', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), size: ColumnSize.L),
                            DataColumn2(label: Text('Qty', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), size: ColumnSize.L),
                            // DataColumn2(label: Text('Supplier', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), size: ColumnSize.S),
                          ],
                          rows: cpr.items
                              .map<DataRow>((item) => DataRow2(
                                      color: MaterialStateColor.resolveWith((states) => item.selected ? Colors.orange.shade100 : Colors.white),
                                      onSelectChanged: (s) {
                                        item.selected = s!;
                                        setState(() {});
                                      },
                                      selected: item.selected,
                                      cells: [
                                        DataCell(Text(item.item)),
                                        DataCell(Text(item.qty)),
                                        // DataCell(DropdownButtonHideUnderline(
                                        //     child: Container(
                                        //         padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                        //         child: DropdownButton<String>(
                                        //             hint: const Text("Supplier"),
                                        //             icon: const Icon(Icons.arrow_downward, size: 12),
                                        //             value: item.supplier,
                                        //             style: const TextStyle(color: Colors.deepPurple),
                                        //             onChanged: (String? newValue) {
                                        //               setState(() {
                                        //                 item.supplier = newValue;
                                        //               });
                                        //             },
                                        //             items: cpr.suppliers.map<DropdownMenuItem<String>>((String value) {
                                        //               return DropdownMenuItem<String>(value: value, child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Text(value)));
                                        //             }).toList()))))
                                      ]))
                              .toList(),
                        ),
                      )),
                )),
              ]))
            ]),
            if (saving) Container(color: Colors.white, child: const Center(child: CircularProgressIndicator())),
          ],
        ),
        floatingActionButton: saving
            ? null
            : FloatingActionButton.small(
                child: const Icon(Icons.save_rounded),
                onPressed: () async {
                  save();
                }));
  }

  FocusNode focusNode = FocusNode();

  List<CprItem> get selectedItems => cpr.items.where((element) => element.selected).toList();
  late DropzoneViewController controller1;
  bool highlighted1 = false;

  void _addMaterialToList(CprItem currentMaterial) {
    print(currentMaterial.toJson());
    // int x = cpr.items.indexWhere((element) => element.item == currentMaterial.item && element.supplier == currentMaterial.supplier);
    // cpr.items.removeWhere((element) => element.item == currentMaterial.item && element.supplier == currentMaterial.supplier);

    int x = cpr.items.indexWhere((element) => element.item == currentMaterial.item);
    cpr.items.removeWhere((element) => element.item == currentMaterial.item);

    // if (x.isEmpty) {
    cpr.items.insert(x == -1 ? 0 : x, CprItem.fromJson(currentMaterial.toJson()));
    // } else {
    //   x[0].qty = "${(double.parse("${x[0].qty.split(' ')[0]}") + double.parse(currentMaterial.qty.split(' ')[0]))} ${x[0].qty.split(' ')[1]}";
    // }
  }

  getUi() {}

  String? _supplier1;
  String? _supplier2;
  String? _supplier3;

  getSuppliers() {
    _supplier2 = _supplier1 == _supplier2 ? null : _supplier2;
    _supplier3 = _supplier2 == _supplier3 ? null : _supplier3;

    cpr.suppliers.removeWhere((value) => value == 'None');
    cpr.suppliers = cpr.suppliers.toSet().toList();
    print(cpr.suppliers);

    List<String> __suppliers = List.from(_suppliers);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: PopupMenuButton<String>(
                offset: const Offset(0, 30),
                padding: const EdgeInsets.all(16.0),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                child: Chip(
                    avatar: const Icon(Icons.airport_shuttle, color: Colors.black),
                    label: Row(children: [
                      Text(cpr.suppliers.isNotEmpty ? cpr.suppliers[0] : 'Select Supplier'),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down_rounded, color: Colors.black)
                    ])),
                onSelected: (result) {},
                itemBuilder: (BuildContext context) {
                  return __suppliers.map((String value) {
                    return PopupMenuItem<String>(
                        value: value,
                        onTap: () {
                          try {
                            cpr.suppliers.removeAt(0);
                          } catch (e) {}
                          setState(() {
                            cpr.suppliers.insert(0, value);
                            print(cpr.suppliers);
                          });
                        },
                        child: Text(value));
                  }).toList();
                })),
        // ListTile(
        //     title: Padding(
        //         padding: const EdgeInsets.only(left: 8.0),
        //         child: DropdownButtonHideUnderline(
        //             child: Container(
        //                 padding: const EdgeInsets.symmetric(horizontal: 10.0),
        //                 decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400, width: 1, style: BorderStyle.solid), borderRadius: BorderRadius.circular(4)),
        //                 child: DropdownButton<String>(
        //                     hint: const Text("Select Supplier"),
        //                     value: cpr.suppliers.isNotEmpty ? cpr.suppliers[0] : null,
        //                     icon: const Icon(Icons.arrow_downward),
        //                     elevation: 16,
        //                     style: const TextStyle(color: Colors.deepPurple),
        //                     onChanged: (String? newValue) {
        //                       setState(() {
        //                         if (newValue != null) {
        //                           try {
        //                             cpr.suppliers.removeAt(0);
        //                           } catch (e) {}
        //                           cpr.suppliers.insert(0, newValue);
        //                           print(cpr.suppliers);
        //                         }
        //                       });
        //                     },
        //                     items: __suppliers.map<DropdownMenuItem<String>>((String value) {
        //                       return DropdownMenuItem<String>(value: value, child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Text(value)));
        //                     }).toList()))))),
        if (cpr.suppliers.isNotEmpty)
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: PopupMenuButton<String>(
                  offset: const Offset(0, 30),
                  padding: const EdgeInsets.all(16.0),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                  child: Chip(
                      avatar: const Icon(Icons.factory, color: Colors.black),
                      label: Row(children: [
                        Text(cpr.suppliers.length > 1 ? cpr.suppliers[1] : 'Select Supplier'),
                        const Spacer(),
                        const Icon(Icons.arrow_drop_down_rounded, color: Colors.black)
                      ])),
                  onSelected: (result) {},
                  itemBuilder: (BuildContext context) {
                    return __suppliers.map((String value) {
                      return PopupMenuItem<String>(
                          value: value,
                          onTap: () {
                            setState(() {
                              try {
                                cpr.suppliers.removeAt(1);
                              } catch (e) {}
                              cpr.suppliers.insert(1, value);
                              print(cpr.suppliers);
                            });
                          },
                          child: Text(value));
                    }).toList();
                  })),
        // ListTile(
        //     title: Padding(
        //         padding: const EdgeInsets.only(left: 8.0),
        //         child: DropdownButtonHideUnderline(
        //             child: Container(
        //                 padding: const EdgeInsets.symmetric(horizontal: 10.0),
        //                 decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400, width: 1, style: BorderStyle.solid), borderRadius: BorderRadius.circular(4)),
        //                 child: DropdownButton<String>(
        //                     hint: const Text("Select Supplier"),
        //                     value: cpr.suppliers.length > 1 ? cpr.suppliers[1] : null,
        //                     icon: const Icon(Icons.arrow_downward),
        //                     elevation: 16,
        //                     style: const TextStyle(color: Colors.deepPurple),
        //                     onChanged: (String? newValue) {
        //                       setState(() {
        //                         if (newValue != null) {
        //                           try {
        //                             cpr.suppliers.removeAt(1);
        //                           } catch (e) {}
        //                           cpr.suppliers.insert(1, newValue);
        //                           print(cpr.suppliers);
        //                         }
        //                       });
        //                     },
        //                     items: __suppliers.map<DropdownMenuItem<String>>((String value) {
        //                       return DropdownMenuItem<String>(value: value, child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Text(value)));
        //                     }).toList()))))),
        if (cpr.suppliers.length > 1)
          // ListTile(
          //     title: Padding(
          //         padding: const EdgeInsets.only(left: 8.0),
          //         child: DropdownButtonHideUnderline(
          //             child: Container(
          //                 padding: const EdgeInsets.symmetric(horizontal: 10.0),
          //                 decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400, width: 1, style: BorderStyle.solid), borderRadius: BorderRadius.circular(4)),
          //                 child: DropdownButton<String>(
          //                     hint: const Text("Select Supplier"),
          //                     value: cpr.suppliers.length > 2 ? cpr.suppliers[2] : null,
          //                     icon: const Icon(Icons.arrow_downward),
          //                     elevation: 16,
          //                     style: const TextStyle(color: Colors.deepPurple),
          //                     onChanged: (String? newValue) {
          //                       setState(() {
          //                         if (newValue != null) {
          //                           try {
          //                             cpr.suppliers.removeAt(2);
          //                           } catch (e) {}
          //                           cpr.suppliers.insert(2, newValue);
          //                         }
          //                       });
          //                     },
          //                     items: __suppliers.map<DropdownMenuItem<String>>((String value) {
          //                       return DropdownMenuItem<String>(value: value, child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Text(value)));
          //                     }).toList()))))),

          Padding(
              padding: const EdgeInsets.all(8.0),
              child: PopupMenuButton<String>(
                  offset: const Offset(0, 30),
                  padding: const EdgeInsets.all(16.0),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                  child: Chip(
                      avatar: const Icon(Icons.factory, color: Colors.black),
                      label: Row(children: [
                        Text(cpr.suppliers.length > 2 ? cpr.suppliers[2] : 'Select Supplier'),
                        const Spacer(),
                        const Icon(Icons.arrow_drop_down_rounded, color: Colors.black)
                      ])),
                  onSelected: (result) {},
                  itemBuilder: (BuildContext context) {
                    return __suppliers.map((String value) {
                      return PopupMenuItem<String>(
                          value: value,
                          onTap: () {
                            setState(() {
                              try {
                                cpr.suppliers.removeAt(2);
                              } catch (e) {}
                              cpr.suppliers.insert(2, value);
                            });
                          },
                          child: Text(value));
                    }).toList();
                  })),
      ],
    );
  }

  Future getAllMaterials() {
    return Api.get("materialManagement/cpr/getAllMaterials", {}).then((res) {
      Map data = res.data;
      _matList = List.from(data['materials']).map((e) => "${e["name"]}").toList();
    }).whenComplete(() {
      setState(() {});
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err.toString()),
          action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                getAllMaterials();
              })));
      setState(() {
        // _dataLoadingError = true;
      });
    });
  }

  String errMsg = '';

  save() {
    if (cpr.client == null) {
      errMsg = 'select client ';
    } else if (cpr.sailType == null) {
      errMsg = 'select sail type ';
    } else if (cpr.shortageType == null) {
      errMsg = 'select shortageType   ';
    } else if (cpr.cprType == null) {
      errMsg = 'select cprType ';
    } else if (cpr.suppliers.isEmpty) {
      errMsg = 'select suppliers ';
    }
    // else if (cpr.items.where((element) => element.supplier == null).isNotEmpty) {
    //   err_msg = 'check materials';
    // }
    else {
      setState(() {
        saving = true;
      });
      Api.post(EndPoints.materialManagement_cpr_saveCpr, {'cpr': cpr}).then((res) {
        Map s = res.data;
        print(s);
        Navigator.pop(context, true);
      }).whenComplete(() {
        setState(() {});
      }).catchError((err) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(err.toString()),
            action: SnackBarAction(
                label: 'Retry',
                onPressed: () {
                  save();
                })));
        setState(() {
          // _dataLoadingError = true;
        });
      });
    }
    print(errMsg);
    if (errMsg.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errMsg, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
    }
    setState(() {});
  }

  getOptions(List _selectedItems) {
    return AbsorbPointer(
      absorbing: _selectedItems.isEmpty,
      child: Opacity(
        opacity: _selectedItems.isEmpty ? 0.5 : 1,
        child: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Row(children: [
            (_selectedItems.length == cpr.items.length)
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        for (var element in cpr.items) {
                          element.selected = false;
                        }
                      });
                    },
                    icon: const Icon(Icons.check_box, size: 16))
                : IconButton(
                    onPressed: () {
                      setState(() {
                        for (var element in cpr.items) {
                          element.selected = true;
                        }
                      });
                    },
                    icon: const Icon(Icons.check_box_outlined, size: 16)),
            Text("${_selectedItems.length}/${cpr.items.length}"),
            if (_selectedItems.length == 1)
              IconButton(
                  onPressed: () {
                    setState(() {
                      currentMaterial = _selectedItems[0];
                      textEditingController.value = TextEditingValue(text: currentMaterial.item);
                      _qtyController.value = TextEditingValue(text: currentMaterial.qty);
                    });
                  },
                  icon: const Icon(Icons.edit, size: 16)),
            IconButton(
                onPressed: () {
                  for (var x in selectedItems) {
                    print(x.toJson());
                    cpr.items.removeWhere((e) => e.item == x.item && e.qty == x.qty);
                  }
                  setState(() {});
                },
                icon: const Icon(Icons.delete_rounded, size: 16)),
            const Spacer(),
            // DropdownButton<String>(
            //     hint: const Text("Supplier"),
            //     icon: const Icon(Icons.arrow_downward, size: 12),
            //     value: _selectedItems.isEmpty ? null : _selectedItems[0].supplier,
            //     style: const TextStyle(color: Colors.deepPurple),
            //     onChanged: (String? newValue) {
            //       setState(() {
            //         if (newValue != null) {
            //           selectedItems.forEach((element) {
            //             element.supplier = newValue;
            //           });
            //         }
            //       });
            //     },
            //     items: cpr.suppliers.map<DropdownMenuItem<String>>((String value) {
            //       return DropdownMenuItem<String>(value: value, child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Text(value)));
            //     }).toList())
          ]),
        ),
      ),
    );
  }
}
