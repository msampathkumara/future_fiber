import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeekPicker extends StatefulWidget {
  final Function(DateTime start, DateTime end, int year, int week) onSelect;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime selectedDate;

  const WeekPicker({Key? key, required this.onSelect, required this.firstDate, required this.lastDate, required this.selectedDate}) : super(key: key);

  @override
  State<WeekPicker> createState() => _WeekPickerState();
}

class _WeekPickerState extends State<WeekPicker> {
  int _currentYear = 0;


  @override
  void initState() {
    _currentYear = widget.selectedDate.year;

    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.jumpTo(_controller.position.maxScrollExtent));

    super.initState();
  }

  List months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    var weeks = getWeekList(_currentYear);
    int todayWeek = weekNumber(DateTime.now());
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
            child: ListView.separated(
          controller: _controller,
          itemCount: weeks.length,
          itemBuilder: (BuildContext context, int index) {
            var week = weeks[index];
            return InkWell(
              onTap: () {
                widget.onSelect(week["start"], week["end"], _currentYear, week["week"]);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(children: [
                  CircleAvatar(backgroundColor: todayWeek == week["week"] ? null : Colors.white, child: Text("${week["week"]}")),
                  const SizedBox(width: 16),
                  Text("${DateFormat("MM/dd").format(week["start"])} to ${DateFormat("MM/dd").format(week["end"])}")
                ]),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return const Divider(thickness: 0.5);
          },
        )),
      ],
    );
  }

  void setYear(int i) {
    setState(() {
      _currentYear = i;
    });
  }

  List<Map> getWeekList(int year) {
    Map<int, Map> weekMap = {};
    int i = 0;
    getDaysInBetween(DateTime(year, 1, 1, 0, 0), DateTime.now()).forEach((d) {
      if (DateFormat("E").format(d) == "Mon") {
        i++;
        weekMap[i] = {'start': d, 'week': i, 'end': d.add(const Duration(days: 6))};
      }
    });
    return weekMap.values.toList();
  }

  List<DateTime> getDaysInBetween(DateTime startDate, DateTime endDate) {
    List<DateTime> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    return days;
  }

  int weekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }
}
