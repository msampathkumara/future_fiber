import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:deebugee_plugin/DialogView.dart';
import 'package:smartwind_future_fibers/C/Api.dart';
import 'package:smartwind_future_fibers/C/form_input_decoration.dart';

import '../../../../../../M/EndPoints.dart';

class AddTimeSheet extends StatefulWidget {
  final int selectedSectionId;
  final String uniqueKey;

  const AddTimeSheet(this.selectedSectionId, this.uniqueKey, {Key? key}) : super(key: key);

  @override
  State<AddTimeSheet> createState() => _AddTimeSheetState();

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _AddTimeSheetState extends State<AddTimeSheet> {
  bool loading = true;

  @override
  void initState() {
    loadSubOperations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DialogView(
      width: 500,
      child: getWebUi(),
    );
  }

  Scaffold getWebUi() {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Add Times'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(onPressed: () => {Navigator.of(context).pop()}, icon: const Icon(Icons.close))
          ],
        ),
        body: loading
            ? Container(width: double.infinity, height: double.infinity, color: Colors.white, child: const Center(child: CircularProgressIndicator()))
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        itemBuilder: (context, index) {
                          var x = subOperations[index];
                          return ListTile(
                            leading: Text("${index + 1}"),
                            title: Text("${x['subOperation']}"),
                            trailing: Wrap(
                              children: [
                                SizedBox(
                                    width: 100,
                                    height: 36,
                                    child: TextFormField(
                                        initialValue: x["nop"] ?? '',
                                        decoration: FormInputDecoration.getDeco(hintText: 'No of people'),
                                        textInputAction: TextInputAction.next,
                                        onChanged: (t) {
                                          x["nop"] = t;
                                        },
                                        keyboardType: TextInputType.number)),
                                SizedBox(
                                    width: 100,
                                    height: 36,
                                    child: TextFormField(
                                        initialValue: x["time"] ?? '',
                                        decoration: FormInputDecoration.getDeco(hintText: 'Time'),
                                        onChanged: (t) {
                                          x["time"] = t;
                                        },
                                        textInputAction: TextInputAction.next,
                                        keyboardType: TextInputType.number)),
                              ],
                            ),
                          );
                        },
                        itemCount: subOperations.length),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        saveTimeCard();
                      },
                      child: const Text("Save"))
                ],
              ));
  }

  Scaffold getUi() => getWebUi();

  List subOperations = [];

  void loadSubOperations() {
    setState(() => loading = true);

    Api.get(EndPoints.tickets_finish_getSubOperations, {'sectionId': widget.selectedSectionId}).then((res) {
      print(res.data);
      subOperations = res.data["subOperations"];
    }).whenComplete(() {
      setState(() => loading = false);
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.toString()), action: SnackBarAction(label: 'Retry', onPressed: () => {loadSubOperations()})));
      setState(() {
        // _dataLoadingError = true;
      });
    });
  }

  void saveTimeCard() {
    setState(() => loading = true);
    Api.post(EndPoints.tickets_finish_saveTimeCard, {'subOperations': subOperations, 'uniqueKey': widget.uniqueKey}).then((res) {
      print(res.data);
      Navigator.of(context).pop(true);
    }).whenComplete(() {
      setState(() => loading = false);
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.toString()), action: SnackBarAction(label: 'Retry', onPressed: () => {loadSubOperations()})));
      setState(() {
        // _dataLoadingError = true;
      });
    });
  }
}
