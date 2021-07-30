import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

// ignore: must_be_immutable
class SearchBar extends StatefulWidget implements PreferredSizeWidget {
  var onSearchTextChanged;
  var OnBarcode;
  var onSubmitted;

  var child;

  SearchBar({@required this.onSearchTextChanged, @required this.onSubmitted, this.OnBarcode, this.child}) {
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
  final TextEditingController searchController = new TextEditingController();

  @override
  void initState() {
    super.initState();
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
                      controller: searchController,
                      decoration: InputDecoration(hintText: 'Search', border: InputBorder.none),
                      onSubmitted: widget.onSubmitted,
                      onChanged: (val) {
                        widget.onSearchTextChanged(val);
                      },
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.cancel),
                      onPressed: () {
                        searchController.clear();
                        widget.onSearchTextChanged('');
                      },
                    ),
                  ),
                ),
              ),
              if (widget.OnBarcode != null)
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
                            String barcode = await scanQR();
                            if (barcode == null) {
                              print('nothing return.');
                            } else {
                              widget.OnBarcode(barcode);
                              // setState(() {
                              searchController.text = barcode;
                              widget.onSearchTextChanged(barcode);
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
                ), if(widget.child != null)widget.child
            ],
          )),
    );
  }

  scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", true, ScanMode.QR);
      print("barcodeScanRes");
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return null;

    return barcodeScanRes;
  }
}
