import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/C/Api.dart';
import 'package:smartwind/M/CPR/KIT.dart';
import 'package:smartwind/M/CPR/KitItem.dart';
import 'package:smartwind/M/Chat/message.dart';
import 'package:smartwind/M/Enums.dart';
import 'package:smartwind/V/Widgets/UserImage.dart';
import 'package:smartwind/Web/V/MaterialManagement/KIT/AddMaterials.dart';
import 'package:smartwind/Web/Widgets/DialogView.dart';
import 'package:smartwind/Web/Widgets/IfWeb.dart';
import 'package:smartwind/Web/Widgets/chatBubble.dart';

import '../../../../M/NsUser.dart';
import '../../../../V/Home/Tickets/StandardFiles/factory_selector.dart';

class KitView extends StatefulWidget {
  final KIT kit;

  final Function(bool) isKitChange;

  const KitView(this.kit, this.isKitChange, {Key? key}) : super(key: key);

  @override
  State<KitView> createState() => _KitViewState();

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _KitViewState extends State<KitView> {
  var titleTheme = const TextStyle(fontSize: 12, color: Colors.grey);
  var valTheme = const TextStyle(fontSize: 15, color: Colors.black);
  var vd = const VisualDensity(horizontal: 0, vertical: -4);
  var st = const TextStyle(fontSize: 12, color: Colors.black);

  late KIT _kit;

  late List<KIT> kits;

  List<Message> kitComments = [];

  @override
  void initState() {
    _kit = widget.kit;
    kits = [_kit, _kit, _kit];
    apiGetData();
    getComments();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getWebUi(), child: DialogView(width: 1200, child: getWebUi()));
  }

  bool _loading = true;

  getWebUi() {
    return Scaffold(
      appBar: AppBar(title: const Text("View KIT")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Row(children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Table(
                          children: [
                            TableRow(children: [
                              ListTile(
                                  visualDensity: vd,
                                  title: Text('Ticket', style: titleTheme),
                                  subtitle: Wrap(direction: Axis.vertical, children: [
                                    Text('${_kit.ticket?.mo}', style: valTheme),
                                    Text('${_kit.ticket?.oe}', style: const TextStyle(fontSize: 12, color: Colors.deepOrange))
                                  ])),
                              ListTile(
                                  onTap: () {
                                    FactorySelector(_kit.client, title: "Select Client", onSelect: (prod) {
                                      print(prod);
                                      updateProduction(prod);
                                    }).show(context);
                                  },
                                  visualDensity: vd,
                                  title: Text('Client', style: titleTheme),
                                  subtitle: Text('${_kit.client}', style: valTheme)),
                              ListTile(visualDensity: vd, title: Text('Shortage Type', style: titleTheme), subtitle: Text('${_kit.shortageType}', style: valTheme)),
                              ListTile(visualDensity: vd, title: Text('Status', style: titleTheme), subtitle: Text('${_kit.status} ', style: valTheme)),
                            ]),
                          ],
                        ),
                        Expanded(
                          child: Card(
                            elevation: 4,
                            child: Column(children: [
                              if (_kit.items.isEmpty)
                                Expanded(
                                    child: Center(
                                        child: Wrap(
                                  direction: Axis.vertical,
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    const Text(
                                      "No Materials",
                                      textScaleFactor: 1.5,
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    if (kIsWeb)
                                      TextButton(
                                          onPressed: () async {
                                            await AddMaterials(_kit.id).show(context);
                                          },
                                          child: const Text("Add Materials"))
                                  ],
                                ))),
                              if (_kit.items.isNotEmpty)
                                Expanded(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: DataTable2(smRatio: 0.2, columns: const [
                                      DataColumn2(label: Text(''), size: ColumnSize.S),
                                      DataColumn2(label: Text('Item'), size: ColumnSize.L),
                                      DataColumn2(label: Text('Qty'), size: ColumnSize.M),
                                      DataColumn2(label: Text('Date'), size: ColumnSize.M),
                                      DataColumn2(label: Text('User'), size: ColumnSize.L)
                                    ], rows: [
                                      for (var material in _kit.items) getMatRow(material),
                                      DataRow2(cells: [
                                        DataCell.empty,
                                        DataCell.empty,
                                        DataCell.empty,
                                        DataCell.empty,
                                        DataCell(TextButton(
                                            onPressed: () async {
                                              await AddMaterials(_kit.id).show(context) == true ? apiGetData() : null;
                                            },
                                            child: const Text("Add Materials")))
                                      ])
                                    ]),
                                  ),
                                ),
                              const Divider(color: Colors.red),
                              Table(
                                children: [
                                  TableRow(
                                    children: [
                                      _kit.user != null
                                          ? ListTile(
                                              visualDensity: vd,
                                              title: Text("Added By ", style: titleTheme),
                                              subtitle: ListTile(
                                                  leading: UserImage(nsUser: NsUser.fromId(_kit.user!.id), radius: 16),
                                                  title: Text(_kit.user!.uname, style: valTheme),
                                                  subtitle: Text(_kit.addedOn, style: const TextStyle(fontSize: 12, color: Colors.black))))
                                          : Container(),
                                      (_kit.sentUserId != null)
                                          ? ListTile(
                                              visualDensity: vd,
                                              title: Text("Sent By ", style: titleTheme),
                                              subtitle: ListTile(
                                                  leading: UserImage(nsUser: NsUser.fromId(_kit.sentUser!.id), radius: 16),
                                                  title: Text(_kit.sentUser!.uname, style: valTheme),
                                                  subtitle: Text(_kit.sentOn ?? "", style: const TextStyle(fontSize: 12, color: Colors.black))))
                                          : Container(),
                                      if (_kit.status.isReady(caseInsensitive: true, trim: true))
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Spacer(),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: SizedBox(
                                                  width: 100,
                                                  child: ElevatedButton(
                                                      onPressed: () {
                                                        sendKit();
                                                      },
                                                      child: const Text("Send"))),
                                            ),
                                          ],
                                        )
                                    ],
                                  )
                                ],
                              ),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (kIsWeb)
                SizedBox(
                    width: 395,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 4,
                        child: Column(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListView.builder(
                                    itemCount: kitComments.length,
                                    itemBuilder: (context, index) {
                                      Message msg = kitComments[index];
                                      return ChatBubble(msg, isSelf: msg.isSelf);
                                    }),
                              ),
                            ),
                            ListTile(
                              title: TextFormField(
                                  controller: commentController,
                                  onFieldSubmitted: (r) {
                                    saveComment();
                                  }),
                              trailing: IconButton(
                                  onPressed: () {
                                    saveComment();
                                  },
                                  icon: const Icon(
                                    Icons.send,
                                    color: Colors.green,
                                    size: 24,
                                  )),
                            )
                          ],
                        ),
                      ),
                    ))
            ]),
      // floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      // floatingActionButton: getButton()
    );
  }

  Future apiGetData() {
    return Api.get("materialManagement/kit/getKit", {'id': _kit.id}).then((res) {
      Map data = res.data;

      _kit = KIT.fromJson(res.data);
      var _kit1 = KIT.fromJson(res.data);

      var _kit2 = KIT.fromJson(res.data);

      kits = [_kit, _kit1, _kit2];

      print(data);
      setState(() {
        _loading = false;
      });
    }).whenComplete(() {
      setState(() {});
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err.toString()),
          action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                apiGetData();
              })));
      setState(() {
        // _dataLoadingError = true;
      });
    });
  }

  List<int> checkingMaterials = [];

  checkMaterial(KitItem material, bool checked) {
    checkingMaterials.add(material.id);
    return Api.post("materialManagement/kit/checkItem", {'checked': checked, 'itemId': material.id, 'id': _kit.id}).then((res) {
      checkingMaterials.remove(material.id);
      apiGetData();
      widget.isKitChange(true);
    }).whenComplete(() {
      setState(() {});
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err.toString()),
          action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                apiGetData();
              })));
      setState(() {
        // _dataLoadingError = true;
      });
    });
  }

  getButton() {
    if (_loading) {
      return null;
    }

    switch (_kit.status.toLowerCase()) {
      case 'ready':
        {
          return FloatingActionButton.extended(
              onPressed: () {
                sendKit();
              },
              label: const Text('Send'),
              icon: const Icon(Icons.send),
              backgroundColor: Colors.green);
        }
      case 'sent':
        {
          return FloatingActionButton.extended(onPressed: () {}, label: const Text('Receive'), icon: const Icon(Icons.thumb_up), backgroundColor: Colors.deepOrangeAccent);
        }
    }
    return null;
  }

  Future sendKit() {
    return Api.post("materialManagement/kit/sendKit", {'kit': _kit.id}).then((res) {
      Map data = res.data;
      apiGetData();
    }).whenComplete(() {
      setState(() {});
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err.toString()),
          action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                apiGetData();
              })));
      setState(() {
        // _dataLoadingError = true;
      });
    });
  }

  getMatRow(KitItem material) {
    NsUser? user = (material.user);
    return DataRow2(cells: [
      DataCell(checkingMaterials.contains(material.id)
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 1.5))
          : Checkbox(
              value: material.isChecked(),
              onChanged: (checked) {
                if (checked != null) {
                  checkMaterial(material, checked);
                }
                setState(() {
                  material.setChecked(checked!);
                });
              })),
      DataCell(Text(material.item)),
      DataCell(Text(material.qty)),
      DataCell(Text(material.dnt.replaceAll(" ", "\n"))),
      DataCell(user != null
          ? ListTile(
              leading: UserImage(nsUser: user, radius: 12),
              title: Text(user.uname, style: const TextStyle(fontSize: 12)),
            )
          : const Text('-')),
    ]);
  }

  Future getComments() {
    return Api.get("materialManagement/getCprComments", {'id': _kit.id}).then((res) {
      Map data = res.data;

      kitComments = Message.fromJsonArray(data["messages"]);
      setState(() {});
    }).whenComplete(() {
      setState(() {});
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err.toString()),
          action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                apiGetData();
              })));
      setState(() {
        // _dataLoadingError = true;
      });
    });
  }

  TextEditingController commentController = TextEditingController();

  saveComment() {
    String text = commentController.text;
    commentController.clear();
    return Api.post("materialManagement/saveCprComment", {'text': text, 'cprId': _kit.id}).then((res) {
      Map data = res.data;
      getComments();
    }).whenComplete(() {
      setState(() {});
    }).catchError((err) {});
  }

  void updateProduction(String prod) {
    Api.post("materialManagement/kit/updateClient", {'client': prod, 'kitId': _kit.id}).then((res) {
      Map data = res.data;
      apiGetData();
    }).whenComplete(() {
      setState(() {});
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err.toString()),
          action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                updateProduction(prod);
              })));
      setState(() {
        // _dataLoadingError = true;
      });
    });
  }
}
