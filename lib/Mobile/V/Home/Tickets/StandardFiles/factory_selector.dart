import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FactorySelector extends StatefulWidget {
  final String? selectedFactory;

  final String title;

  final Function(String)? onSelect;

  const FactorySelector(this.selectedFactory, {this.onSelect, Key? key, this.title = "Select Factory"}) : super(key: key);

  @override
  State<FactorySelector> createState() => _FactorySelectorState();

  show(context) async {
    await showModalBottomSheet<void>(
      constraints: kIsWeb ? const BoxConstraints(maxWidth: 600) : null,
      context: context,
      builder: (BuildContext context) {
        return Container(
            decoration: const BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)), color: Colors.white),
            height: 650,
            child: this);
      },
    );
  }
}

List<String> factoryList = ['Upwind', 'OD', 'Nylon Standard', 'OEM'];

class _FactorySelectorState extends State<FactorySelector> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              ListTile(title: Text(widget.title)),
              const Divider(),
              Expanded(
                  child: SingleChildScrollView(
                      child: Column(children: [
                for (var x in factoryList)
                  RadioListTile(
                      value: x,
                      selected: widget.selectedFactory == x,
                      groupValue: widget.selectedFactory,
                      onChanged: (v) async {
                        setLoading(true);

                        if (widget.onSelect != null) {
                          widget.onSelect!(x);
                        }
                        Navigator.of(context).pop(x);
                      },
                      title: Text(x)),
              ])))
            ],
          );
  }

  void setLoading(bool bool) {
    setState(() {
      _loading = bool;
    });
  }
}
