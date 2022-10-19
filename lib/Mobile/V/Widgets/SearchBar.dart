import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

// ignore: must_be_immutable
class SearchBar extends StatefulWidget implements PreferredSizeWidget {
  TextEditingController searchController;

  Function(String text) onSearchTextChanged;
  final Function? onBarCode;
  final Function(String)? onSubmitted;

  Widget? child;

  int delay = 0;

  SearchBar({super.key, required this.onSearchTextChanged, this.onSubmitted, this.onBarCode, this.child, this.delay = 300, required this.searchController}) {
    print("_______________________________________");
  }

  @override
  _SearchBarState createState() {
    return _SearchBarState();
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
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
      var future = Future.delayed(Duration(milliseconds: widget.delay));
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
    if (kIsWeb) {
      return Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
            height: 40,
            width: 200,
            child: TextFormField(
              controller: widget.searchController,
              onChanged: (text) {},
              cursorColor: Colors.black,
              decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: widget.searchController.clear),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.only(left: 15, bottom: 11, top: 10, right: 15),
                  hintText: "Search Text"),
            )),
      );
    }

    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Flexible(
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.search),
                  title: TextField(
                    controller: widget.searchController,
                    decoration: const InputDecoration(hintText: 'Search', border: InputBorder.none),
                    onSubmitted: widget.onSubmitted,
                    onChanged: (val) {},
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.cancel),
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
                      icon: const Icon(Icons.qr_code_scanner_outlined),
                      onPressed: () async {
                        var permissionStatus = await Permission.camera.request();
                        if (permissionStatus.isGranted) {
                          String barcode = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.DEFAULT);
                          if (barcode == '-1') {
                            print('nothing return.');
                          } else {
                            if (widget.onBarCode != null) {
                              widget.onBarCode!(barcode);
                            }

                            widget.searchController.text = barcode;
                          }
                        }
                      },
                    ),
                  ),
                ),
              ),
            if (widget.child != null) widget.child!
          ],
        ));
  }
}
