import 'package:flutter/cupertino.dart';

import '../underConstruction.dart';

class WebSheetData extends StatefulWidget {
  const WebSheetData({Key? key}) : super(key: key);

  @override
  State<WebSheetData> createState() => _WebSheetDataState();
}

class _WebSheetDataState extends State<WebSheetData> {
  @override
  Widget build(BuildContext context) {
    return Container(child: UnderConstructions());
  }
}
