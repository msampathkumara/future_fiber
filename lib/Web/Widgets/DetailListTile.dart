import 'package:flutter/material.dart';

class DetailListTile extends StatelessWidget {
  final String? title;

  final String? subtitle;

  const DetailListTile({Key? key, this.title, this.subtitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text("$title", style: const TextStyle(color: Colors.grey, fontSize: 16)), subtitle: Text("$subtitle", style: const TextStyle(color: Colors.black, fontSize: 20)));
  }
}
