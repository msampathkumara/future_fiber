import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessageBox {
  static show(context, title, content) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            )
          ],
        );
      },
    );
  }
}
