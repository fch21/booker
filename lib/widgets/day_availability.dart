import 'package:booker/models/time_interval.dart';
import 'package:booker/widgets/time_slot_widget.dart';
import 'package:flutter/material.dart';

class DayAvailability extends StatefulWidget {
  String dayName;
  Function(String, bool, List<TimeInterval?>) onDayChanged;
  bool initialIsSelected;
  List<TimeInterval> initialIntervals;

  DayAvailability({
    required this.dayName,
    required this.onDayChanged,
    required this.initialIsSelected,
    required this.initialIntervals,
  });

  @override
  _DayAvailabilityState createState() => _DayAvailabilityState();
}

class _DayAvailabilityState extends State<DayAvailability> {
  bool isExpanded = false;
  late bool isSelected;
  late List<TimeInterval> intervals;

  _addTimeInterval() async {
    TimeInterval? newTimeInterval = await TimeInterval.pickTime(context);
    if(newTimeInterval != null){
      setState(() {
        intervals.add(newTimeInterval);
      });
      _updateDay();
    }
  }

  _updateDay() {
    widget.onDayChanged(
      widget.dayName,
      isSelected,
      intervals,
    );
  }

  _removeTimeInterval(int index){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          title: Text("Remover Horário?"),
          content: Text("Você deseja realmente remover esse horário?"),
          actions: <Widget>[
            TextButton(
              child: Text("Não"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Sim"),
              onPressed: () {
                setState(() {
                  intervals.removeAt(index);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    print("initstate widget.initialIntervals = ${widget.initialIntervals}");
    isSelected = widget.initialIsSelected;
    intervals = List.of(widget.initialIntervals);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("widget.initialIntervals = ${widget.initialIntervals}");
    print("intervals = ${intervals}");

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ListTile(
            title: Row(
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      isSelected = value!;
                      _updateDay();
                    });
                  },
                ),
                Text(widget.dayName),
                const Spacer(),
                IconButton(
                  icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    if (isSelected) {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          if (isExpanded && isSelected)
            Wrap(
              children: [
                for(int i = 0; i < intervals.length; i++)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onLongPress: (){
                        _removeTimeInterval(i);
                      },
                      child: TimeSlotWidget(onTimeChanged: _updateDay, initialInterval: intervals[i],)
                    ),
                  ),
              ],
            ),

          if (isExpanded && isSelected)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: _addTimeInterval,
                  child: Text("Adicionar horário")
                )
              ),
            )
        ],
      ),
    );
  }
}