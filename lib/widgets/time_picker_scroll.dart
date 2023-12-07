import 'package:booker/main.dart';
import 'package:flutter/material.dart';

class TimePickerScroll extends StatefulWidget {
  final TimeOfDay time;
  final double fontSize;
  final Function(TimeOfDay) onTimeChanged;

  TimePickerScroll({required this.time, required this.fontSize, required this.onTimeChanged});

  @override
  _TimePickerScrollState createState() => _TimePickerScrollState();
}

class _TimePickerScrollState extends State<TimePickerScroll> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _hourController = FixedExtentScrollController(initialItem: widget.time.hour);
    _minuteController = FixedExtentScrollController(initialItem: widget.time.minute);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: widget.fontSize * 6,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hours
          Expanded(
            child: ListWheelScrollView.useDelegate(
              controller: _hourController,
              itemExtent: 60,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                widget.onTimeChanged(TimeOfDay(hour: index % 24, minute: widget.time.minute));
              },
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  final hour = index % 24; // Wrap around if the index exceeds 24
                  return Center(
                    child: Text(
                      hour.toString().padLeft(2, '0'),
                      style: TextStyle(color: Colors.black, fontSize: widget.fontSize),
                    ),
                  );
                },
              ),
            ),
          ),
          Text(':', style: TextStyle(color: Colors.black, fontSize: widget.fontSize),),
          // Minutes
          Expanded(
            child: ListWheelScrollView.useDelegate(
              controller: _minuteController,
              itemExtent: 60,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                widget.onTimeChanged(TimeOfDay(hour: widget.time.hour, minute: index % 60));
              },
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  final minute = index % 60; // Wrap around if the index exceeds 60
                  return Center(
                    child: Text(
                      minute.toString().padLeft(2, '0'),
                      style: TextStyle(color: Colors.black, fontSize: widget.fontSize),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
