import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind_future_fibers/C/Api.dart';
import 'package:smartwind_future_fibers/M/CPR/KIT.dart';
import 'package:smartwind_future_fibers/M/CPR/KitItem.dart';
import 'package:smartwind_future_fibers/M/Chat/message.dart';
import 'package:smartwind_future_fibers/M/EndPoints.dart';
import 'package:smartwind_future_fibers/M/Enums.dart';
import 'package:smartwind_future_fibers/Mobile/V/Home/Tickets/StandardFiles/factory_selector.dart';
import 'package:smartwind_future_fibers/Mobile/V/Widgets/UserImage.dart';
import 'package:smartwind_future_fibers/Web/V/MaterialManagement/KIT/AddMaterials.dart';
import 'package:smartwind_future_fibers/Web/Widgets/DialogView.dart';
import 'package:deebugee_plugin/DialogView.dart';
import 'package:smartwind_future_fibers/Web/Widgets/IfWeb.dart';
import 'package:smartwind_future_fibers/Web/Widgets/chatBubble.dart';

import '../../../../M/AppUser.dart';
import '../../../../M/CPR/CprItem.dart';
import '../../../../M/NsUser.dart';
import '../../../../M/PermissionsEnum.dart';

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

  final _canDeleted = AppUser.havePermissionFor(NsPermissions.KIT_DELETE_MATERIALS);

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
                                            setState(() => {_loading = true});
                                            apiGetData();
                                          },
                                          child: const Text("Add Materials"))
                                  ],
                                ))),
                              if (_kit.items.isNotEmpty)
                                Expanded(
                                    child: SizedBox(
                                        width: double.infinity,
                                        child: DataTable(columns: [
                                          const DataColumn(label: Text('')),
                                          const DataColumn(label: Text('Item')),
                                          const DataColumn(label: Text('Qty')),
                                          const DataColumn(label: Text('Date')),
                                          const DataColumn(label: Text('User')),
                                          if (_canDeleted) const DataColumn(label: Text(''))
                                        ], rows: [
                                          for (var material in _kit.items) getMatRow(material),
                                          // if (kIsWeb)
                                          //   DataRow2(cells: [
                                          //     DataCell.empty,
                                          //     DataCell.empty,
                                          //     DataCell.empty,
                                          //     DataCell.empty,
                                          //     if (_canDeleted) DataCell.empty,
                                          //     DataCell(TextButton(
                                          //         onPressed: () async {
                                          //           await AddMaterials(_kit.id).show(context) == true ? apiGetData() : null;
                                          //         },
                                          //         child: const Text("Add Materials"))),
                                          //   ])
                                        ]))),
                              if (_kit.items.isNotEmpty)
                                TextButton(
                                    onPressed: () async {
                                      await AddMaterials(_kit.id).show(context) == true ? apiGetData() : null;
                                    },
                                    child: const Text("Add Materials")),
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
    return Api.get(EndPoints.materialManagement_kit_getKit, {'id': _kit.id}).then((res) {
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

  Future checkMaterial(KitItem material, bool checked) {
    checkingMaterials.add(material.id);
    return Api.post(EndPoints.materialManagement_kit_checkItem, {'checked': checked, 'itemId': material.id, 'id': _kit.id}).then((res) {
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
    return Api.post(EndPoints.materialManagement_kit_sendKit, {'kit': _kit.id}).then((res) {
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
    print('AppUser.havePermissionFor(NsPermissions.KIT_CHECK_MATERIALS) ${AppUser.havePermissionFor(NsPermissions.KIT_CHECK_MATERIALS)}');
    return DataRow(cells: [
      DataCell(checkingMaterials.contains(material.id)
          ? const Padding(padding: EdgeInsets.all(8.0), child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 1.5))))
          : Checkbox(
              value: material.isChecked(),
              onChanged: (AppUser.havePermissionFor(NsPermissions.CPR_CHECK_CPR_ITEMS))
                  ? (checked) {
                      material.setChecked(checked!);
                      setState(() {});
                      checkMaterial(material, checked);
                    }
                  : null)),
      DataCell(Text(material.item)),
      DataCell(Text(material.qty)),
      DataCell(Text(material.dnt.replaceAll(" ", "\n"))),
      DataCell(user != null
          ? ListTile(
              leading: UserImage(nsUser: user, radius: 12),
              title: Text(user.uname, style: const TextStyle(fontSize: 12)),
            )
          : const Text('-')),
      if (_canDeleted)
        DataCell(IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: Colors.red,
                  content: const Text('Are you sure you want to delete this material ?'),
                  action: SnackBarAction(textColor: Colors.white, label: 'Yes', onPressed: () => {deleteMaterial(material)})));
            },
            icon: const Icon(Icons.close, color: Colors.red)))
    ]);
  }

  deleteMaterial(CprItem material) {
    setState(() {
      _loading = true;
    });
    return Api.post(EndPoints.materialManagement_deleteMaterial, {'itemId': material.id, 'id': widget.kit.id}).then((res) {}).whenComplete(() {
      apiGetData();
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.toString()), action: SnackBarAction(label: 'Retry', onPressed: () => {deleteMaterial(material)})));
      setState(() {
        // _dataLoadingError = true;
      });
    });
  }

  Future getComments() {
    return Api.get(EndPoints.materialManagement_getCprComments, {'id': _kit.id}).then((res) {
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
    return Api.post(EndPoints.materialManagement_saveCprComment, {'text': text, 'cprId': _kit.id}).then((res) {
      getComments();
    }).whenComplete(() {
      setState(() {});
    }).catchError((err) {});
  }

  void updateProduction(String prod) {
    Api.post(EndPoints.materialManagement_kit_updateClient, {'client': prod, 'kitId': _kit.id}).then((res) {
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
