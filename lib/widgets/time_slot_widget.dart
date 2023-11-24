import 'package:booker/models/time_interval.dart';
import 'package:flutter/material.dart';

import '../helper/utils.dart';





class TimeSlotWidget extends StatefulWidget {
  final Function onTimeChanged;
  TimeInterval? initialInterval;
  Color? color;
  TimeSlotWidget({required this.onTimeChanged, this.initialInterval, this.color});



  @override
  _TimeSlotWidgetState createState() => _TimeSlotWidgetState();
}

class _TimeSlotWidgetState extends State<TimeSlotWidget> {
  TimeInterval? interval;

  _changeTimeInterval() async {
    TimeInterval? newTimeInterval = await TimeInterval.pickTime(context);

    if(newTimeInterval != null){
      setState(() {
        interval = newTimeInterval;
        widget.onTimeChanged();
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    interval = widget.initialInterval;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("build");
    return ElevatedButton(
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(widget.color)),
      onPressed: _changeTimeInterval,
      child: Text(
        "${interval?.startTime?.format(context) ?? "Início"} - ${interval?.endTime?.format(context) ?? "Término"}",
        style: TextStyle(color: Utils.getContrastingColor(widget.color)),
      ),
    );
  }
}
