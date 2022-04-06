import 'package:flutter/cupertino.dart';
import 'package:smartwind/Web/V/underConstruction.dart';

class WebAdmin extends StatefulWidget {
  const WebAdmin({Key? key}) : super(key: key);

  @override
  State<WebAdmin> createState() => _WebAdminState();
}

class _WebAdminState extends State<WebAdmin> {
  @override
  Widget build(BuildContext context) {
    return Container(child: UnderConstructions(title: "Admin Panel"),);
  }
}
