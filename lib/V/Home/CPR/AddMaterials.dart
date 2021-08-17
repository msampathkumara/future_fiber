import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/M/CPR.dart';

class AddMaterials extends StatefulWidget {
  CPR cpr;

  AddMaterials(this.cpr);

  @override
  _AddMaterialsState createState() => _AddMaterialsState();
}

List<String> _statesOfIndia = ['United States', 'America', 'Washington', 'India', 'Paris', 'Jakarta', 'Australia', 'Lorem Ipsum'];

class _AddMaterialsState extends State<AddMaterials> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return AlertDialog(
        title: Text("Materials"),
        content: Container(
          width: width - 200,
          height: height / 2,
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 400,
                    height: 50,
                    child: DropdownSearch<String>(showSearchBox: true,
                        mode: Mode.DIALOG,
                        showSelectedItem: true,showClearButton:true,
                        isFilteredOnline:true,
                        onFind: (String filter) => getData(filter),
                        label: "Menu mode",
                        hint: "country in menu mode",
                        popupItemDisabled: (String s) => s.startsWith('I'),
                        onChanged: print,
                        selectedItem: "Brazil"),
                  )
                ],
              ),
              Expanded(child: Container())
            ],
          ),
        ));
  }

  getData(String filter) {

    List<String> data= _statesOfIndia.where((element) => element.toLowerCase().contains(filter.toLowerCase())).toList();
  data.add(filter);
    return Future.value( data);
  }
}
