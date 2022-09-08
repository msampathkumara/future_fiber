import 'package:flutter/material.dart';

class MonthPicker extends StatefulWidget {
  final Function(DateTime month) onSelect;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime selectedDate;

  const MonthPicker({Key? key, required this.onSelect, required this.firstDate, required this.lastDate, required this.selectedDate}) : super(key: key);

  @override
  State<MonthPicker> createState() => _MonthPickerState();
}

class _MonthPickerState extends State<MonthPicker> {
  int _minYear = 0;
  int _currentYear = 0;

  int _currentMonth = 0;

  @override
  void initState() {
    _minYear = widget.firstDate.year;
    _currentYear = widget.selectedDate.year;
    _currentMonth = widget.selectedDate.month;

    super.initState();
  }

  List months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setYear(_currentYear - 1);
              },
            ),
            const Spacer(),
            Text("$_currentYear"),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setYear(_currentYear + 1);
              },
            ),
          ],
        ),
        const Divider(),
        Expanded(
          child: GridView.builder(
            itemCount: months.length,
            itemBuilder: (BuildContext context, int index) {
              String month = months[index];
              return ListTile(
                title: _currentMonth == (index + 1)
                    ? Chip(
                        label: Text(month),
                        backgroundColor: Theme.of(context).primaryColor,
                        labelStyle: TextStyle(color: Colors.white),
                      )
                    : Chip(label: Text(month), backgroundColor: Colors.transparent),
                onTap: () {
                  widget.onSelect(DateTime(_currentYear, index + 1));
                },
              );
            },
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 3),
          ),
        ),
      ],
    );
  }

  void setYear(int i) {
    setState(() {
      _currentYear = i;
    });
  }
}
