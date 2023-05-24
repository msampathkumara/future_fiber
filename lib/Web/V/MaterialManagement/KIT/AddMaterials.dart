import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smartwind_future_fibers/M/CPR/CprItem.dart';
import 'package:smartwind_future_fibers/M/EndPoints.dart';
import 'package:smartwind_future_fibers/Web/Widgets/DialogView.dart';
import 'package:deebugee_plugin/DialogView.dart';
import 'package:smartwind_future_fibers/Web/Widgets/IfWeb.dart';

import '../../../../C/Api.dart';
import '../../../../M/CPR/KIT.dart';
import '../../../../M/CPR/KitItem.dart';
import '../CPR/PastMaterialRow.dart';
import '../DropMaterialList.dart';

class AddMaterials extends StatefulWidget {
  final int kitId;
  late BuildContext parentContext;

  AddMaterials(this.kitId, {Key? key}) : super(key: key);

  @override
  State<AddMaterials> createState() => _AddMaterialsState();

  Future show(context) {
    parentContext = context;
    return kIsWeb
        ? showDialog(context: context, builder: (_) => MaterialApp(home: this, theme: Theme.of(context)))
        : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _AddMaterialsState extends State<AddMaterials> {
  var textEditingController = TextEditingController();
  KitItem currentMaterial = KitItem();
  late List<String> _matList = [];
  final _qtyController = TextEditingController();

  FocusNode currentMaterialFocusNode = FocusNode();
  FocusNode qtyFocusNode = FocusNode();

  List<KitItem> get selectedItems => kit.items.where((element) => element.selected).toList();

  @override
  void initState() {
    kit.id = widget.kitId;
    getAllMaterials();
    super.initState();
  }

  Future getAllMaterials() {
    return Api.get(EndPoints.materialManagement_cpr_getAllMaterials, {}).then((res) {
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

  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getUi(), child: DialogView(width: 600, child: getWebUi()));
  }

  Scaffold getWebUi() {
    List<KitItem> _selectedItems = List.from(selectedItems);
    return Scaffold(
        floatingActionButton: FloatingActionButton(onPressed: () => {save()}, child: const Icon(Icons.save_rounded)),
        appBar: AppBar(title: const Text('Add Materials'), actions: [
          IconButton(onPressed: () => {Navigator.pop(widget.parentContext, false)}, icon: const Icon(Icons.close))
        ]),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Spacer(),
                    TextButton(
                        onPressed: () async {
                          List<CprItem>? items = await const DropMaterialList().show(context);
                          if (items != null) {
                            for (var element in items) {
                              _addMaterialToList(KitItem.fromJson(element.toJson()));
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
                              _addMaterialToList(KitItem.fromJson(element.toJson()));
                            }
                            setState(() {});
                          }
                        },
                        child: const Text("Past row from excel"))
                  ],
                ),
              ),
              Card(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(children: [
                  Flexible(
                      child: Autocomplete<String>(
                          fieldViewBuilder: (BuildContext context, TextEditingController textEditingController_, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                            textEditingController = textEditingController_;
                            currentMaterialFocusNode = focusNode;
                            return TextFormField(
                                controller: textEditingController,
                                focusNode: focusNode,
                                onFieldSubmitted: (String value) {
                                  onFieldSubmitted();
                                  print('You just typed a new entry  $value');
                                },
                                decoration: getTextFieldDecoration(hint: "Material"));
                          },
                          displayStringForOption: (s) => s,
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text == '') {
                              // return const Iterable<String>.empty();
                              return _matList;
                            }
                            return [textEditingValue.text, ..._matList].where((option) {
                              return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                            });
                          },
                          onSelected: (selection) {
                            debugPrint('You just selected $selection');
                            currentMaterial.item = selection;
                            FocusScope.of(context).requestFocus(qtyFocusNode);
                          },
                          optionsViewBuilder: (context, onSelected, options) => Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  elevation: 4.0,
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(4.0))),
                                  child: SizedBox(
                                    height: 52.0 * options.length,
                                    width: 350, // <-- Right here !
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      itemCount: options.length,
                                      shrinkWrap: false,
                                      itemBuilder: (BuildContext context, int index) {
                                        final option = options.elementAt(index);
                                        return InkWell(
                                          onTap: () => {onSelected(option)},
                                          child: Builder(builder: (BuildContext context) {
                                            final bool highlight = AutocompleteHighlightedOption.of(context) == index;
                                            if (highlight) {
                                              SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) => {Scrollable.ensureVisible(context, alignment: 0.5)});
                                            }
                                            return Container(color: highlight ? Theme.of(context).focusColor : null, padding: const EdgeInsets.all(16.0), child: Text((option)));
                                          }),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                          optionsMaxHeight: 200)),
                  const SizedBox(width: 8),
                  SizedBox(
                      width: 100,
                      child: TextField(
                          decoration: getTextFieldDecoration(hint: "QTY"),
                          focusNode: qtyFocusNode,
                          controller: _qtyController,
                          // decoration: const InputDecoration(border: OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)), labelText: 'QTY'),
                          onChanged: (text) {
                            currentMaterial.qty = (text);

                            setState(() {});
                          },
                          onSubmitted: (q) => {saveMaterial(context)})),
                  const SizedBox(width: 8)
                  // Card(
                  //     child: IconButton(
                  //         color: Colors.blue,
                  //         onPressed: (textEditingController.text.isEmpty || _qtyController.text.isEmpty)
                  //             ? null
                  //             : () {
                  //                 saveMaterial();
                  //               },
                  //         icon: const Icon(Icons.add_rounded)))
                ]),
              )),
              getOptions(_selectedItems),
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: SizedBox(
                          width: double.infinity,
                          child: Card(
                              elevation: 4,
                              child: DataTable2(
                                  showCheckboxColumn: false,
                                  checkboxHorizontalMargin: 12,
                                  columns: const [
                                    DataColumn2(label: Text('Item', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), size: ColumnSize.L),
                                    DataColumn2(label: Text('Qty', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), size: ColumnSize.L)
                                  ],
                                  rows: kit.items
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
                                              ]))
                                      .toList())))))
            ])));
  }

  getUi() {}
  KIT kit = KIT();

  void _addMaterialToList(KitItem currentMaterial) {
    int x = kit.items.indexWhere((element) => element.item == currentMaterial.item);
    kit.items.removeWhere((element) => element.item == currentMaterial.item);
    kit.items.insert(x == -1 ? 0 : x, KitItem.fromJson(currentMaterial.toJson()));
  }

  AbsorbPointer getOptions(List _selectedItems) {
    return AbsorbPointer(
      absorbing: _selectedItems.isEmpty,
      child: Opacity(
        opacity: _selectedItems.isEmpty ? 0.5 : 1,
        child: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Row(children: [
            (_selectedItems.length == kit.items.length)
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        for (var element in kit.items) {
                          element.selected = false;
                        }
                      });
                    },
                    icon: const Icon(Icons.check_box, size: 16))
                : IconButton(
                    onPressed: () {
                      setState(() {
                        for (var element in kit.items) {
                          element.selected = true;
                        }
                      });
                    },
                    icon: const Icon(Icons.check_box_outlined, size: 16)),
            Text("${_selectedItems.length}/${kit.items.length}"),
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
                    kit.items.removeWhere((e) => e.item == x.item && e.qty == x.qty);
                  }
                  setState(() {});
                },
                icon: const Icon(Icons.delete_rounded, size: 16)),
            const Spacer(),
          ]),
        ),
      ),
    );
  }

  late String errMsg = "";

  save() {
    print(kit.toJson());

    // if (kit.items.where((element) => element.supplier == null).isEmpty) {
    //   err_msg = 'items';
    // } else {
    Api.post(EndPoints.materialManagement_kit_saveKitMaterials, {'kit': kit}).then((res) {
      Navigator.pop(widget.parentContext, true);
    }).whenComplete(() {
      setState(() {});
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.toString()), action: SnackBarAction(label: 'Retry', onPressed: () => {getAllMaterials()})));
      setState(() {
        // _dataLoadingError = true;
      });
    });
    // }
    print(errMsg);
  }

  void saveMaterial(context) {
    if (textEditingController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.red, content: Text("Enter Material", style: TextStyle(color: Colors.white))));
      return;
    }
    if (_qtyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.red, content: Text("Enter Qty", style: TextStyle(color: Colors.white))));
      return;
    }

    KitItem item = KitItem.fromJson(currentMaterial.toJson());

    // Api.post(EndPoints.materialManagement_kit_saveKitMaterials, {'kit': kit}).then((res) {
    //   item.saved = true;
    //   setState(() {});
    // }).whenComplete(() {
    //   setState(() {});
    // }).catchError((err) {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.toString()), action: SnackBarAction(label: 'Retry', onPressed: () => {getAllMaterials()})));
    //   setState(() {
    //     // _dataLoadingError = true;
    //   });
    // });

    _addMaterialToList(item);
    currentMaterial = KitItem();
    _qtyController.clear();
    textEditingController.clear();
    setState(() {});
  }
}

InputDecoration getTextFieldDecoration({hint = ''}) {
  return InputDecoration(
    border: InputBorder.none,
    hintText: hint,
    filled: true,
    // fillColor: Colors.grey.shade300,
    contentPadding: const EdgeInsets.only(left: 14.0, bottom: 6.0, top: 8.0),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.red),
      borderRadius: BorderRadius.circular(4.0),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: const BorderSide(color: Colors.grey),
      borderRadius: BorderRadius.circular(4.0),
    ),
  );
}
