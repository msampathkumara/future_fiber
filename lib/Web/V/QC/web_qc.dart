import 'package:flutter/cupertino.dart';

import '../underConstruction.dart';

class WebQc extends StatefulWidget {
  const WebQc({Key? key}) : super(key: key);

  @override
  State<WebQc> createState() => _WebQcState();
}

class _WebQcState extends State<WebQc> {
  @override
  Widget build(BuildContext context) {
    return Container(child: UnderConstructions());
  }
}
