import 'package:flutter/material.dart';

class TimeInterval{
  TimeOfDay startTime, endTime;

  TimeInterval({required this.startTime, required this.endTime});

  TimeInterval copy(){
    return TimeInterval(startTime: startTime, endTime: endTime);
  }

  bool isValid(){
    int startMinutes = startTime.hour * 60 + startTime.minute;
    int endMinutes = endTime.hour * 60 + endTime.minute;

    if(endMinutes > startMinutes){
      return true;
    }
    return false;
  }

  Map<String, dynamic> toMap() {
    return {
      'startTime': {'hour': startTime.hour, 'minute': startTime.minute},
      'endTime': {'hour': endTime.hour, 'minute': endTime.minute},
    };
  }

  static TimeInterval fromMap(Map<String, dynamic> map) {
    return TimeInterval(
      startTime: TimeOfDay(hour: map['startTime']['hour'], minute: map['startTime']['minute']),
      endTime: TimeOfDay(hour: map['endTime']['hour'], minute: map['endTime']['minute']),
    );
  }

  static DateTime convertToDateTime(TimeOfDay time) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }

  static Future<TimeInterval?> pickTime(BuildContext context, {TimeInterval? interval}) async {

    TimeInterval? timeInterval;

    TimeOfDay? initialTime = await showTimePicker(
      helpText: "Horário de início",
      context: context,
      initialTime: interval?.endTime ?? TimeOfDay.now(),
    );
    if (initialTime != null && context.mounted) {
      TimeOfDay? finalTime = await showTimePicker(
        helpText: "Horário de término",
        context: context,
        initialTime: interval?.endTime ?? TimeOfDay.now(),
      );
      if (finalTime != null) {
        if (convertToDateTime(initialTime).isBefore(convertToDateTime(finalTime))) {
          timeInterval = TimeInterval(startTime: initialTime, endTime: finalTime);
        } else {
          if(context.mounted) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Erro na seleção de horário"),
                  content: const Text("O horário de início precisa ser antes do horário de término."),
                  actions: <Widget>[
                    TextButton(
                      child: const Text("OK"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
        }
      }
    }

    return timeInterval;

  }

  @override
  String toString() {
    // TODO: implement toString
    return "${startTime.hour}:${startTime.minute < 10 ? "0" : ""}${startTime.minute} - ${endTime.hour}:${endTime.minute < 10 ? "0" : ""}${endTime.minute}";
  }

}