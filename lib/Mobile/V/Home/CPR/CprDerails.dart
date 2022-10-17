import 'package:flutter/material.dart';
import 'package:smartwind/M/CPR/CPR.dart';
import 'package:smartwind/M/CPR/CprItem.dart';
import 'package:smartwind/M/NsUser.dart';

import '../../../../C/Api.dart';
import '../../Widgets/ErrorMessageView.dart';
import '../../Widgets/UserImage.dart';

class CprDetails extends StatefulWidget {
  final CPR cpr;

  const CprDetails(this.cpr, {super.key});

  static show(context, CPR cpr) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CprDetails(cpr)),
    );
  }

  @override
  _CprDetailsState createState() => _CprDetailsState();
}

class _CprDetailsState extends State<CprDetails> with TickerProviderStateMixin {
  late CPR _cpr;
  bool saving = false;

  var st = const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();
    _cpr = widget.cpr;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tabBarController = TabController(length: 2, vsync: this);
      _tabBarController!.addListener(() {
        print("Selected Index: " + _tabBarController!.index.toString());
      });
      setState(() {});
    });

    Api.get("cpr/getCpr", {"id": _cpr.id}).then((res) async {
      print("res.data ${res.data}");
      if (res.data["error"] == null) {
        _cpr = CPR.fromJson(res.data);
        // print(_cpr.toJson());
        setState(() {});
      } else {
        await ErrorMessageView(errorMessage: res.data["error"]).show(context);
        Navigator.of(context).pop();
      }
    });
  }

  TabController? _tabBarController;

  @override
  Widget build(BuildContext context) {
    print(_cpr.toJson());

    if (_tabBarController == null) {
      return saving
          ? Container(
              child: Center(
                  child: Column(
                    children: const [CircularProgressIndicator(), Text("Saving")],
            )))
          : Container();
    } else {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
            // floatingActionButton: Visibility(
            //   visible: !keyboardIsOpen,
            //   child: FloatingActionButton(
            //     onPressed: () {
            //       saving = true;
            //       setState(() {});
            //       OnlineDB.apiPost("cpr/saveCpr", _cpr.toJson()).then((value) {
            //         saving = false;
            //         // Navigator.of(context).pop();
            //       }).catchError((onError) {
            //         ErrorMessageView(errorMessage: onError.toString()).show(context);
            //       });
            //     },
            //     child: const Icon(Icons.save),
            //     backgroundColor: Colors.lightBlue,
            //   ),
            // ),
            appBar: AppBar(
                title: const Text("CPR Details"),
                bottom: TabBar(
                  controller: _tabBarController,
                  indicatorWeight: 4.0,
                  indicatorColor: Colors.white,
                  isScrollable: true,
                  tabs: [
                    Tab(
                      child: Wrap(alignment: WrapAlignment.center, children: [
                        const Icon(
                          Icons.info_rounded,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 4, bottom: 4, left: 4),
                          child: const Text("Info"),
                        )
                      ]),
                    ),
                    Tab(
                      child: Wrap(alignment: WrapAlignment.center, children: [
                        const Icon(
                          Icons.settings_suggest_rounded,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 4, bottom: 4, left: 4),
                          child: const Text("Materials"),
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
                          title: const Text("Sail"),
                          subtitle: ListTile(
                              title: Text(_cpr.ticket?.mo ?? _cpr.ticket?.oe ?? "", style: st),
                              subtitle: Text(_cpr.ticket?.mo != null ? _cpr.ticket?.oe ?? "" : "", style: const TextStyle(fontWeight: FontWeight.bold)))),
                      ListTile(title: const Text("Sail Type"), subtitle: Text("${_cpr.sailType}", style: st)),
                      ListTile(title: const Text("Client"), subtitle: Text("${_cpr.client}", style: st)),
                      ListTile(title: const Text("Suppliers"), subtitle: Text("${_cpr.suppliers.join(',')}", style: st)),
                      ListTile(title: const Text("Shortage Type"), subtitle: Text("${_cpr.shortageType}", style: st)),
                      ListTile(title: const Text("CPR Type"), subtitle: Text("${_cpr.cprType}", style: st)),
                      if (_cpr.user != null)
                        ListTile(
                            title: const Text("Added By "),
                            subtitle: ListTile(
                                leading: UserImage(nsUser: NsUser.fromId(_cpr.user!.id), radius: 24), title: Text(_cpr.user!.uname, style: st), subtitle: Text(_cpr.addedOn))),
                      if (_cpr.sentUser != null)
                        ListTile(
                            title: const Text("Sent By "),
                            subtitle: ListTile(
                                leading: UserImage(nsUser: NsUser.fromId(_cpr.sentUser!.id), radius: 24),
                                title: Text(_cpr.sentUser!.uname, style: st),
                                subtitle: Text(_cpr.sentOn ?? ""))),
                    ])),
                  ),
                ),
                Container(
                    child: ListTile(
                      title: const Text("Materials"),
                  subtitle: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(children: [
                        Expanded(
                          child: Card(
                            child: ListView.separated(
                                itemBuilder: (context, index) {
                                  CprItem material = _cpr.items[index];
                                  print(material.toJson());
                                  return GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onLongPress: () async {
                                      await showMaterialOptions(material, context);
                                      setState(() {});
                                    },
                                    child: ListTile(
                                        title: Text(material.item, style: st),
                                        // leading: Checkbox(
                                        //     value: material.isChecked(),
                                        //      onChanged: (checked){setState(() {
                                        //       material.setChecked(checked!);
                                        //     });}
                                        // ),
                                        subtitle: material.isChecked()
                                            ? Row(
                                                children: [
                                                  UserImage(nsUser: NsUser.fromId(material.user!.id), radius: 12),
                                                  Padding(
                                                      padding: const EdgeInsets.only(left: 8, right: 8),
                                                      child: Text(material.user!.uname, style: const TextStyle(fontWeight: FontWeight.bold))),
                                                  const Icon(Icons.query_builder_rounded, color: Colors.grey, size: 16),
                                                  Text(" ${material.dnt}", style: const TextStyle(fontWeight: FontWeight.bold))
                                                ],
                                              )
                                            : null,
                                        trailing: Wrap(alignment: WrapAlignment.center, direction: Axis.vertical, children: [
                                          Text("${material.qty}", style: st),
                                        ])),
                                  );
                                },
                                itemCount: _cpr.items.length,
                                separatorBuilder: (BuildContext context, int index) {
                                  return const Divider(height: 1, endIndent: 0.5, color: Colors.black12);
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

  CprItem currentMaterial = new CprItem();

  getData(String filter) {
    List<String> data = _matList.where((element) => element.toLowerCase().contains(filter.toLowerCase())).toList();
    data.add(filter);
    return Future.value(data);
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
              child: Column(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.max, children: <Widget>[
                Column(children: [
                  const SizedBox(height: 20),
                  ListTile(
                      title: const Text("Delete"),
                      leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                      onTap: () async {
                        _cpr.items.removeWhere((item) => item == material);
                        Navigator.of(context).pop();
                      })
                ])
              ]));
        });
  }
}
