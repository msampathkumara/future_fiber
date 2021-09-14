import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class SearchBar extends StatefulWidget implements PreferredSizeWidget {
  var onSearchTextChanged;
  var OnBarcode;
  var onSubmitted;

  var child;

  int delay = 0;

  SearchBar({@required this.onSearchTextChanged, @required this.onSubmitted, this.OnBarcode, this.child, this.delay = 0}) {
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

  StreamSubscription? subscription;

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
                        if (subscription != null) {
                          subscription!.cancel();
                        }
                        var future = new Future.delayed(Duration(milliseconds: widget.delay));
                        subscription = future.asStream().listen((v) {
                          widget.onSearchTextChanged(val);
                        });
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
            ],
          )),
    );
  }
}
