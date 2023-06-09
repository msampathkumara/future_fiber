import 'package:deebugee_plugin/DialogView.dart';
import 'package:deebugee_plugin/IfWeb.dart';
import 'package:deebugee_plugin/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:universal_html/html.dart' as html;

import '../../../../C/Api.dart';
import '../../../../M/AppUser.dart';
import '../../../../M/CPR/CPR.dart';
import '../../../../M/CPR/CprItem.dart';
import '../../../../M/CPR/cprActivity.dart';
import '../../../../M/Chat/message.dart';
import '../../../../M/EndPoints.dart';
import '../../../../M/NsUser.dart';
import '../../../../M/PermissionsEnum.dart';
import '../../../../Mobile/V/Widgets/UserImage.dart';
import '../../../Widgets/chatBubble.dart';
import '../../ProductionPool/copy.dart';
import 'LinkViewer.dart';

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

  List<CprActivity> cprActivities = [];

  Map<String, bool> cprsExpanded = {};

  List<Message> cprComments = [];

  TextEditingController commentController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  bool isAllChecked = false;

  bool get haveMoreToCheck => _cpr.items.where((element) => (element.isChecked())).length < _cpr.items.length;

  @override
  void initState() {
    // _cpr = widget.cpr;

    apiGetData();
    getComments();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getWebUi(), child: DialogView(width: 1200, child: getWebUi()));
  }

  bool _loading = true;

  Scaffold getWebUi() {
    // todo fix user permission
    bool sendAnyCpr = AppUser.havePermissionFor(NsPermissions.CPR_SEND_ANY_CPR);

    return Scaffold(
        appBar: AppBar(title: const Text("View CPR")),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Builder(builder: (context) {
                return Row(children: [
                  Flexible(
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
                              ListTile(visualDensity: vd, title: Text('Status', style: titleTheme), subtitle: Text(_cpr.status, style: valTheme)),
                            ],
                          ),
                        ],
                      ),
                      if (_cpr.imageUrl != null)
                        ListTile(
                            onTap: () async {
                              if (kIsWeb) {
                                html.window.open(_cpr.imageUrl ?? '', 'image');
                              } else {
                                LinkViewer(_cpr.imageUrl ?? '', _cpr.imageUrl ?? '').show(context);
                              }
                            },
                            visualDensity: vd,
                            title: Text('Image', style: titleTheme),
                            subtitle: TextMenu(child: Text(_cpr.imageUrl ?? '', style: valTheme))),
                      const SizedBox(height: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Card(
                            elevation: 4,
                            child: Column(children: [
                              SizedBox(
                                width: double.infinity,
                                child: DataTable(columns: [
                                  const DataColumn(label: Text('')),
                                  const DataColumn(label: Text('Item')),
                                  const DataColumn(label: Text('Qty')),
                                  const DataColumn(label: Text('Date')),
                                  const DataColumn(label: Text('User')),
                                  if (AppUser.havePermissionFor(NsPermissions.CPR_DELETE_CPR_MATERIALS)) const DataColumn(label: Text(''))
                                ], rows: [
                                  for (var material in _cpr.items) getMatRow(material)
                                ]),
                              )
                            ]),
                          ),
                        ),
                      ),
                      const Divider(color: Colors.red),
                      Table(children: [
                              TableRow(children: [
                                ...(cprActivitiesWithNull)
                                    .map((e) => e.id == 0
                                        ? Container()
                                        : (e.status != 'Sent'
                                            ? Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: sendAnyCpr
                                                    ? ElevatedButton(
                                                        onPressed: (unSentCount == 1 && haveMoreToCheck && sendAnyCpr) ? null : () => {sendCpr(e.id)},
                                                        child: Text("${e.supplier} Send"))
                                                    : null)
                                            : ListTile(
                                                leading: UserImage(nsUser: e.sentBy, radius: 16),
                                                title: Text(e.sentBy?.name ?? '', style: valTheme),
                                                subtitle: Wrap(
                                                  direction: Axis.vertical,
                                                  children: [
                                                    Text(e.supplier, style: const TextStyle(fontSize: 10, color: Colors.redAccent)),
                                                    Text(e.sentOn, style: const TextStyle(fontSize: 10, color: Colors.black))
                                                  ],
                                                ))))
                                    .toList(),
                                if ((AppUser.havePermissionFor(NsPermissions.CPR_RECEIVE_CPRS)) && _cpr.status.toLowerCase() == 'sent')
                                  receiving
                                      ? const Padding(padding: EdgeInsets.all(8.0), child: Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator())))
                                      : Padding(padding: const EdgeInsets.all(8.0), child: ElevatedButton(onPressed: () => {receiveCpr()}, child: const Text("Receive")))
                              ])
                            ]),
                    ],
                  ),
                ),
              ),
            ),
            if (kIsWeb)
              SizedBox(
                  width: 300,
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
                                    title: TextFormField(controller: commentController, onFieldSubmitted: (r) => {saveComment()}),
                                    trailing: IconButton(onPressed: () => {saveComment()}, icon: const Icon(Icons.send, color: Colors.green, size: 24)))
                              ],
                      ),
                    ),
                  ))
          ]);
        }));
  }

  int unSentCount = 0;
  List<CprActivity> cprActivitiesWithNull = [];

  Future apiGetData() {
    setState(() {
      _loading = true;
    });
    return Api.get(EndPoints.materialManagement_cpr_getCpr, {'id': widget.cpr.id}).then((res) {
      Map data = res.data;

      _cpr = CPR.fromJson(res.data);
      isAllChecked = _cpr.items.where((element) => element.checked == 0).isEmpty;
      unSentCount = _cpr.cprActivities.where((element) => element.status.toLowerCase() != 'sent').length;
      cprActivities = _cpr.cprActivities;
      cprActivitiesWithNull = getCprActivities(cprActivities);

      setSupplierPermissions();
      print(data);
      setState(() {
        _loading = false;
      });
    }).whenComplete(() {
      setState(() {});
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.toString()), action: SnackBarAction(label: 'Retry', onPressed: () => {apiGetData()})));
      setState(() {});
    });
  }

  List<int> checkingMaterials = [];

  Future<void> checkMaterial(CprItem material, bool checked) {
    checkingMaterials.add(material.id);
    return Api.post(EndPoints.materialManagement_cpr_checkItem, {'checked': checked, 'itemId': material.id, 'id': widget.cpr.id}).then((res) {
      checkingMaterials.remove(material.id);
      apiGetData();
      widget.isCprChange(true);
    }).whenComplete(() {
      setState(() {});
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.toString()), action: SnackBarAction(label: 'Retry', onPressed: () => {apiGetData()})));
      setState(() {
        // _dataLoadingError = true;
      });
    });
  }

  ElevatedButton? getButton(CprActivity cprA) {
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
    }
    return null;
  }

  Future sendCpr(id) {
    return Api.post(EndPoints.materialManagement_cpr_sendCpr, {'cprActivityId': id}).then((res) {
      widget.isCprChange(true);
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
    return Api.get(EndPoints.materialManagement_getCprComments, {'id': widget.cpr.id}).then((res) {
      Map data = res.data;

      cprComments = Message.fromJsonArray(data["messages"]);
      setState(() {});
    }).whenComplete(() {
      setState(() {});
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.toString()), action: SnackBarAction(label: 'Retry', onPressed: () => {getComments()})));
      setState(() {
        // _dataLoadingError = true;
      });
    });
  }

  DataRow getMatRow(CprItem material) {
    NsUser? user = (material.user);
    var dnt = material.dnt.split(" ");
    var date = dnt.asMap().containsKey(0) ? dnt[0] : '-';
    var time = dnt.asMap().containsKey(1) ? dnt[1] : '-';

    return DataRow(cells: [
      DataCell(checkingMaterials.contains(material.id)
          ? const Padding(padding: EdgeInsets.all(8.0), child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 1.5))))
          : Checkbox(
          value: material.isChecked(),
          onChanged: (AppUser.havePermissionFor(NsPermissions.CPR_CHECK_CPR_ITEMS))
              ? _cpr.isSent
              ? null
              : (checked) {
            material.setChecked(checked!);
            setState(() {});
            checkMaterial(material, checked);
          }
              : null)),
      DataCell(Text(material.item)),
      DataCell(Text(material.qty)),
      DataCell(Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text(date), Text(time, textAlign: TextAlign.end, style: const TextStyle(fontSize: 12, color: Colors.grey))])),
      DataCell(user != null ? ListTile(leading: UserImage(nsUser: user, radius: 12), title: Text(user.uname)) : const Text('-')),
      if (AppUser.havePermissionFor(NsPermissions.CPR_DELETE_CPR_MATERIALS))
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

  Future<void> saveComment() {
    String text = commentController.text;
    commentController.clear();
    return Api.post(EndPoints.materialManagement_saveCprComment, {'text': text, 'cprId': widget.cpr.id}).then((res) {
      getComments();
    }).whenComplete(() {
      setState(() {});
    }).catchError((err) {});
  }

  final Map<String, bool> _suppliersPermissions = {};

  void setSupplierPermissions() {
    for (var sup in _cpr.suppliers) {
      _suppliersPermissions[sup] = (AppUser.getUser()?.sections ?? []).where((element) => element.sectionTitle.equalIgnoreCase(sup)).isNotEmpty;
    }
  }

  List<CprActivity> getCprActivities(List<CprActivity> cprs) {
    for (var i = cprs.length; i < 3; i++) {
      cprs.add(CprActivity());
    }
    return cprs;
  }

  Future<void> deleteMaterial(CprItem material) {
    setState(() {
      _loading = true;
    });
    return Api.post(EndPoints.materialManagement_deleteMaterial, {'itemId': material.id, 'id': widget.cpr.id}).then((res) {}).whenComplete(() {
      apiGetData();
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.toString()), action: SnackBarAction(label: 'Retry', onPressed: () => {deleteMaterial(material)})));
      setState(() {
        // _dataLoadingError = true;
      });
    });
  }

  bool receiving = false;

  void receiveCpr() {
    setState(() {
      receiving = true;
    });
    Api.post(EndPoints.materialManagement_cpr_receive, {'cprId': _cpr.id}).then((res) {
      receiving = false;
      apiGetData();
    }).whenComplete(() {
      setState(() {});
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.toString())));
      setState(() {
        receiving = false;
      });
    });
  }
}
