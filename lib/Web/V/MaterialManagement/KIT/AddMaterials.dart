import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:searchfield/searchfield.dart';
import 'package:smartwind/M/CPR/CprItem.dart';
import 'package:smartwind/M/EndPoints.dart';
import 'package:smartwind/Web/Widgets/DialogView.dart';
import 'package:smartwind/Web/Widgets/IfWeb.dart';

import '../../../../C/Api.dart';
import '../../../../M/CPR/KIT.dart';
import '../../../../M/CPR/KitItem.dart';
import '../CPR/PastMaterialRow.dart';
import '../DropMaterialList.dart';

class AddMaterials extends StatefulWidget {
  final int kitId;

  const AddMaterials(this.kitId, {Key? key}) : super(key: key);

  @override
  State<AddMaterials> createState() => _AddMaterialsState();

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _AddMaterialsState extends State<AddMaterials> {
  var textEditingController = TextEditingController();
  KitItem currentMaterial = KitItem();
  late List<String> _matList = [];
  final _qtyController = TextEditingController();

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
    return IfWeb(elseIf: getUi(), child: DialogView(width: 500, child: getWebUi()));
  }

  getWebUi() {
    List<KitItem> _selectedItems = List.from(selectedItems);
    return Scaffold(
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              save();
            },
            child: const Icon(Icons.save_rounded)),
        appBar: AppBar(title: const Text('Add Materials')),
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
                      child: SearchField(
                          controller: textEditingController,
                          onSubmit: (v) {
                            currentMaterial.item = v;
                            setState(() {});
                          },
                          suggestions: _matList.map((e) => SearchFieldListItem(e)).toList(),
                          suggestionState: Suggestion.expand,
                          textInputAction: TextInputAction.next,
                          hint: 'Material',
                          hasOverlay: true,
                          searchStyle: TextStyle(fontSize: 15, color: Colors.black.withOpacity(0.8)),
                          searchInputDecoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black.withOpacity(0.8))),
                              border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red))),
                          maxSuggestionsInViewPort: 6,
                          itemHeight: 36,
                          onSuggestionTap: (v) {
                            currentMaterial.item = v.searchKey;
                            setState(() {});
                          })),
                  const SizedBox(width: 8),
                  SizedBox(
                      width: 100,
                      child: TextField(
                          controller: _qtyController,
                          decoration: const InputDecoration(border: OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)), labelText: 'QTY'),
                          onChanged: (text) {
                            currentMaterial.qty = (text);
                            setState(() {});
                          })),
                  const SizedBox(width: 8),
                  Card(
                      child: IconButton(
                          color: Colors.blue,
                          onPressed: (textEditingController.text.isEmpty || _qtyController.text.isEmpty)
                              ? null
                              : () {
                                  currentMaterial.item = textEditingController.text;
                                  _addMaterialToList(currentMaterial);
                                  currentMaterial = KitItem();
                                  _qtyController.clear();
                                  textEditingController.clear();
                                  setState(() {});
                                },
                          icon: const Icon(Icons.add_rounded)))
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

  getOptions(List _selectedItems) {
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
      Navigator.pop(context, true);
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
    // }
    print(errMsg);
  }
}
