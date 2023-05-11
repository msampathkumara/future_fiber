import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:smartwind_future_fibers/C/form_input_decoration.dart';
import 'package:smartwind_future_fibers/Web/Widgets/DialogView.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../../C/Api.dart';
import '../../../../M/EndPoints.dart';
import '../../../../M/Enums.dart';

class AddEmployeeCounts extends StatefulWidget {
  const AddEmployeeCounts({Key? key}) : super(key: key);

  @override
  State<AddEmployeeCounts> createState() => _AddEmployeeCountsState();

  Future show(context) {
    return showDialog(context: context, builder: (_) => this);
  }
}

class _AddEmployeeCountsState extends State<AddEmployeeCounts> {
  DateTime? selectedDate;

  String? selectedFactory;
  Map? selectedShift;

  bool error = false;

  bool loading = false;

  List _shiftsList = [];
  List sectionEmployeeCounts = [];
  Map sectionEmployeeCountsMap = {};

  List _selectedFactoryShiftsList = [];

  bool get isFactorySelected => selectedFactory != null;

  bool get isShiftSelected => selectedShift != null;

  @override
  void initState() {
    // TODO: implement initState
    print('zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DialogView(width: 500, height: 600, child: getWebUi());
  }

  List<String> _sections = [];

  Scaffold getWebUi() {
    return Scaffold(
        appBar: AppBar(title: const Text("Add Employee Count")),
        body: !isShiftSelected
            ? getFactorySector()
            : loading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      ListTile(title: getFactorySector()),
                      const Padding(
                          padding: EdgeInsets.only(left: 8.0, right: 8),
                          child: Divider(
                            color: Colors.red,
                          )),
                      Expanded(
                        child: ListView.separated(
                          itemBuilder: (BuildContext context, int index) {
                            var section = _sections[index];
                            Map? sectionAvg = sectionEmployeeCountsMap[section];
                            var myController = TextEditingController();
                            myController.text = "${sectionAvg?["employeeCount"] ?? 0}";
                            var focusNode = FocusNode();
                            focusNode.addListener(() {
                              if (focusNode.hasFocus) {
                                myController.selectAll();
                              }
                            });

                            return ListTile(
                              title: Text(section),
                              trailing: SizedBox(
                                  width: 100,
                                  height: 36,
                                  child: TextFormField(
                                    focusNode: focusNode,
                                    controller: myController,
                                    onTap: myController.selectAll,
                                    autofocus: true,
                                    onChanged: (text) => sectionEmployeeCountsMap[section]["employeeCount"] = text,
                                    decoration: FormInputDecoration.getDeco(),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), FilteringTextInputFormatter.digitsOnly],
                                  )),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) => Divider(color: Colors.grey.shade200),
                          itemCount: _sections.length,
                        ),
                      ),
                    ],
                  ),
        bottomNavigationBar: (isShiftSelected && !loading)
            ? BottomAppBar(child: Padding(padding: const EdgeInsets.all(8.0), child: ElevatedButton(onPressed: save, child: const Text('Save'))))
            : null);
  }

  Widget getFactorySector() {
    var x = [
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: PopupMenuButton<int>(
            offset: const Offset(0, 30),
            padding: const EdgeInsets.all(16.0),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
            child: Chip(
                label: Text(selectedDate == null ? "Select Date" : DateFormat('yyyy MMMM dd').format(selectedDate ?? DateTime.now()), style: const TextStyle(color: Colors.black))),
            onSelected: (result) {},
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<int>>[
                PopupMenuItem(
                  value: 0,
                  enabled: false,
                  child: SizedBox(
                      width: 500,
                      height: 300,
                      child: SfDateRangePicker(
                          onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                            if (args.value is DateTime) {
                              selectedDate = args.value;
                            }
                            Navigator.of(context).pop();
                            selectedShift = null;
                            selectedFactory = null;
                            setState(() {});
                          },
                          selectionMode: DateRangePickerSelectionMode.single)),
                )
              ];
            }),
      ),
      if (isShiftSelected) const SizedBox(width: 16),
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: PopupMenuButton<int>(
            enabled: selectedDate != null,
            offset: const Offset(0, 30),
            padding: const EdgeInsets.all(16.0),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
            child: Chip(label: Text(selectedFactory ?? 'Select Factory', style: const TextStyle(color: Colors.black))),
            onSelected: (result) {},
            itemBuilder: (BuildContext context) {
              return Production.values
                  .without([Production.None, Production.All])
                  .map((e) => PopupMenuItem(
                      onTap: () {
                        selectedShift = null;
                        selectedFactory = e.getValue();

                        getShiftsByDate();
                      },
                      value: 0,
                      enabled: true,
                      child: Text(e.getValue())))
                  .toList();
            }),
      ),
      const SizedBox(width: 16),
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: PopupMenuButton<int>(
            enabled: _selectedFactoryShiftsList.isNotEmpty,
            offset: const Offset(0, 30),
            padding: const EdgeInsets.all(16.0),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
            child: Chip(label: Text(selectedShift?["shiftName"] ?? 'Select Shift', style: const TextStyle(color: Colors.black))),
            onSelected: (result) {},
            itemBuilder: (BuildContext context) {
              return _selectedFactoryShiftsList
                  .map((e) => PopupMenuItem(
                      onTap: () {
                        selectedShift = e;
                        setState(() {});
                        if (selectedFactory != null) {
                          getShiftData();
                        }
                      },
                      value: 0,
                      enabled: true,
                      child: Text(e["shiftName"] ?? '')))
                  .toList();
            }),
      ),
    ];

    return loading
        ? const Center(child: CircularProgressIndicator())
        : isShiftSelected
            ? Row(children: x)
            : Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: x));
  }

  getShiftsByDate() {
    setState(() {
      loading = true;
      selectedShift = null;
    });

    Api.get(EndPoints.dashboard_settings_getShiftsByDate, {'date': selectedDate, 'factory': selectedFactory}).then((res) {
      Map data = res.data;
      print(data);

      _shiftsList = data["shifts"];
      _selectedFactoryShiftsList = _shiftsList.where((element) => (element['factoryName'] ?? '').toString().toLowerCase() == selectedFactory?.toLowerCase()).toList();
    }).whenComplete(() {
      setState(() {
        loading = false;
      });
    }).catchError((err) {
      print(err);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.toString()), action: SnackBarAction(label: 'Retry', onPressed: getShiftsByDate)));
      setState(() {
        // _dataLoadingError = true;
      });
    });
  }

  getShiftData() {
    setState(() {
      loading = true;
    });
    Api.get(EndPoints.dashboard_settings_getShiftSectionEmployeeCount, {'factory': selectedFactory, 'shiftId': selectedShift!["id"]}).then((res) {
      Map data = res.data;

      sectionEmployeeCounts = data["sectionEmployeeCounts"];
      sectionEmployeeCountsMap = {for (var e in sectionEmployeeCounts) e["sectionTitle"]: e};
      _sections = sectionEmployeeCountsMap.keys.map((e) => e as String).toList();
    }).whenComplete(() {
      setState(() {
        loading = false;
      });
    }).catchError((err) {
      print(err);
      error = true;
    });
  }

  void save() {
    setState(() {
      loading = true;
    });

    Api.post(EndPoints.dashboard_settings_saveShiftSectionEmployeeCount, {'shiftSectionEmployeeCounts': sectionEmployeeCountsMap.values.toList()}).then((res) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saved"), width: 200, behavior: SnackBarBehavior.floating));
      Navigator.pop(context);
      selectedFactory = null;
    }).whenComplete(() {
      setState(() {
        loading = false;
      });
    }).catchError((err) {
      print(err);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Something went wrong"), action: SnackBarAction(label: 'Retry', onPressed: save)));
      setState(() {
        // _dataLoadingError = true;
      });
    });
  }
}
