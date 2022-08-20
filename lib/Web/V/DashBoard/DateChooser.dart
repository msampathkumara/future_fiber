import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DateChooser extends StatefulWidget {
  final Null Function(DateTime rangeStartDate, DateTime? rangeEndDate)? onChose;
  final DateRangePickerSelectionMode selectionMode;

  const DateChooser({Key? key, this.onChose, required this.selectionMode}) : super(key: key);

  @override
  State<DateChooser> createState() => _DateChooserState();
}

class _DateChooserState extends State<DateChooser> {
  var rangeEndDate;

  var rangeStartDate;
  var now = DateTime.now();

  String formatDate(DateTime date, {bool dateOnly = false}) => dateOnly ? DateFormat("yyyy MMMM d").format(date) : DateFormat("yyyy MMMM d HH:mm").format(date);

  @override
  void initState() {
    // TODO: implement initState
    rangeStartDate = DateTime(now.year, now.month, now.day);
    rangeEndDate = widget.selectionMode == DateRangePickerSelectionMode.single ? null : DateTime(now.year, now.month, now.day);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 40,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: PopupMenuButton<int>(
            offset: const Offset(0, 30),
            padding: const EdgeInsets.all(16.0),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
            child: Text("${formatDate(rangeStartDate!, dateOnly: rangeEndDate == null)} ${rangeEndDate == null ? "" : " - ${formatDate(rangeEndDate!)}"}"),
            onSelected: (result) {},
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              PopupMenuItem(
                value: 0,
                enabled: false,
                child: SizedBox(
                    width: 500,
                    height: 300,
                    child: SfDateRangePicker(
                        initialSelectedRange: PickerDateRange(rangeStartDate, rangeEndDate),
                        initialSelectedDate: rangeStartDate,
                        onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                          print(args.value);
                          rangeStartDate = null;
                          rangeEndDate = null;

                          if (args.value is PickerDateRange) {
                            rangeStartDate = args.value.startDate;
                            rangeEndDate = args.value.endDate;
                          } else if (args.value is DateTime) {
                            rangeStartDate = args.value;
                          } else if (args.value is List<DateTime>) {
                            final List<DateTime> selectedDates = args.value;
                          } else {
                            final List<PickerDateRange> selectedRanges = args.value;
                          }
                          setState(() {});
                        },
                        selectionMode: widget.selectionMode)),
              ),
              PopupMenuItem(
                value: 1,
                enabled: false,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (widget.onChose != null) {
                        widget.onChose!(rangeStartDate, rangeEndDate);
                      }
                    },
                    child: const Text('Done')),
              )
            ],
          ),
        ),
      ),
    );
  }
}
