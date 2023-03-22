import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartwind/Web/Widgets/DialogView.dart';
import 'package:smartwind/Web/Widgets/IfWeb.dart';

class Rf_test extends StatefulWidget {
  const Rf_test({Key? key}) : super(key: key);

  @override
  State<Rf_test> createState() => _Rf_testState();

  Future show(context) {
    return kIsWeb ? showDialog(context: context, builder: (_) => this) : Navigator.push(context, MaterialPageRoute(builder: (context) => this));
  }
}

class _Rf_testState extends State<Rf_test> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IfWeb(elseIf: getUi(), child: DialogView(child: getWebUi()));
  }

  getWebUi() {
    return Scaffold(
      appBar: AppBar(title: Text('test')),
    );
  }

  getUi() {
    return getWebUi();
  }
}
