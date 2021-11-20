import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

// ignore: must_be_immutable
class SearchBar extends StatefulWidget implements PreferredSizeWidget {
  TextEditingController searchController;

  var onSearchTextChanged;
  var onBarCode;
  var onSubmitted;

  var child;

  int delay = 0;

  SearchBar({required this.onSearchTextChanged, this.onSubmitted, this.onBarCode, this.child, this.delay = 300, required this.searchController}) {
    print("_______________________________________");

  }

  @override
  _SearchBarState createState() {
    return _SearchBarState();
  }

  @override
  Size get preferredSize => Size.fromHeight(50);
}

class _SearchBarState extends State<SearchBar> {
  StreamSubscription? subscription;

  @override
  void initState() {
    super.initState();
    widget.searchController.addListener(() {
      if (subscription != null) {
        subscription!.cancel();
      }
      var future = new Future.delayed(Duration(milliseconds: widget.delay));
      subscription = future.asStream().listen((val) {
        print(val);
        widget.onSearchTextChanged(widget.searchController.text);
      });
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.deepOrangeAccent,
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Flexible(
                child: Card(
                  child: ListTile(
                    leading: Icon(Icons.search),
                    title: TextField(
                      controller: widget.searchController,
                      decoration: InputDecoration(hintText: 'Search', border: InputBorder.none),
                      onSubmitted: widget.onSubmitted,
                      onChanged: (val) {},
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.cancel),
                      onPressed: () {
                        widget.searchController.clear();
                        widget.onSearchTextChanged('');
                      },
                    ),
                  ),
                ),
              ),
              if (widget.onBarCode != null)
                InkWell(
                  onTap: () {},
                  splashColor: Colors.red,
                  child: Ink(
                    child: Card(
                      child: IconButton(
                        icon: Icon(Icons.qr_code_scanner_outlined),
                        onPressed: () async {
                          var permissionStatus = await Permission.camera.request();
                          if (permissionStatus.isGranted) {
                            String barcode = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.DEFAULT);
                            if (barcode == '-1') {
                              print('nothing return.');
                            } else {
                              widget.onBarCode(barcode);
                              // setState(() {
                              widget.searchController.text = barcode;
                              // widget.onSearchTextChanged(barcode);
                              // });
                            }

                            // String barcode = await scanner.scan();
                            // if (barcode == null) {
                            //   print('nothing return.');
                            // } else {
                            //   widget.OnBarcode(barcode);
                            //   // setState(() {
                            //   searchController.text = barcode;
                            //   widget.onSearchTextChanged(barcode);
                            //   // });
                            // }
                          }
                        },
                      ),
                    ),
                  ),
                ),
              if (widget.child != null) widget.child
            ],
          )),
    );
  }
}
