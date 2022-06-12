import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/C/Api.dart';
import 'package:smartwind/M/AppUser.dart';
import 'package:smartwind/M/CPR/CPR.dart';
import 'package:smartwind/M/CPR/CprItem.dart';
import 'package:smartwind/M/Chat/message.dart';
import 'package:smartwind/M/Enums.dart';
import 'package:smartwind/V/Widgets/UserImage.dart';
import 'package:smartwind/Web/Widgets/DialogView.dart';
import 'package:smartwind/Web/Widgets/IfWeb.dart';
import 'package:smartwind/Web/Widgets/chatBubble.dart';

import '../../../../M/CPR/cprActivity.dart';
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

  List<CprActivity> cprs = [];

  Map<String, bool> cprsExpanded = {};

  List<Message> cprComments = [];

  TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    _cpr = widget.cpr;

    apiGetData();
    getComments();

    setSupplierPermissions();

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
                                ListTile(visualDensity: vd, title: Text('Supplier(s)', style: titleTheme), subtitle: Text((_cpr.suppliers).join(','), style: valTheme)),
                              ]),
                              TableRow(
                                children: [
                                  ListTile(visualDensity: vd, title: Text('Shortage Type', style: titleTheme), subtitle: Text('${_cpr.shortageType}', style: valTheme)),
                                  ListTile(visualDensity: vd, title: Text('CPR Type', style: titleTheme), subtitle: Text('${_cpr.cprType}', style: valTheme)),
                                  ListTile(visualDensity: vd, title: Text('Status', style: titleTheme), subtitle: Text('${_cpr.status}', style: valTheme)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                              child: SingleChildScrollView(
                                  child: ExpansionPanelList(
                            expansionCallback: (int index, bool isExpanded) {
                              setState(() {
                                cprsExpanded[cprs[index].supplier] = !isExpanded;
                              });
                            },
                            children: cprs.map<ExpansionPanel>((CprActivity __cprA) {
                              return ExpansionPanel(
                                headerBuilder: (BuildContext context, bool isExpanded) {
                                  return ListTile(
                                    title: Text(__cprA.supplier),
                                    subtitle: Text(__cprA.status),
                                    leading: __cprA.status.isReady(caseInsensitive: true)
                                        ? const Icon(Icons.done, color: Colors.green, size: 20)
                                        : const Icon(Icons.done, color: Colors.grey, size: 20),
                                    trailing: getButton(__cprA),
                                  );
                                },
                                body: Card(
                                  elevation: 0,
                                  child: Column(children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: DataTable(columns: const [
                                        DataColumn(label: Text('')),
                                        DataColumn(label: Text('Item')),
                                        DataColumn(label: Text('Qty')),
                                        DataColumn(label: Text('Date')),
                                        DataColumn(label: Text('User')),
                                      ], rows: [
                                        for (var material in __cprA.items) getMatRow(material)
                                      ]),
                                    ),
                                    const Divider(color: Colors.red),
                                    Table(
                                      children: [
                                        TableRow(
                                          children: [
                                            __cprA.addedBy != null
                                                ? ListTile(
                                                    visualDensity: vd,
                                                    title: Text("Added By ", style: titleTheme),
                                                    subtitle: ListTile(
                                                        leading: UserImage(nsUser: NsUser.fromId(__cprA.addedBy!.id), radius: 16),
                                                        title: Text(__cprA.addedBy!.uname, style: valTheme),
                                                        subtitle: Text(__cprA.addedOn, style: const TextStyle(fontSize: 12, color: Colors.black))))
                                                : Container(),
                                            (__cprA.sentBy != null)
                                                ? ListTile(
                                                    visualDensity: vd,
                                                    title: Text("Sent By ", style: titleTheme),
                                                    subtitle: ListTile(
                                                        leading: UserImage(nsUser: NsUser.fromId(__cprA.sentBy!.id), radius: 16),
                                                        title: Text(__cprA.sentBy!.uname, style: valTheme),
                                                        subtitle: Text(__cprA.sentOn, style: const TextStyle(fontSize: 12, color: Colors.black))))
                                                : Container(),
                                          ],
                                        )
                                      ],
                                    ),
                                  ]),
                                ),
                                isExpanded: cprsExpanded[__cprA.supplier] ?? false,
                              );
                            }).toList(),
                          )))
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
                                    itemCount: cprComments.length,
                                    itemBuilder: (context, index) {
                                      Message msg = cprComments[index];
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
                                  icon: const Icon(Icons.send, color: Colors.green, size: 24)),
                            )
                          ],
                        ),
                      ),
                    ))
              ]));
  }

  getUi() {
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
                                ListTile(visualDensity: vd, title: Text('Supplier(s)', style: titleTheme), subtitle: Text((_cpr.suppliers).join(','), style: valTheme)),
                              ]),
                              TableRow(
                                children: [
                                  ListTile(visualDensity: vd, title: Text('Shortage Type', style: titleTheme), subtitle: Text('${_cpr.shortageType}', style: valTheme)),
                                  ListTile(visualDensity: vd, title: Text('CPR Type', style: titleTheme), subtitle: Text('${_cpr.cprType}', style: valTheme)),
                                  ListTile(visualDensity: vd, title: Text('Status', style: titleTheme), subtitle: Text('${_cpr.status}', style: valTheme)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                              child: SingleChildScrollView(
                                  child: ExpansionPanelList(
                            expansionCallback: (int index, bool isExpanded) {
                              setState(() {
                                cprsExpanded[cprs[index].supplier] = !isExpanded;
                              });
                            },
                            children: cprs.map<ExpansionPanel>((CprActivity __cprA) {
                              return ExpansionPanel(
                                headerBuilder: (BuildContext context, bool isExpanded) {
                                  return ListTile(
                                    title: Text(__cprA.supplier),
                                    subtitle: Text(__cprA.status),
                                    leading: __cprA.status.isReady(caseInsensitive: true)
                                        ? const Icon(Icons.done, color: Colors.green, size: 20)
                                        : const Icon(Icons.done, color: Colors.grey, size: 20),
                                    trailing: getButton(__cprA),
                                  );
                                },
                                body: Card(
                                  elevation: 0,
                                  child: Column(children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: DataTable(columns: const [
                                        DataColumn(label: Text('')),
                                        DataColumn(label: Text('Item')),
                                        DataColumn(label: Text('Qty')),
                                        DataColumn(label: Text('Date')),
                                        DataColumn(label: Text('User')),
                                      ], rows: [
                                        for (var material in __cprA.items) getMatRow(material)
                                      ]),
                                    ),
                                    const Divider(color: Colors.red),
                                    Table(
                                      children: [
                                        TableRow(
                                          children: [
                                            __cprA.addedBy != null
                                                ? ListTile(
                                                    visualDensity: vd,
                                                    title: Text("Added By ", style: titleTheme),
                                                    subtitle: ListTile(
                                                        leading: UserImage(nsUser: NsUser.fromId(__cprA.addedBy!.id), radius: 16),
                                                        title: Text(__cprA.addedBy!.uname, style: valTheme),
                                                        subtitle: Text(__cprA.addedOn, style: const TextStyle(fontSize: 12, color: Colors.black))))
                                                : Container(),
                                            (__cprA.sentBy != null)
                                                ? ListTile(
                                                    visualDensity: vd,
                                                    title: Text("Sent By ", style: titleTheme),
                                                    subtitle: ListTile(
                                                        leading: UserImage(nsUser: NsUser.fromId(__cprA.sentBy!.id), radius: 16),
                                                        title: Text(__cprA.sentBy!.uname, style: valTheme),
                                                        subtitle: Text(__cprA.sentOn, style: const TextStyle(fontSize: 12, color: Colors.black))))
                                                : Container(),
                                          ],
                                        )
                                      ],
                                    ),
                                  ]),
                                ),
                                isExpanded: cprsExpanded[__cprA.supplier] ?? false,
                              );
                            }).toList(),
                          )))
                        ],
                      ),
                    ),
                  ),
                ),
                // SizedBox(
                //     width: 400,
                //     child: Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: Card(
                //         elevation: 4,
                //         child: Column(
                //           children: [
                //             Expanded(
                //               child: Padding(
                //                 padding: const EdgeInsets.all(8.0),
                //                 child: ListView.builder(
                //                     itemCount: cprComments.length,
                //                     itemBuilder: (context, index) {
                //                       Message msg = cprComments[index];
                //                       return ChatBubble(msg, isSelf: msg.isSelf);
                //                     }),
                //               ),
                //             ),
                //             ListTile(
                //               title: TextFormField(
                //                   controller: commentController,
                //                   onFieldSubmitted: (r) {
                //                     saveComment();
                //                   }),
                //               trailing: IconButton(
                //                   onPressed: () {
                //                     saveComment();
                //                   },
                //                   icon: const Icon(Icons.send, color: Colors.green, size: 24)),
                //             )
                //           ],
                //         ),
                //       ),
                //     ))
              ]));
  }

  Future apiGetData() {
    return Api.get("materialManagement/cpr/getCpr", {'id': _cpr.id}).then((res) {
      Map data = res.data;

      _cpr = CPR.fromJson(res.data);

      cprs = _cpr.cprs;

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

  getButton(CprActivity cprA) {
    var status = cprA.status;
    if (_loading) {
      return null;
    }

    switch (status.toLowerCase()) {
      case 'ready':
        {
          return ((_suppliersPermissions[cprA.supplier]) ?? false)
              ? ElevatedButton(
                  onPressed: () {
                    sendCpr(cprA.id);
                  },
                  child: const Text('Send'))
              : null;
        }
      // case 'sent':
      //   {
      //     return FloatingActionButton.extended(onPressed: () {}, label: const Text('Receive'), icon: const Icon(Icons.thumb_up), backgroundColor: Colors.deepOrangeAccent);
      //   }
    }
    return null;
  }

  Future sendCpr(id) {
    return Api.post("materialManagement/cpr/sendCpr", {'id': id}).then((res) {
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

  Future getComments() {
    return Api.get("materialManagement/getCprComments", {'id': _cpr.id}).then((res) {
      Map data = res.data;

      cprComments = Message.fromJsonArray(data["messages"]);
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

  getMatRow(CprItem material) {
    NsUser? user = (material.user);
    return DataRow(cells: [
      DataCell(checkingMaterials.contains(material.id)
          ? const Padding(padding: EdgeInsets.all(8.0), child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 1.5))))
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
              title: Text("${user.uname}"),
            )
          : const Text('-')),
    ]);
  }

  saveComment() {
    String text = commentController.text;
    commentController.clear();
    return Api.post("materialManagement/saveCprComment", {'text': text, 'cprId': _cpr.id}).then((res) {
      Map data = res.data;
      getComments();
    }).whenComplete(() {
      setState(() {});
    }).catchError((err) {});
  }

  Map<String, bool> _suppliersPermissions = {};

  void setSupplierPermissions() {
    _cpr.suppliers.forEach((sup) {
      _suppliersPermissions[sup] = (AppUser.getUser()?.sections ?? []).where((element) => element.sectionTitle.equalIgnoreCase(sup)).isNotEmpty;
    });
  }
}