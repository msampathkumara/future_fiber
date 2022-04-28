import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/C/Api.dart';
import 'package:smartwind/M/CPR/CPR.dart';
import 'package:smartwind/M/CPR/CprItem.dart';
import 'package:smartwind/M/Chat/message.dart';
import 'package:smartwind/V/Widgets/UserImage.dart';
import 'package:smartwind/Web/Widgets/DialogView.dart';
import 'package:smartwind/Web/Widgets/IfWeb.dart';
import 'package:smartwind/Web/Widgets/chatBubble.dart';

import '../../../../M/NsUser.dart';

class CprView extends StatefulWidget {
  final CPR cpr;

  final Function(bool) isCprChange;

  const CprView(this.cpr, this.isCprChange, {Key? key}) : super(key: key);

  @override
  State<CprView> createState() => _CprViewState();

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _CprViewState extends State<CprView> {
  var titleTheme = const TextStyle(fontSize: 12, color: Colors.grey);
  var valTheme = const TextStyle(fontSize: 15, color: Colors.black);
  var vd = const VisualDensity(horizontal: 0, vertical: -4);
  var st = const TextStyle(fontSize: 12, color: Colors.black);

  late CPR _cpr;

  int? _canSend;

  late List<CPR> cprs;

  @override
  void initState() {
    _cpr = widget.cpr;
    cprs = [_cpr, _cpr, _cpr];
    apiGetData();

    // _canSend=AppUser.getUser()?.sections.indexWhere((element) => element.id==_cpr.supplier.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getUi(), child: DialogView(width: 1200, child: getWebUi()));
  }

  bool _loading = true;

  getWebUi() {
    return Scaffold(
      appBar: AppBar(title: const Text("View CPR")),
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
                                    Text('${_cpr.ticket?.mo}', style: valTheme),
                                    Text('${_cpr.ticket?.oe}', style: const TextStyle(fontSize: 12, color: Colors.deepOrange))
                                  ])),
                              ListTile(visualDensity: vd, title: Text('Client', style: titleTheme), subtitle: Text('${_cpr.client}', style: valTheme)),
                              ListTile(visualDensity: vd, title: Text('Supplier(s)', style: titleTheme), subtitle: Text(cprs.map((e) => e.supplier).join(','), style: valTheme)),
                            ]),
                            TableRow(
                              children: [
                                ListTile(visualDensity: vd, title: Text('Shortage Type', style: titleTheme), subtitle: Text('${_cpr.shortageType}', style: valTheme)),
                                ListTile(visualDensity: vd, title: Text('CPR Type', style: titleTheme), subtitle: Text('${_cpr.cprType}', style: valTheme)),
                                Container()
                              ],
                            ),
                          ],
                        ),
                        Expanded(
                          child: ListView.separated(
                            itemCount: cprs.length,
                            separatorBuilder: (BuildContext context, int index) {
                              return const Divider();
                            },
                            itemBuilder: (BuildContext context, int index) {
                              var __cpr = cprs[index];

                              return Card(
                                elevation: 4,
                                child: Column(children: [
                                  ListTile(title: Text(__cpr.supplier, textScaleFactor: 1.2)),
                                  for (var material in __cpr.items)
                                    ListTile(
                                        title: Text(material.item, style: valTheme),
                                        leading: checkingMaterials.contains(material.id)
                                            ? const Padding(
                                                padding: EdgeInsets.all(8.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 1.5)))
                                            : Checkbox(
                                                value: material.isChecked(),
                                                onChanged: (checked) {
                                                  if (checked != null) {
                                                    checkMaterial(material, checked);
                                                  }
                                                  setState(() {
                                                    material.setChecked(checked!);
                                                  });
                                                }),
                                        subtitle: (material.isChecked() && (!checkingMaterials.contains(material.id)))
                                            ? Row(
                                                children: [
                                                  UserImage(nsUser: NsUser.fromId(material.user!.id), radius: 8),
                                                  Padding(padding: const EdgeInsets.only(left: 8, right: 8), child: Text(material.user!.uname, style: st)),
                                                  const Icon(Icons.query_builder_rounded, color: Colors.grey, size: 16),
                                                  Text(" ${material.dnt}", style: st)
                                                ],
                                              )
                                            : null,
                                        trailing: Wrap(alignment: WrapAlignment.center, direction: Axis.vertical, children: [
                                          Text("${material.qty}"),
                                        ])),
                                  const Divider(color: Colors.red),
                                  Table(
                                    children: [
                                      TableRow(
                                        children: [
                                          __cpr.user != null
                                              ? ListTile(
                                                  visualDensity: vd,
                                                  title: Text("Added By ", style: titleTheme),
                                                  subtitle: ListTile(
                                                      leading: UserImage(nsUser: NsUser.fromId(__cpr.user!.id), radius: 16),
                                                      title: Text(__cpr.user!.uname, style: valTheme),
                                                      subtitle: Text(__cpr.addedOn, style: const TextStyle(fontSize: 12, color: Colors.black))))
                                              : Container(),
                                          (__cpr.sentUser != null)
                                              ? ListTile(
                                                  visualDensity: vd,
                                                  title: Text("Sent By ", style: titleTheme),
                                                  subtitle: ListTile(
                                                      leading: UserImage(nsUser: NsUser.fromId(__cpr.sentUser!.id), radius: 16),
                                                      title: Text(__cpr.sentUser!.uname, style: valTheme),
                                                      subtitle: Text("${__cpr.sentOn ?? ""}", style: const TextStyle(fontSize: 12, color: Colors.black))))
                                              : Container(),
                                        ],
                                      )
                                    ],
                                  ),
                                ]),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                  width: 400,
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
                                  itemCount: 10,
                                  itemBuilder: (context, index) {
                                    return ChatBubble(Message(), isSelf: (index % 2 == 0));
                                  }),
                            ),
                          ),
                          ListTile(
                            title: TextFormField(),
                            trailing: IconButton(
                                onPressed: () {},
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

  getUi() {}

  Future apiGetData() {
    return Api.get("materialManagement/cpr/getCpr", {'id': _cpr.id}).then((res) {
      Map data = res.data;

      _cpr = CPR.fromJson(res.data);
      var _cpr1 = CPR.fromJson(res.data);

      var _cpr2 = CPR.fromJson(res.data);

      cprs = [_cpr, _cpr1, _cpr2];

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

  checkMaterial(CprItem material, bool checked) {
    checkingMaterials.add(material.id);
    return Api.post("materialManagement/cpr/checkItem", {'checked': checked, 'itemId': material.id, 'id': _cpr.id}).then((res) {
      checkingMaterials.remove(material.id);
      apiGetData();
      widget.isCprChange(true);
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

    switch (_cpr.status.toLowerCase()) {
      case 'ready':
        {
          return FloatingActionButton.extended(
              onPressed: () {
                sendCpr();
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

  Future sendCpr() {
    return Api.post("materialManagement/cpr/sendCpr", {'cpr': _cpr.id}).then((res) {
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
}
