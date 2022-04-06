import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DetailListTile extends StatelessWidget {
  String? title;

  String? subtitle;

  DetailListTile({Key? key, this.title, this.subtitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text("$title",style: TextStyle(color: Colors.grey,fontSize: 16)), subtitle: Text("$subtitle",style: TextStyle(color: Colors.black,fontSize: 20)));
  }
}
