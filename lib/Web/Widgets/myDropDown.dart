import 'package:flutter/material.dart';

typedef PopupMenuItemSelected<T> = String Function(T value);
typedef PopupMenuItemSelected1<T> = String Function(T value);
typedef OnChildBuild<T> = Widget? Function(T value);

class MyDropDown<T> extends StatefulWidget {
  final T value;
  final List<T>? items;
  final int? elevation;
  final PopupMenuItemSelected1<T> onSelect;
  final PopupMenuItemSelected<T> selectedText;
  final String? lable;
  final OnChildBuild<T> onChildBuild;
  final TextStyle? lableStyle;

  const MyDropDown(
      {super.key, this.items, this.elevation, required this.onSelect, required this.selectedText, required this.value, this.lable, this.lableStyle, required this.onChildBuild});

  @override
  State<MyDropDown<T>> createState() => _MyDropDownState<T>();
}

enum WhyFarther { harder, smarter, selfStarter, tradingCharter }

class _MyDropDownState<T> extends State<MyDropDown<T>> {
  final GlobalKey _menuKey = GlobalKey();

  String? _selectinString = '';

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectinString = widget.selectedText.call(widget.value);
    });

    // widget.onChanged(widget.value);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final button = PopupMenuButton<T>(
        key: _menuKey,
        shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(4))),
        color: Colors.white,
        offset: const Offset(20, 40),
        onSelected: (T result) {
          setState(() {
            print(result);
            _selectinString = widget.onSelect.call(result);
          });
        },
        itemBuilder: (BuildContext context) {
          return [for (T item in widget.items ?? []) PopupMenuItem<T>(value: item, child: widget.onChildBuild.call(item))];
        },
        child: Icon(Icons.arrow_drop_down_sharp, size: 24, color: Theme.of(context).primaryColor));

    return InkWell(
      onTap: () {
        dynamic state = _menuKey.currentState;
        state.showButtonMenu();
      },
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(4),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.lable != null) Text(widget.lable ?? '', style: widget.lableStyle ?? TextStyle(fontSize: 10, color: Theme.of(context).primaryColor)),
                  Text(_selectinString ?? '', style: const TextStyle(fontSize: 16, color: Colors.black)),
                ],
              ),
              button
            ],
          ),
        ),
      ),
    );
  }
}
